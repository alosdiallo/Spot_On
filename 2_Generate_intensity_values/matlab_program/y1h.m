function grid_positions = check_zeros_helper(grid_positions)

    % Globals
    delta = 0;
    numrows = 32;
    numcols = 48;
    index = 1;
    x_points = [];
    y_points = [];

    % Parse directory -- someone could be pathalogical by putting 'png' in their
    % filename, not as an extension
    file_data = dir('.');
    image_files = {};
    place = 1;
    for f = 1:length(file_data)
        if (strfind(lower(file_data(f).name), 'png'))
            image_files{place} = file_data(f).name;
            place = place + 1;
        end
    end
    total = length(image_files)

    % Build the data 
    if nargin < 1
        grid_positions = struct('filename' , '', 'x_points' , [], 'y_points' , []);
        grid_positions(total).x_points = [];
    end
    
    % This should handle people adding more pngs to a directory. No promises
    % though.
    if length(grid_positions) < total;
        grid_positions(total).x_points = [];
    end

    if exist('onCleanup') == 2
        onCleanup(@()save('results.mat', 'grid_positions'));
    end

    % Build GUI elements
    f = figure('Visible','off','Position',[360,500,450,285]);
    set(f, 'Toolbar', 'figure')
    haccept = uicontrol('Style','pushbutton','String','Save and move on',...
           'Position',[315,220,45,25],...
           'Callback',{@accept_Callback},...
           'BackgroundColor', 'g');
    hreject = uicontrol('Style','pushbutton','String','Try again',...
           'Position',[360,220,45,25],...
           'Callback',{@reject_Callback},...
           'BackgroundColor', 'r');
    hcommon = uicontrol('Style','text','String',...
                    'you should never see this',...
                    'Position',[315,205,90,15]);
    hprogress = uicontrol('Style','text','String',...
                          sprintf('Progress: %d/%d', index, total),...
                          'Position',[315,235,90,15]);
    hgoto_index = uicontrol('Style','edit','String','Index to warp to...',...
           'Position',[10, 5,100,15]);
    hgoto = uicontrol('Style','pushbutton','String','Warp',...
           'Position',[110, 5,30,15],...
           'Callback',{@goto_Callback},...
           'BackgroundColor', [0.72, 0.72, 0.72],...
           'Visible', 'on', 'Enable', 'on');
    hwarp_to_empty = uicontrol('Style','pushbutton','String','Warp to first nonempty',...
           'Position',[140, 5,90,15],...
           'Callback',{@empty_Callback},...
           'BackgroundColor', [0.72, 0.72, 0.72],...
           'Visible', 'off', 'Enable', 'on');
    ha = axes('Visible', 'on', 'Units','Pixels','Position',...
              [10,15,200 * 1.5,185*1.5]); 
    
    set([f,ha, hcommon,haccept, hreject, hprogress, hgoto, hwarp_to_empty,...
                                        hgoto_index],  'Units','normalized');
    align([f,ha, hcommon,haccept, hreject, hprogress, hgoto, hwarp_to_empty,...
                                hgoto_index], 'HorizontalAlignment', 'None');
    set(f,'Name','Grid Builder')
    movegui(f,'center')
    set(f,'Visible','on');
  
    update_display()
    uiwait(f)
    
    %% Setup Complete --- Here's where the real logic starts

    function update_display() 
        set([haccept, hreject], 'Enable', 'inactive', 'ForegroundColor', [0.72, 0.72, 0.72])
        set(hprogress, 'String', sprintf('Progress: %d/%d', index, total));
        set(hcommon, 'String', image_files{index})
        set(haccept, 'String', 'Save and move on');
        set(hreject, 'String', 'Try again');
        delta = 0;
        hold off
        imshow(image_files{index})
        set([hgoto_index, hgoto, hwarp_to_empty], 'Visible', 'off');
        hold on
        x_points = grid_positions(index).x_points;
        y_points = grid_positions(index).y_points;
        if not(isempty(grid_positions(index).x_points))
            plot(x_points, y_points, 'g.');
            set(haccept, 'String', 'Keep this grid');
            set(hreject, 'String', 'Overwrite this grid');
            set([haccept, hreject], 'Enable', 'on', 'ForegroundColor', 'k')
            set([hgoto_index, hgoto, hwarp_to_empty], 'Visible', 'on');
            return
        end
        [x y] = ginput(2);
        set([hgoto_index, hgoto, hwarp_to_empty], 'Visible', 'on');
        mid = [mean(x), mean(y)];
        c1 = [x(1), y(1)];
        c2 = [x(2), y(2)];
        dx = (x(2) - x(1))/(numcols-1);
        dy = (y(2) - y(1))/(numcols-1);
        col_step = [dx, dy];
        row_step = ([0 -1;1 0] * [dx;dy])';
        hold on
        x_points = zeros(numrows, numcols);
        y_points = zeros(numrows, numcols);
        for row = 1:numrows
            for col = 1:numcols
                p = c1 + col_step .* (col-1);
                p = p + row_step .* (row-1);
                x_points(row, col) = p(1);
                y_points(row, col) = p(2);
            end
        end
        delta = 1;
        plot(x_points, y_points, 'r.');
        set([haccept, hreject], 'Enable', 'on',  'ForegroundColor', 'k')
    end

    function accept_Callback(source,eventdata) 
        set([haccept, hreject], 'Enable', 'inactive', 'ForegroundColor', [0.72, 0.72, 0.72])
        grid_positions(index).filename = image_files{index};
        grid_positions(index).x_points = x_points;
        grid_positions(index).y_points = y_points;
        index = index + 1;
        if delta
            save('results.mat', 'grid_positions')
            filename = grid_positions(index-1).filename;
            base_name = filename(1:end-3);
            x_file = strcat(base_name, '_x_coords.txt');
            y_file = strcat(base_name, '_y_coords.txt');
            output_y = y_points(1:numrows);
            output_x = x_points(1:numrows:end);
            step = mean(diff(output_x))/2;
            output_x = [output_x - step, output_x(end)+step];
            output_y = [output_y - step, output_y(end)+step];
            dlmwrite(x_file, output_x');
            dlmwrite(y_file, output_y');
        end
        update_display()
    end

    function reject_Callback(source,eventdata) 
        grid_positions(index).x_points = [];
        grid_positions(index).y_points = [];
        set([haccept, hreject], 'Enable', 'inactive', 'ForegroundColor', [0.72, 0.72, 0.72])
        update_display()
    end

    function goto_Callback(source, eventdata)
        warp_index = str2num(get(hgoto_index, 'String'));
        if not(isempty(warp_index)) && isreal(warp_index) && floor(warp_index) == warp_index && warp_index > 0 && warp_index <= total
            index = warp_index;
            update_display()
        else
            set(hgoto_index, 'String', 'Invalid Input')
        end
    end

    function empty_Callback(source, eventdata)
        warp_index = 1;
        while warp_index <= total && not(isempty(grid_positions(warp_index).x_points))
            warp_index = warp_index + 1;
        end
        if warp_index <= total
            index = warp_index;
            update_display()
        else
            set(hgoto_index, 'String', 'All of the pictures have data')
        end
    end
end 
