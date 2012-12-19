use GD;
use GD::Simple;
use POSIX qw(ceil floor);
use Data::Dumper;
use warnings;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
no warnings "recursion";
use strict;
use Math::Round qw/round/;


#parse input arguments
sub check_options {
    my $opts = shift;
    my ($inputPNG,$nClusters,$smoothRadius,$smoothMode,$colonyMinSize,$colonyMaxSize,$colonyNeighbors,$debugMode,$yGridOverrideFile,$xGridOverrideFile,$gridOverride);
	$inputPNG=$nClusters=$smoothRadius=$smoothMode=$colonyMinSize=$colonyMaxSize=$colonyNeighbors=$debugMode=$yGridOverrideFile=$xGridOverrideFile=$gridOverride="";
	
	if( exists($opts->{'inputPNG'}) ) {
		$inputPNG = $opts->{'inputPNG'};
    } else {
		help();
		exit;
    }
	if( exists($opts->{'nClusters'}) ) {
		$nClusters = $opts->{'nClusters'};
    } else {
		$nClusters=2;
    }
	if( exists($opts->{'smoothRadius'}) ) {
		$smoothRadius = $opts->{'smoothRadius'};
    } else {
		$smoothRadius=8;
    }
	if( exists($opts->{'smoothMode'}) ) {
		$smoothMode = $opts->{'smoothMode'};
		if(($smoothMode ne "avg") and ($smoothMode ne "med") and ($smoothMode ne "stdev") and ($smoothMode ne "min") and ($smoothMode ne "max") ) {
			print "invalid smoothMode ($smoothMode) ... setting to default (med)\n";
			$smoothMode="med";
		}		
    } else {
		$smoothMode="med";
	}
	if( exists($opts->{'colonyMinSize'}) ) {
		$colonyMinSize = $opts->{'colonyMinSize'};
    } else {
		$colonyMinSize=20;
    }
	if( exists($opts->{'colonyMaxSize'}) ) {
		$colonyMaxSize = $opts->{'colonyMaxSize'};
    } else {
		$colonyMaxSize=150;
    }
	if( exists($opts->{'colonyNeighbors'}) ) {
		$colonyNeighbors = $opts->{'colonyNeighbors'};
    } else {
		$colonyNeighbors=15;
    }
	if( exists($opts->{'debugMode'}) ) {
		$debugMode = $opts->{'debugMode'};
    } else {
		$debugMode=0;
    }
	
	$gridOverride=0;
	if( exists($opts->{'yGridOverrideFile'}) ) {
		$yGridOverrideFile = $opts->{'yGridOverrideFile'};
		$gridOverride=1;
    } else {
		$yGridOverrideFile="";
    }
	if( exists($opts->{'xGridOverrideFile'}) ) {
		$xGridOverrideFile = $opts->{'xGridOverrideFile'};
		if($gridOverride != 1) {
			print "error - must supply both a X and Y gridOverrideFile\n";
			exit;
		}
		$gridOverride=1;
    } else {
		$xGridOverrideFile="";
    }
	
	return($inputPNG,$nClusters,$smoothRadius,$smoothMode,$colonyMinSize,$colonyMaxSize,$colonyNeighbors,$debugMode,$yGridOverrideFile,$xGridOverrideFile,$gridOverride);
}

sub help() {
	
	print "\n";
	print "magicPlate.pl\n";
	print "\n";
	print "Input Parameters\n";
	print "-inputPNG\t\t-i\t\trequired\t\tThe PNG file name you wish you run magicPlate over.\n";
	print "\n";
	print "-nClusters\t\t-c\t\toptional\t2\tHow many clusters to detect during initial segmentation.\n";
	print "-smoothRadius\t\t-r\t\toptional\t4\tPixel radius by which to smooth over. A radius of 4 will smooth over 64 pixels.\n";
	print "-smoothMode\t\t-m\t\toptional\tmed\t(avg,med,stdev,min,max).  Which smoothing mode to use.\n";
	print "-colonyMinSize\t\t-min\t\toptional\t40\tMinimum pixel size for a detectable colony.\n";
	print "-colonyMinSize\t\t-max\t\toptional\t150\tMaximum pixel size for a detectable colony.\n";
	print "-colonyNeighbors\t-nhood\t\toptional\t18\tMinimum required neighbors of the same object within a 1 radius window around each pixel.\n";
	print "-debugMode\t\t-d\t\toptional\t0\t(0=off,1=on).  Debug Mode prints out all steps of the pipeline for debug purposes.\n";
	print "-xGridOverrideFile\t\t-xgo\t\toptional\t0\tA file to override the auto-grid.  Uses manual call.\n";
	print "-xGridOverrideFile\t\t-ygo\t\toptional\t0\tA file to override the auto-grid.  Uses manual call.\n";
	print "\n";
}
	
	
#This method will take in the two files that contain coordinates for the lines and return them.	
sub manualGridLines($$$$$){
	my ($x,$y,$height,$width);
	$x=$y=0;
	my $input_x = shift;
	my $input_y = shift;
	my $matrix={};
	$matrix=shift;
	$height=shift;
	$width=shift;
	open (XCOORD, $input_x) or die $!;
	open (YCOORD, $input_y) or die $!;

	my ($line,$i,$k,$j,$elementx,$elementy,@x_array,@y_array,%x_values,%y_values,$xcoords,$ycoords);
	$line=$i=$k=$j=$elementx,$elementy = 0;
		
		while($xcoords = <XCOORD>){                
			chomp($xcoords); 
			@x_array = split(/\n/, $xcoords);
			foreach $elementx (@x_array){
				$elementx = round($elementx);
				$x_values{$elementx} =$elementx;
			}

		}
	close (XCOORD);
		
		while($ycoords = <YCOORD>){                 
			chomp($ycoords); 
			@y_array = split(/\n/, $ycoords);
			foreach $elementy (@y_array){
				$elementy = round($elementy);
				$y_values{$elementy} =$elementy;
			}
		}
	close (YCOORD);

	#so now everything in %y_values & %x_values should be y,x coordinates of pixels that should be grid lines.
	#usually I pass in a color value (-1 or -2 or -3 etc) to set this spot to.
	my $color=-1; #cha
	
	# my ($y,$x);
	# for($y=0;$y<$height;$y++) {
		# for($x=0;$x<$width;$x++) {
			# my $value=$matrix->{$y}->{$x};
			# next if($value < 0);
			# if( (exists($y_values{$y})) or (exists($x_values{$x})) ) {  
				# is the Y coordinate we are at in the grid hashes? or the X coordinate?
				# if so, change the value inside of matrix to the color value.
				# other do nothing, and leave it alone
				# $matrix->{$y}->{$x}=$color;
			# }
		# }
	# }
	return(\%x_values,\%y_values);
}	
	
sub round($) {
    my $number = shift;
    return int($number + .5);
}


#turn a PNG file into a matrix
sub PNG2matrix($) {
	my ($png);
	$png=shift;
	
	my $image = GD::Image->newFromPng($png, 1); 
	my $width = $image->width;
	my $height = $image->height;

	my %matrix=();
	my ($x,$y);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $index = $image->getPixel($x, $y);
			my ($r,$g,$b) = $image->rgb($index);
			my $key=$r.",".$g.",".$b;
			
			$matrix{$y}{$x}=$key;
		}
	}
	
	return($height,$width,\%matrix);
}

sub smoothMatrix($$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$smoothRadius,$smoothMode);
	$height=shift;
	$width=shift;
	$smoothRadius=shift;
	$smoothMode=shift;
	
	my %temporaryMatrix=();
	my %smoothedMatrix=();
	my %colors=();
	
	my ($y,$x);
	
	my ($totalMeanR,$totalMeanG,$totalMeanB);
	$totalMeanR=$totalMeanG=$totalMeanB=0;
	
	#process X first
	for($y=0;$y<$height;$y++) {
		
		#initialize the data array for X=0;
		my (@smoothDataR,@smoothDataG,@smoothDataB);
		@smoothDataR=@smoothDataG=@smoothDataB=();

		my ($color,$xx);
		for($xx=0;$xx<=$smoothRadius;$xx++) {
			
			if(exists($matrix->{$y}->{$xx})) {
				$color=$matrix->{$y}->{$xx}; 
			} else { 
				$color=0; 
			}
			
			my ($red,$green,$blue)=split(/,/,$color);
			push(@smoothDataR,$red);
			push(@smoothDataG,$green);
			push(@smoothDataB,$blue);
		}
		#finish initializing
		
		
		for($x=0;$x<$width;$x++) {
			
			my ($smoothEnd);
			$smoothEnd=($x+$smoothRadius);
			$smoothEnd=($width-1) if($smoothEnd >= $width); #catch upper bound
			if(exists($matrix->{$y}->{$smoothEnd})) { $color=$matrix->{$y}->{$smoothEnd}; } else { $color=0; }
			my ($red,$green,$blue)=split(/,/,$color);
		
			#push a new value | only if we have new values left to push
			if($x < (($width-1)-$smoothRadius)) {
				push(@smoothDataR,$red); 
				push(@smoothDataG,$green);
				push(@smoothDataB,$blue);
			} 
			#remove a value from the end | only if data = (radius*2)+1
			if($x > $smoothRadius)  {
				shift(@smoothDataR);
				shift(@smoothDataG);
				shift(@smoothDataB);
			}
			
			my ($meanR,$stdevR,$medianR,$minR,$maxR)=listStats(\@smoothDataR);
			my ($meanG,$stdevG,$medianG,$minG,$maxG)=listStats(\@smoothDataG);
			my ($meanB,$stdevB,$medianB,$minB,$maxB)=listStats(\@smoothDataB);
			
			my $meanColor=round($meanR).",".round($meanG).",".round($meanB);
			my $stdevColor=round($stdevR).",".round($stdevG).",".round($stdevB);
			my $medianColor=round($medianR).",".round($medianG).",".round($medianB);
			my $minColor=round($minR).",".round($minG).",".round($minB);
			my $maxColor=round($maxR).",".round($maxG).",".round($maxB);
			
			$colors{'avg'}=$meanColor;
			$colors{'stdev'}=$stdevColor;
			$colors{'med'}=$medianColor;
			$colors{'min'}=$minColor;
			$colors{'max'}=$maxColor;
			
			$temporaryMatrix{$y}{$x}=$colors{$smoothMode};
		}
	}
	
	#now process Y
	for($x=0;$x<$width;$x++) {
		
		#initialize the data array for X=0;
		my (@smoothDataR,@smoothDataG,@smoothDataB);
		@smoothDataR=@smoothDataG=@smoothDataB=();

		my ($color,$yy);
		for($yy=0;$yy<=$smoothRadius;$yy++) {
			
			if(exists($temporaryMatrix{$yy}{$x})) { 
				$color=$temporaryMatrix{$yy}{$x}; 
			} else { 
				$color=0; 
			
			}
			my ($red,$green,$blue)=split(/,/,$color);
			push(@smoothDataR,$red);
			push(@smoothDataG,$green);
			push(@smoothDataB,$blue);
		}
		#finish initializing
		
		
		for($y=0;$y<$height;$y++) {
			
			my ($smoothEnd);
			$smoothEnd=($y+$smoothRadius);
			$smoothEnd=($height-1) if($smoothEnd >= $height); #catch upper bound
			
			if(exists($temporaryMatrix{$smoothEnd}{$x})) {
				$color=$temporaryMatrix{$smoothEnd}{$x}; 
			} else { 
				$color=0;
			}
			
			my ($red,$green,$blue)=split(/,/,$color);
		
			#push a new value | only if we have new values left to push
			if($y < (($height-1)-$smoothRadius)) {
				push(@smoothDataR,$red); 
				push(@smoothDataG,$green);
				push(@smoothDataB,$blue);
			} 
			#remove a value from the end | only if data = (radius*2)+1
			if($y > $smoothRadius)  {
				shift(@smoothDataR);
				shift(@smoothDataG);
				shift(@smoothDataB);
			}
			
			my ($meanR,$stdevR,$medianR,$minR,$maxR)=listStats(\@smoothDataR);
			my ($meanG,$stdevG,$medianG,$minG,$maxG)=listStats(\@smoothDataG);
			my ($meanB,$stdevB,$medianB,$minB,$maxB)=listStats(\@smoothDataB);
			
			my $meanColor=round($meanR).",".round($meanG).",".round($meanB);
			my $stdevColor=round($stdevR).",".round($stdevG).",".round($stdevB);
			my $medianColor=round($medianR).",".round($medianG).",".round($medianB);
			my $minColor=round($minR).",".round($minG).",".round($minB);
			my $maxColor=round($maxR).",".round($maxG).",".round($maxB);
			
			$colors{'avg'}=$meanColor;
			$colors{'stdev'}=$stdevColor;
			$colors{'med'}=$medianColor;
			$colors{'min'}=$minColor;
			$colors{'max'}=$maxColor;
			
			$totalMeanR += $meanR;
			$totalMeanG += $meanG;
			$totalMeanB += $meanB;
			
			$smoothedMatrix{$y}{$x}=$colors{$smoothMode};
		}
	}
	
	my $globalAverageR=round($totalMeanR/($width*$height));
	my $globalAverageG=round($totalMeanG/($width*$height));
	my $globalAverageB=round($totalMeanB/($width*$height));
	my $averageColor=$globalAverageR.",".$globalAverageG.",".$globalAverageB;
	
	return(\%smoothedMatrix,$averageColor);
}
	
sub subtractBG($$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$averageColor);
	$height=shift;
	$width=shift;
	my $smoothedMatrix={};
	$smoothedMatrix=shift;
	$averageColor=shift;
	
	my ($averageR,$averageG,$averageB);
	($averageR,$averageG,$averageB)=split(/,/,$averageColor);
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $origColor=$matrix->{$y}->{$x};
			my $smoothedColor=$smoothedMatrix->{$y}->{$x};
			
			my ($origR,$origG,$origB)=split(/,/,$origColor);
			my ($smoothedR,$smoothedG,$smoothedB)=split(/,/,$smoothedColor);
			
			my $factorR=($averageR/$smoothedR);
			my $factorG=($averageG/$smoothedG);
			my $factorB=($averageB/$smoothedB);
			
			my $adjustedR=round($origR*$factorR);
			my $adjustedG=round($origG*$factorG);
			my $adjustedB=round($origB*$factorB);
			
			#print "$averageR\t\t$origR\t$smoothedR\t$factorR\t$adjustedR\n";
			
			
			$adjustedR=0 if($adjustedR < 0);
			$adjustedG=0 if($adjustedG < 0);
			$adjustedB=0 if($adjustedB < 0);
			
			my $adjustedColor=$adjustedR.",".$adjustedG.",".$adjustedB;
			
			$smoothedMatrix->{$y}->{$x}=$adjustedColor;
		}
	}
	return($smoothedMatrix);
}

sub colorDiff($$) {
	my ($color1,$color2);
	$color1=shift;
	$color2=shift;
	
	my ($r1,$g1,$b1)=split(/,/,$color1);
	my ($r2,$g2,$b2)=split(/,/,$color2);
	
	my $diff=sqrt( (($r1-$r2)**2) + (($g1-$g2)**2) + (($b1-$b2)**2) );
	
	return($diff);
}	
	
	
sub matrix2channelArray($$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$color);
	$height=shift;
	$width=shift;
	$color=shift;

	my @list=();
	
	my ($y,$x,$l);
	$l=0;
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my ($red,$blue,$green)=split(/,/,$matrix->{$y}->{$x});
			
			my %colors=();
			$colors{'red'}=$red;
			$colors{'blue'}=$blue;
			$colors{'green'}=$green;
						
			$list[$l++]=$colors{$color};
		}
	}
	return(\@list);
}


sub kmeans($$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$k);
	$height=shift;
	$width=shift;
	$k=shift;
	
	my %kmeansMatrix=();
	my @centroids=();
	my ($i);
	
	for($i=0;$i<$k;$i++) {
		my ($rand_c,$rand_key);
		$rand_c=$rand_key="";
		my %usedCentroids=();
		while($rand_c eq "") {
			my $rand_y = int(rand($height-1));
			my $rand_x = int(rand($width-1));
			$rand_key = $rand_y . "." . $rand_x;
			if(defined($matrix->{$rand_y}->{$rand_x})) { 
				if(!exists($usedCentroids{$matrix->{$rand_y}->{$rand_x}})) {
					$rand_c = $matrix->{$rand_y}->{$rand_x};
					$usedCentroids{$rand_c}=1;
				}
			}
		}
		
		$centroids[$i]{"average"}=$rand_c;
		$centroids[$i]{"index"}=$rand_key;
		$centroids[$i]{"size"}=0;
		$centroids[$i]{"prevsize"}=1;
		$centroids[$i]{"members"}=();
	}
	my ($nIterations,$continue);
	$nIterations=0;
	$continue=1;
	
	while(($nIterations < 20) and ($continue == 1)) {
		my ($yi,$xi);
		for($yi=0;$yi<$height;$yi++) {
			for($xi=0;$xi<$width;$xi++) {
				my $key=$yi."x".$xi;
				
				my ($intensity);
				if(defined($matrix->{$yi}->{$xi})) { $intensity = $matrix->{$yi}->{$xi}; } else { $intensity = 0; }
				
				my ($i,$new_dist,$newCentroid,$min_dist);
				$new_dist=$newCentroid="";
				
				for($i=0;$i<$k;$i++) {
					my $val_dist=colorDiff($intensity,$centroids[$i]{"average"});
					if($newCentroid eq "") {
						$newCentroid=$i;
						$min_dist=$val_dist;
					} elsif($val_dist < $min_dist) {
						$newCentroid=$i;
						$min_dist=$val_dist;
					}
				}
				my $index=$centroids[$newCentroid]{"size"};
				$centroids[$newCentroid]{"members"}[$index]=$intensity;
				$centroids[$newCentroid]{"size"}++;
				$kmeansMatrix{$yi}{$xi}=$newCentroid;
			}
		}
		
		my ($i,$nConverged);
		$nConverged=0;
		for($i=0;$i<$k;$i++) {
			my $centroidSize=$centroids[$i]{"size"};
		
			if($centroids[$i]{"size"} == $centroids[$i]{"prevsize"}) { $nConverged++; }
			$centroids[$i]{"prevsize"}=$centroids[$i]{"size"};
						
			my ($i2);
			if($centroidSize > 0) {
				my ($total_r,$total_g,$total_b,$avg_r,$avg_g,$avg_b);
				$total_r=$total_g=$total_b=$avg_r=$avg_g=$avg_b=0;
				for($i2=0;$i2<$centroidSize;$i2++) {
					my $curCol=$centroids[$i]{"members"}[$i2];
					my ($r,$g,$b)=split(/,/,$curCol);
					$total_r += $r;
					$total_g += $g;
					$total_b += $b;
				}
				
				$avg_r=$total_r/$centroidSize;
				$avg_g=$total_g/$centroidSize;
				$avg_b=$total_b/$centroidSize;
			
				my $newCentroid=$avg_r.",".$avg_g.",".$avg_b;
				my $oldCentroid = $centroids[$i]{"average"};
				$centroids[$i]{"average"}=$newCentroid;
			}
			$centroids[$i]{"members"}=();
			$centroids[$i]{"size"}=0;
		}
		if($nConverged == $k) { $continue = 0; }
		$nIterations++;
	}
	return(\%kmeansMatrix,\@centroids);
}


sub matrix2PNG($$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$bg,$pngFile);
	$height=shift;
	$width=shift;
	$bg=shift;
	$pngFile=shift;
	
	my $img = GD::Simple->new($width,$height);
	my $black=$img->colorAllocate(0,0,0);
	my $white=$img->colorAllocate(255,255,255);
	my $red=$img->colorAllocate(255,0,0);
	my $green=$img->colorAllocate(0,255,0);
	my $blue=$img->colorAllocate(0,0,255);
	my $yellow=$img->colorAllocate(255,255,0);
	my $teal=$img->colorAllocate(0,255,255);
	my $purple=$img->colorAllocate(255,0,255);
	
	my ($y,$x,$color);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my ($val);
			if(exists($matrix->{$y}->{$x})) {
				$val = $matrix->{$y}->{$x};
			} else {
				$val = $bg;
			}
		
			if($val == $bg) { #background
				$color=$white;
			} elsif($val == -1) { #center
				$color=$red;
			} elsif($val == -2) { #centerGrid
				$color=$green;
			} elsif($val == -3) { #outerGrid
				$color=$blue;
			} elsif($val == -4) {
				$color=$yellow;
			} else { #colony
				$color=$black;
			}
			
			$img->setPixel($x,$y,$color);
		}
	}
	
	open(OUT,">".$pngFile);
	print OUT $img->png;
	close(OUT);
}

sub validNeighbor($$) {
	my $checkValue=shift;
	my $neighborValue=shift;
	
	return 0 if((!defined($checkValue)) or (!defined($neighborValue)));
	
	if($checkValue == $neighborValue) {
		return(1);
	} else {
		return(0);
	}
}

sub define_bound($$$$$$$$$$) {
	my $matrix={};
	$matrix=shift;
	my $objectMatrix={};
	$objectMatrix=shift;
	my $objects={};
	$objects=shift;
	my ($height,$width,$y,$x,$currentObject,$objectNumber);
	$height=shift;
	$width=shift;
	$y=shift;
	$x=shift;
	$currentObject=shift;
	$objectNumber=shift;
	
#	print "($x,$y) -> $currentObject | $matrix->{$y}->{$x}\n";
	
	if( (($y >= 0) and ($y < $height)) and (($x >= 0) and ($x < $width)) ) {
		if(!exists($objectMatrix->{$y}->{$x})) {
			if($matrix->{$y}->{$x} == $currentObject) {	
		
				$objectMatrix->{$y}->{$x}=$objectNumber;
				$objects->{$objectNumber}++;
				
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y+1,$x-1,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y+1,$x,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y+1,$x+1,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y,$x+1,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y-1,$x+1,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y-1,$x,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y-1,$x-1,$currentObject,$objectNumber);
				&define_bound($matrix,$objectMatrix,$objects,$height,$width,$y,$x-1,$currentObject,$objectNumber);
			}
		}
	}
}

sub findObjects($$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$nColors,$minNeighbors);
	$height=shift;
	$width=shift;

	my ($currentObject,$objectNumber);
	$objectNumber=0;
	
	my %objectMatrix=();
	my %objects=();
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			if(!exists($objectMatrix{$y}{$x})) {
				$currentObject=$matrix->{$y}->{$x};
				&define_bound($matrix,\%objectMatrix,\%objects,$height,$width,$y,$x,$currentObject,$objectNumber);
				$objectNumber++;
			}
		}
	}
	return(\%objectMatrix,\%objects);
	
}

sub matrix2TXT($$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$nColors,$outFile);
	$height=shift;
	$width=shift;
	$outFile=shift;
	
	open(OUT,">".$outFile);
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my ($value);
			if(exists($matrix->{$y}->{$x})) { $value=$matrix->{$y}->{$x}; } else { $value=0; }
			print OUT $value;
			
			if($x != ($width-1)) { 
				print OUT "\t";
			}
		}
		if($y != ($height)) {
			print OUT "\n";
		} 
	}
	
	close(OUT);
}

	
sub cleanObjects($$$) {
	my $objects={};
	$objects=shift;
	my ($min,$max);
	$min=shift;
	$max=shift;
	
	my %cleanObjects;
	
	my ($key);
	foreach $key ( keys %$objects ) {
		my $value=$objects->{$key};		
		if(($value >= $min) and ($value <= $max)) {
			$cleanObjects{$key}=$value;
		}
	}
	
	return(\%cleanObjects);
}

sub cleanMatrix($$$$$) {
	my $cleanObjects={};
	$cleanObjects=shift;
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$bg);
	$height=shift;
	$width=shift;
	$bg=shift;
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $value=$matrix->{$y}->{$x};
			if(!exists($cleanObjects->{$value})) {
				$matrix->{$y}->{$x}=$bg;
			}
		}
	}
	return($matrix);
}

sub requireNeighbors($$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$minNeighbors,$bg);
	$height=shift;
	$width=shift;
	$minNeighbors=shift;
	$bg=shift;
	
	my %newMatrix=();
	my %objectSizes=();
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $currentObject=$matrix->{$y}->{$x};
					
			my $n_neighbors=0;
			my ($y2,$x2);
			for($y2=-2;$y2<=2;$y2++) {
				for($x2=-2;$x2<=2;$x2++) {
					$n_neighbors += validNeighbor($currentObject,$matrix->{$y+$y2}->{$x+$x2});
				}
			}
			
			if($n_neighbors < $minNeighbors) {
				$newMatrix{$y}{$x}=$bg;
			} else {
				$newMatrix{$y}{$x}=$currentObject;
				$objectSizes{$currentObject}++;
			}
		}
	}
	return(\%objectSizes,\%newMatrix);
}


sub matrix2centers($$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$bg);
	$height=shift;
	$width=shift;
	$bg=shift;
	
	my %centers=();
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $currentObject=$matrix->{$y}->{$x};
			
			next if($currentObject == $bg); 
			
			$centers{$currentObject}{'count'}++;
			$centers{$currentObject}{'ysum'} += $y;
			$centers{$currentObject}{'xsum'} += $x;
		}
	}
	
	my ($key);
	foreach $key (keys %centers) {
		my $xsum=$centers{$key}{'xsum'};
		my $ysum=$centers{$key}{'ysum'};
		my $count=$centers{$key}{'count'};
		
		my $center_y=round($centers{$key}{'ysum'} / $centers{$key}{'count'});
		my $center_x=round($centers{$key}{'xsum'} / $centers{$key}{'count'});
		
		$centers{$key}{'ycenter'}=$center_y;
		$centers{$key}{'xcenter'}=$center_x;
	} 
	
	return(\%centers);

}


sub overlayCenters($$) {
	my $matrix={};
	$matrix=shift;
	my $centers={};
	$centers=shift;
	
	my ($key);
	foreach $key (keys %$centers) {
		my $center_y=$centers->{$key}->{'ycenter'};
		my $center_x=$centers->{$key}->{'xcenter'};
		
		$matrix->{$center_y}->{$center_x}=-1;
	} 
	
	return($matrix);
}

sub centers2array($) {
	my $centers={};
	$centers=shift;
	
	my (@yCenters,@xCenters);
	@yCenters=@xCenters=();
	my ($yInc,$xInc);
	$yInc=$xInc=0;
	
	my ($key);
	foreach $key (keys %$centers) {
		my $center_y=$centers->{$key}->{'ycenter'};
		my $center_x=$centers->{$key}->{'xcenter'};
		
		$yCenters[$yInc++]=$center_y;
		$xCenters[$xInc++]=$center_x;
	} 
	
	return(\@yCenters,\@xCenters);
	
}

sub listStats($) {
	my $list=shift;
	
	my $size=@$list;
	my ($mean,$stdev,$median,$min,$max);
	$mean=$stdev=$median=$min=$max=0;
	
	if($size > 0) {
		my @copy=@$list;
		@copy = sort { $a <=> $b } @copy;
		
		$min=$copy[0];
		$max=$copy[@copy-1];
		
		my ($total,$avg);
		$total=$avg=0;
		my $i=0;
		
		for($i=0;$i<$size;$i++) {
			my $val=$copy[$i];
			$total=$total+$val;
		}
		$mean=$total/$size;
		
		my $total_deviation=0;
		for($i=0;$i<$size;$i++) {
			my $val=$copy[$i];
			my $deviation=$val-$mean;
			my $sqr_deviation=$deviation**2;
			$total_deviation=$total_deviation+$sqr_deviation;
		}
		if($size > 1) {
			$stdev=$total_deviation/($size-1);
			$stdev=sqrt($stdev);
		}
			
		if(($size % 2) == 1) {
			my $middle = floor($size / 2);
			$median = $copy[$middle];
		} else {
			my $middlel = floor($size / 2) - 1;
			my $middler = $middlel + 1;		
			my $medianl = $copy[$middlel];
			my $medianr = $copy[$middler];
			$median = round((($medianl + $medianr) / 2));			
		}
	}
	
	return($mean,$stdev,$median,$min,$max);
}

sub discoverCenterLines($$) {
	my $list=();
	$list=shift;
	my $groups=shift;
	
	my %orig=();
	my ($nClusters);
	$nClusters=0;

	my $listSize=@$list;
	my ($i);
	for($i=0;$i<$listSize;$i++) {
		my $value = @$list[$i];
		$orig{$nClusters}{'size'}=1;
		$orig{$nClusters}{'average'}=$value;
		$orig{$nClusters}{'members'}[0]=$value;
		$nClusters++;
	}

	my %clusters=();
	%clusters=%orig;

	my $finalClusters=$nClusters;

	my ($cluster1Value,$cluster2Value,$diff,$minDiff,$toJoin,$step);
	$minDiff=$diff=-1;
	$cluster1Value=$cluster2Value=$step=0;
	$toJoin="";

	my ($key1,$key2,$join1,$join2);
	while($finalClusters != 1) {
		last if($finalClusters == $groups);
		$minDiff=-1;
		foreach $key1 ( keys %clusters ) {
			$cluster1Value=$clusters{$key1}{'average'};
			foreach $key2 (keys %clusters ) {
				next if($key1 eq $key2);
				$cluster2Value=$clusters{$key2}{'average'};	
				$diff=abs($cluster1Value-$cluster2Value);
				if($minDiff == -1) { 
					$minDiff=$diff;
					$toJoin=$key1.".".$key2;
					$join1=$key1;
					$join2=$key2;
					goto SKIP if($minDiff == 0);
				} elsif($diff < $minDiff) {
					$minDiff=$diff;
					$toJoin=$key1.".".$key2;
					$join1=$key1;
					$join2=$key2;
					goto SKIP if($minDiff == 0);
				}
			}
		}
		SKIP:
		
		delete($clusters{$join1});
		delete($clusters{$join2});
		
		my @subClusters=split(/\./,$toJoin);
		my $numSubClusters=@subClusters;
		
		my ($total,$size);
		$total=$size=0;
			
		my ($i);
		for($i=0;$i<$numSubClusters;$i++) {
			
			my $key=$subClusters[$i];		
			my $subSize=$orig{$key}{'size'};

			my ($ii);
			for($ii=0;$ii<$subSize;$ii++) {
				$total += $orig{$key}{'members'}[$ii];
			}
			
			$size += $subSize;
			push(@{$clusters{$toJoin}{'members'}},@{$orig{$key}{'members'}});
			delete($clusters{$key});
		}
		
		my $mergedAverage=($total/$size);
		
		$clusters{$toJoin}{'size'} += $size;
		$clusters{$toJoin}{'average'}=$mergedAverage;
		
		$step++;
		$finalClusters--;
	}

	my %centers=();
	foreach my $key( keys %clusters ) {
		my $size=$clusters{$key}{'size'};
		my $average=$clusters{$key}{'average'};
		
		my ($mean,$stdev,$median,$min,$max);
		($mean,$stdev,$median,$min,$max)=listStats($clusters{$key}{'members'});
		$centers{$median}=$median;
	}
	return(\%centers);
}

sub overlayLine($$$$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($height,$width,$bg,$color);
	$height=shift;
	$width=shift;
	$bg=shift;
	my $yLine={};
	$yLine=shift;
	my $xLine={};
	$xLine=shift;
	$color=shift;
	
	my ($y,$x);
	for($y=0;$y<$height;$y++) {
		for($x=0;$x<$width;$x++) {
			my $value=$matrix->{$y}->{$x};
			next if($value < 0);
			if( (exists($yLine->{$y})) or (exists($xLine->{$x})) ) {
				$matrix->{$y}->{$x}=$color;
			}
		}
	}
	return($matrix);
}

sub hash2array($) {
	my $hash={};
	$hash=shift;
	
	my @array=();
	my $aInc=0;
	
	my ($key);
	foreach $key ( sort {$a<=>$b} keys %$hash) {
		my $value=$hash->{$key};
		$array[$aInc++]=$value;
	}
	
	return(\@array);
}
	
sub center2outer($$) {
	my $centers={};
	$centers=shift;
	my ($imageBound);
	$imageBound=shift;
	
	
	my @steps=();
	my ($key,$lastKey,$step,$total,$nCenters);
	$lastKey="";
	$step=$total=$nCenters=0;
	foreach $key ( sort {$a<=>$b} keys %$centers) {
		if($lastKey eq "") {
			$lastKey=$key;
		} else {
			$step=($key-$lastKey);
			$lastKey=$key;
		}
		$steps[$nCenters++]=$step;
	}
	my ($mean,$stdev,$median,$min,$max);
	($mean,$stdev,$median,$min,$max)=listStats(\@steps);
	my $halfCenterDistance=round($median/2);
	
	my %outerGrid=();
	
	my ($gridLine_L,$gridLine_R,$currentDistance,$centerLine);
	
	my $centersArr=();
	$centersArr=hash2array($centers);
	my $centersArrSize=@$centersArr;
	
	my ($i);
	for($i=0;$i<$centersArrSize;$i++) {
		my $centerLine=@$centersArr[$i];
		if($i == 0) {
			$gridLine_L=$centerLine-$halfCenterDistance;
			if($gridLine_L <= 0) { $gridLine_L=0; }
			$outerGrid{$gridLine_L}=$gridLine_L;
		} else {
			$currentDistance=round((@$centersArr[$i]-@$centersArr[$i-1])/2);
			$gridLine_L=$centerLine-$currentDistance;
			$outerGrid{$gridLine_L}=$gridLine_L;
		} 
		if($i == ($centersArrSize-1)) {
			$gridLine_R=$centerLine+$halfCenterDistance;
			if($gridLine_R >= $imageBound) { $gridLine_R=$imageBound; }
			$outerGrid{$gridLine_R}=$gridLine_R;
		}
	}
	
	return(\%outerGrid);
}

sub findBoundaries($$) {
	my $yGrid={};
	$yGrid=shift;
	my $xGrid={};
	$xGrid=shift;
	#print Dumper($xGrid);
	my $yGridArr=();
	$yGridArr=hash2array($yGrid);
	my $yGridArrSize=@$yGridArr;
	
	my %yColonyBoundary=();
	my ($y);
	for($y=0;$y<($yGridArrSize-1);$y++) {
		my $start = (@$yGridArr[$y]+1);
		my $end = (@$yGridArr[$y+1]-1);
		$yColonyBoundary{$y}{'start'}=$start;
		$yColonyBoundary{$y}{'end'}=$end;
	}
	
	my $xGridArr=();
	$xGridArr=hash2array($xGrid);
	my $xGridArrSize=@$xGridArr;
	
	my %xColonyBoundary=();
	my ($x);
	for($x=0;$x<($xGridArrSize-1);$x++) {
		my $start = (@$xGridArr[$x]+1);
		my $end = (@$xGridArr[$x+1]-1);
		$xColonyBoundary{$x}{'start'}=$start;
		$xColonyBoundary{$x}{'end'}=$end;
	}
	
	return(\%yColonyBoundary,\%xColonyBoundary);
	
}
sub euclidianDistance($$$$) {
	my ($x1,$x2,$y1,$y2);
	$x1=shift;
	$y1=shift;
	$x2=shift;
	$y2=shift;
	
	my $distance=sqrt( (($x2-$x1)**2) + (($y2-$y1)**2) );
	
	return($distance);
}

	
	
sub processSubColony($$$$$$) {
	my $matrix={};
	$matrix=shift;
	my ($rows,$cols);
	$rows=shift;
	$cols=shift;
	my $rowBoundary={};
	$rowBoundary=shift;
	my $colBoundary={};
	$colBoundary=shift;
	my $finalMatrix={};
	$finalMatrix=shift;
	my %colonyData=();
	
	my ($rowStart,$rowEnd,$colStart,$colEnd);
	my ($r,$c);
	for($r=0;$r<$rows;$r++) {
		$rowStart=$rowBoundary->{$r}->{'start'};
		$rowEnd=$rowBoundary->{$r}->{'end'};
		for($c=0;$c<$cols;$c++) {
			$colStart=$colBoundary->{$c}->{'start'};
			$colEnd=$colBoundary->{$c}->{'end'};
			
			my %subMatrix=();
			my ($total_r,$total_g,$total_b);
			$total_r=$total_g=$total_b=0;
			my ($rr,$cc);
			#print"row start:$colStart\trow end:$colEnd\n";
			for($rr=$rowStart;$rr<=$rowEnd;$rr++) {
				for($cc=$colStart;$cc<=$colEnd;$cc++) {
					$subMatrix{($rr-$rowStart)}{($cc-$colStart)}=$matrix->{$rr}->{$cc};
					my $color=$matrix->{$rr}->{$cc};
				}
			}
			my $kmeansMatrix={};
			my $kmeansCentroids=();
			
			my $height=(($rowEnd-$rowStart)+1);
			my $width=(($colEnd-$colStart)+1);
			my $expectedSize=$height*$width;
			($kmeansMatrix,$kmeansCentroids)=kmeans(\%subMatrix,$height,$width,2);
			
			my $nCentroids=@$kmeansCentroids;
			
			my %clusterColor=();
			my ($i,$totalSize);
			$totalSize=0;
			for($i=0;$i<$nCentroids;$i++) {
				my $average=@$kmeansCentroids[$i]->{'average'};
				my ($red,$green,$blue)=split(/,/,$average);
				my $totalColor=$red+$green+$blue;
				$clusterColor{$i}=$totalColor;
				
				my $size=@$kmeansCentroids[$i]->{'prevsize'};
				$totalSize += $size;
			}
		
			my %dist2center=();
			my $subCenterY=($height/2);
			my $subCenterX=($width/2);
			
			for($rr=$rowStart;$rr<=$rowEnd;$rr++) {
				for($cc=$colStart;$cc<=$colEnd;$cc++) {
					my $cluster=$kmeansMatrix->{($rr-$rowStart)}->{($cc-$colStart)};
					my $ccProjected=($cc-$colStart);
					my $rrProjected=($rr-$rowStart);
					
					my $distance=euclidianDistance($ccProjected,$rrProjected,$subCenterX,$subCenterY);
					$dist2center{$cluster}{'total'} += $distance;
					$dist2center{$cluster}{'count'}++;
				}
			}
			my ($key);
			foreach $key (keys %dist2center) {
				$dist2center{$key}{'average'}=$dist2center{$key}{'total'}/$dist2center{$key}{'count'};
			}
			
			my (@colonyDataR,@colonyDataG,@colonyDataB,@allDataR,@allDataG,@allDataB);
			@colonyDataR=@colonyDataG=@colonyDataB=@allDataR=@allDataG=@allDataB=();
			
			my $colonyCluster = (sort { $dist2center{$a}{'average'} <=> $dist2center{$b}{'average'} } keys %dist2center)[0];
			my $colonySize=@$kmeansCentroids[$colonyCluster]->{"prevsize"};

			for($rr=$rowStart;$rr<=$rowEnd;$rr++) {
				for($cc=$colStart;$cc<=$colEnd;$cc++) {
					my $cluster=$kmeansMatrix->{($rr-$rowStart)}->{($cc-$colStart)};
					my $color=$matrix->{$rr}->{$cc};
						#print "found valid colony ($cluster) @ ($cc,$rr) -> $color\n";
						my ($red,$green,$blue)=split(/,/,$color);
						
						$red=255-$red;
						$green=255-$green;
						$blue=255-$blue;
						
					if($cluster == $colonyCluster) {
						push(@colonyDataR,$red);
						push(@colonyDataG,$green);
						push(@colonyDataB,$blue);
						$finalMatrix->{$rr}->{$cc}=1;
					} else {
						$finalMatrix->{$rr}->{$cc}=0;
					}
					push(@allDataR,$red);
					push(@allDataG,$green);
					push(@allDataB,$blue);
				}
			}
			
			#colony size 
			$colonyData{'size'}{$r}{$c}=$colonySize;
					
			#stats per pixels within colony.
			my ($colonyMeanR,$colonyStdevR,$colonyMedianR,$colonyMinR,$colonMaxR)=listStats(\@colonyDataR);
			my ($colonyMeanG,$colonyStdevG,$colonyMedianG,$colonyMinG,$colonMaxG)=listStats(\@colonyDataG);
			my ($colonyMeanB,$colonyStdevB,$colonyMedianB,$colonyMinB,$colonMaxB)=listStats(\@colonyDataB);
			$colonyData{'red'}{'mean'}{'colony'}{$r}{$c}=$colonyMeanR;
			$colonyData{'red'}{'stdev'}{'colony'}{$r}{$c}=$colonyStdevR;
			$colonyData{'red'}{'median'}{'colony'}{$r}{$c}=$colonyMedianR;
			$colonyData{'green'}{'mean'}{'colony'}{$r}{$c}=$colonyMeanG;
			$colonyData{'green'}{'stdev'}{'colony'}{$r}{$c}=$colonyStdevG;
			$colonyData{'green'}{'median'}{'colony'}{$r}{$c}=$colonyMedianG;
			$colonyData{'blue'}{'mean'}{'colony'}{$r}{$c}=$colonyMeanB;
			$colonyData{'blue'}{'stdev'}{'colony'}{$r}{$c}=$colonyStdevB;
			$colonyData{'blue'}{'median'}{'colony'}{$r}{$c}=$colonyMedianB;
			
			#stats per all pixels within grid box.
			my ($allMeanR,$allStdevR,$allMedianR,$allMinR,$allMaxR)=listStats(\@allDataR);
			my ($allMeanG,$allStdevG,$allMedianG,$allMinG,$allMaxG)=listStats(\@allDataG);
			my ($allMeanB,$allStdevB,$allMedianB,$allMinB,$allMaxB)=listStats(\@allDataB);
			$colonyData{'red'}{'mean'}{'all'}{$r}{$c}=$allMeanR;
			$colonyData{'red'}{'stdev'}{'all'}{$r}{$c}=$allStdevR;
			$colonyData{'red'}{'median'}{'all'}{$r}{$c}=$allMedianR;
			$colonyData{'green'}{'mean'}{'all'}{$r}{$c}=$allMeanG;
			$colonyData{'green'}{'stdev'}{'all'}{$r}{$c}=$allStdevG;
			$colonyData{'green'}{'median'}{'all'}{$r}{$c}=$allMedianG;
			$colonyData{'blue'}{'mean'}{'all'}{$r}{$c}=$allMeanB;
			$colonyData{'blue'}{'stdev'}{'all'}{$r}{$c}=$allStdevB;
			$colonyData{'blue'}{'median'}{'all'}{$r}{$c}=$allMedianB;
		}
	}
	return(\%colonyData,$finalMatrix);
}


	
#

my %options;

my $results = GetOptions( \%options,'inputPNG|i=s','nClusters|k=s','smoothRadius|r=s','smoothMode|m=s','colonyMinSize|min=s','colonyMaxSize|max=s','colonyNeighbors|nhood=s','debugMode|d=s','xGridOverrideFile|xgo=s','yGridOverrideFile|ygo=s');
my ($inputPNG,$nClusters,$smoothRadius,$smoothMode,$colonyMinSize,$colonyMaxSize,$colonyNeighbors,$debugMode,$xGridOverrideFile,$yGridOverrideFile,$gridOverride);
($inputPNG,$nClusters,$smoothRadius,$smoothMode,$colonyMinSize,$colonyMaxSize,$colonyNeighbors,$debugMode,$xGridOverrideFile,$yGridOverrideFile,$gridOverride)=check_options( \%options );

print "\n";
print "magicPlate.pl\n";
print "\n";
print "inputPNG\t$inputPNG\n";
print "nClusters\t$nClusters\n";
print "smoothRadius\t$smoothRadius\n";
print "smoothMode\t$smoothMode\n";
print "colonyMinSize\t$colonyMinSize\n";
print "colonyMaxSize\t$colonyMaxSize\n";
print "colonyNeighbors\t$colonyNeighbors\n";
print "debugMode\t$debugMode\n";
print "xGridOverrideFile\t$xGridOverrideFile\n";
print "yGridOverrideFile\t$yGridOverrideFile\n";
print "gridOverride\t$gridOverride\n";
print "\n";
print "\n";
my @tmp = split(/\//,$inputPNG);
my $inputPNGName=$tmp[@tmp-1];

my $fullPath=$inputPNG;
$fullPath =~ s/\/$inputPNGName//;

#setup debug directory
my $debugName = $inputPNGName;
$debugName =~ s/.png$//;
my $debugFolder = $debugName;
$debugFolder .= "_DEBUG";
my $debugPath = $fullPath."/".$debugFolder;
system("mkdir -p $debugPath");
$debugPath = $debugPath."/".$debugName;


#read the PNG image in
print "reading in input image...\n";
my $matrix={};
my ($height,$width);
($height,$width,$matrix)=PNG2matrix($inputPNG);
matrix2TXT($matrix,$height,$width,$debugPath.".orig.txt") if($debugMode == 1);

#globals#
#move everything inside this if statement with a (my) up here.
#right now they are all out of scope.
#globals#
my $centerLineMatrix={};
my $backgroundClusterNumber = 0;
my $yOuterLine={};
my $xOuterLine={};
#use auto-grid to calculate grid lines
if($gridOverride == 0) {

	# correct image for any background biases
	#smooth the image using the smoothRadius + smoothMode options to model the local noise
	print "smoothing the data using radius=$smoothRadius mode=$smoothMode...\n";
	my $smoothedMatrix={};
	my ($averageColor);
	($smoothedMatrix,$averageColor)=smoothMatrix($matrix,$height,$width,$smoothRadius,$smoothMode);
	matrix2TXT($smoothedMatrix,$height,$width,$debugPath.".smoothed.txt") if($debugMode == 1);

	#subtract the smoothed values from the original values
	print "correcting the original image...\n";
	my $correctedMatrix={};
	$correctedMatrix=subtractBG($matrix,$height,$width,$smoothedMatrix,$averageColor);
	matrix2TXT($correctedMatrix,$height,$width,$debugPath.".corrected.txt") if($debugMode == 1);

	print "running kmeans on corrected matrix...\n";
	#run KMEANS over image to seperate colony/background
	my $kmeansMatrix={};
	my $kmeansCentroids=();
	($kmeansMatrix,$kmeansCentroids)=kmeans($correctedMatrix,$height,$width,$nClusters);
	#convert matrix to TXT file
	matrix2PNG($kmeansMatrix,$height,$width,0,$debugPath.".kmeans.png") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2TXT($kmeansMatrix,$height,$width,$debugPath.".kmeans.txt") if($debugMode == 1);

	#try to classify non-joined objects
	#print "searching for distinct objects...\n";
	my ($objectMatrix,$objects);
	$objectMatrix=$objects={};
	($objectMatrix,$objects)=findObjects($kmeansMatrix,$height,$width);
	my $nObjects=keys %$objects;
	print "\tfound $nObjects distinct objects...\n";
	#assume the background object will be the object covering the most space
	$backgroundClusterNumber = (sort { $objects->{$b} <=> $objects->{$a} } keys %$objects)[0];
	print "\tusing object # $backgroundClusterNumber as background...\n";
	delete($objects->{$backgroundClusterNumber});
	#convert matrix to TXT file
	matrix2PNG($objectMatrix,$height,$width,$backgroundClusterNumber,$debugPath.".object.png") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2TXT($objectMatrix,$height,$width,$debugPath.".object.txt") if($debugMode == 1);

	print "running step 1 noise removal...\n";
	#filter the KMEANS matrix by removing all pixels not having at least N neighbors in a 2pixel radius.
	my $cleanMatrix1={};
	my $objectSizes={};
	($objectSizes,$cleanMatrix1)=requireNeighbors($objectMatrix,$height,$width,$colonyNeighbors,$backgroundClusterNumber);
	#convert matrix to TXT file
	matrix2TXT($cleanMatrix1,$height,$width,$debugPath.".clean.step1.txt") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2PNG($cleanMatrix1,$height,$width,$backgroundClusterNumber,$debugPath.".clean.step1.png") if($debugMode == 1);

	print "running step 2 noise removal...\n";
	#impose a size requirement on all objects.  classify all objects < min and > max size allowed.
	my $cleanObjects={};
	$cleanObjects=cleanObjects($objectSizes,$colonyMinSize,$colonyMaxSize);
	my $nFilteredObjects=keys %$cleanObjects;
	print "\t$nFilteredObjects filtered objects remaining...\n";

	print "cleaning up input matrix...\n";
	#now remove all objects found from the cleanObjects step.
	my $cleanMatrix2={};
	$cleanMatrix2=cleanMatrix($cleanObjects,$cleanMatrix1,$height,$width,$backgroundClusterNumber);
	#convert matrix to TXT file
	matrix2TXT($cleanMatrix2,$height,$width,$debugPath.".clean.step2.txt") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2PNG($cleanMatrix2,$height,$width,$backgroundClusterNumber,$debugPath.".clean.step2.png") if($debugMode == 1);

	#die if too many, too few
	if(($nFilteredObjects < 750) or ($nFilteredObjects > 1800)) {
		print "\t************\ttoo few | too many objects detected. ($nFilteredObjects)\n\n\n";
		exit;
	}
	#die if too many, too few

	print "calculating centers of all objects...\n";
	#find all centers of non background objects.
	my $centers={};
	$centers=matrix2centers($cleanMatrix2,$height,$width,$backgroundClusterNumber);

	print "applying centers to input matrix...\n";
	#apply centers to a matrix
	my $centerMatrix={};
	$centerMatrix=overlayCenters($cleanMatrix2,$centers);
	#convert matrix to TXT file
	matrix2TXT($centerMatrix,$height,$width,$debugPath.".clean.centers.txt") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2PNG($centerMatrix,$height,$width,$backgroundClusterNumber,$debugPath.".clean.centers.png") if($debugMode == 1);

	#print "clustering centers into row/col...\n";
	my $yCenters=();
	my $xCenters=();
	($yCenters,$xCenters)=centers2array($centers);
	my $yCenterLine={};
	 #print Dumper($yCenters);
	 #print Dumper($xCenters);
	$yCenterLine=discoverCenterLines($yCenters,32);
	my $xCenterLine={};
	
	$xCenterLine=discoverCenterLines($xCenters,48);

	print "overlaying center line on input matrix...\n";
	
	$centerLineMatrix=overlayLine($centerMatrix,$height,$width,$backgroundClusterNumber,$yCenterLine,$xCenterLine,-2);
	#convert matrix to TXT file
	matrix2TXT($centerLineMatrix,$height,$width,$debugPath.".clean.centers.lines.txt") if($debugMode == 1);
	#convert matrix to PNG image
	matrix2PNG($centerLineMatrix,$height,$width,$backgroundClusterNumber,$debugPath.".clean.centers.lines.png") if($debugMode == 1);


	#print "calculating outer grid lines from center lines...\n";
	
	$yOuterLine=center2outer($yCenterLine,$height);
	#print Dumper($yOuterLine);

	$xOuterLine=center2outer($xCenterLine,$width);
	#print Dumper($xOuterLine);
} else { #supply manual grid line calls
	
	#put stuff here to process the 2 files you included
	($yOuterLine,$xOuterLine)=manualGridLines($xGridOverrideFile,$yGridOverrideFile,$matrix,$height,$width);
	#1. call some function to read in files
		#return 1 hash per file.
		#should be same structure as if this was done using the auto-grid code
		#needs to be calls $yOuterLine and $xOuterLine
}



print "calculating coordinates of each grid box..\n";
my $yColonyBoundary={};
my $xColonyBoundary={};
($yColonyBoundary,$xColonyBoundary)=findBoundaries($yOuterLine,$xOuterLine);

print "calculating data for each sub colony per grid box...\n";
my $colonyData={};
my $finalMatrix={};
($colonyData,$finalMatrix)=processSubColony($matrix,32,48,$yColonyBoundary,$xColonyBoundary,$centerLineMatrix);
#convert matrix to TXT file
matrix2TXT($finalMatrix,$height,$width,$debugPath.".clean.centers.lines.outer.final.txt") if($debugMode == 1);
#convert matrix to PNG image
matrix2PNG($finalMatrix,$height,$width,0,$inputPNG.".clean.centers.lines.outer.final.png");
#convert matrix to TXT file

#setup debug directory
my $dataName = $inputPNGName;
$dataName =~ s/.png$//;
my $dataFolder = $dataName;
$dataFolder .= "_DATA";
my $dataPath=$fullPath."/".$dataFolder;
system("mkdir -p $dataPath");
$dataPath = $dataPath."/".$dataName;

print "printing final colony size per grid box...\n";
matrix2TXT($colonyData->{'size'},32,48,$dataPath.".size.txt");

print "printing all final 'colony' data...\n";
#print all values of pixels of a detectable colony
matrix2TXT($colonyData->{'blue'}->{'mean'}->{'colony'},32,48,$dataPath.".blue.mean.colony.txt");
matrix2TXT($colonyData->{'blue'}->{'stdev'}->{'colony'},32,48,$dataPath.".blue.stdev.colony.txt");
matrix2TXT($colonyData->{'blue'}->{'median'}->{'colony'},32,48,$dataPath.".blue.median.colony.txt");
matrix2TXT($colonyData->{'red'}->{'mean'}->{'colony'},32,48,$dataPath.".red.mean.colony.txt");
matrix2TXT($colonyData->{'red'}->{'stdev'}->{'colony'},32,48,$dataPath.".red.stdev.colony.txt");
matrix2TXT($colonyData->{'red'}->{'median'}->{'colony'},32,48,$dataPath.".red.median.colony.txt");
matrix2TXT($colonyData->{'green'}->{'mean'}->{'colony'},32,48,$dataPath.".green.mean.colony.txt");
matrix2TXT($colonyData->{'green'}->{'stdev'}->{'colony'},32,48,$dataPath.".green.stdev.colony.txt");
matrix2TXT($colonyData->{'green'}->{'median'}->{'colony'},32,48,$dataPath.".green.median.colony.txt");

print "printing all final 'box' data...\n";
#print all values of the entire 'box'
matrix2TXT($colonyData->{'blue'}->{'mean'}->{'all'},32,48,$dataPath.".blue.mean.all.txt");
matrix2TXT($colonyData->{'blue'}->{'stdev'}->{'all'},32,48,$dataPath.".blue.stdev.all.txt");
matrix2TXT($colonyData->{'blue'}->{'median'}->{'all'},32,48,$dataPath.".blue.median.all.txt");
matrix2TXT($colonyData->{'red'}->{'mean'}->{'all'},32,48,$dataPath.".red.mean.all.txt");
matrix2TXT($colonyData->{'red'}->{'stdev'}->{'all'},32,48,$dataPath.".red.stdev.all.txt");
matrix2TXT($colonyData->{'red'}->{'median'}->{'all'},32,48,$dataPath.".red.median.all.txt");
matrix2TXT($colonyData->{'green'}->{'mean'}->{'all'},32,48,$dataPath.".green.mean.all.txt");
matrix2TXT($colonyData->{'green'}->{'stdev'}->{'all'},32,48,$dataPath.".green.stdev.all.txt");
matrix2TXT($colonyData->{'green'}->{'median'}->{'all'},32,48,$dataPath.".green.median.all.txt");

print "done.\n\n";
