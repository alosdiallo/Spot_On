use strict;
use English;

my %hash=();

my @initialImages = <*>;
foreach my $file (@initialImages) {
	if(($file =~ /.JPG/) and ($file !~ /.cropped./g)) {
		print "processing $file...\n";
		my @tmp=split(/\./,$file);
		my $name="";
		for(my $i=0;$i<(@tmp-1);$i++) {
			if($name eq "") { $name = $tmp[$i]; } else { $name=$name.".".$tmp[$i]; }
		}
		my $exten=$tmp[(@tmp-1)];
		
		my $orig=$name.".".$exten;
		my $cropped=$name.".cropped.".$exten;
		my $resized=$name.".cropped.resized.".$exten;
		my $greyscale=$name.".cropped.resized.grey.".$exten;
		my $png=$name.".cropped.resized.grey.png";
			
		#crop out the border
		print "\tcropping image...\n";
		system("convert ".$orig." -crop 4100x2750+520+365 +repage ".$cropped);
		
		#resize it to 25%
		print "\tresizing to 25%...\n";
		system("convert ".$cropped." -resize 25% ".$resized);
		
		#jpg -> png
		print "\tconverting to PNG...\n";
		system("convert ".$resized." ".$png);
		
		my @sections=split(/_/,$file);
		my $id="";
		for(my $i=0;$i<3;$i++) {
			if($id eq "") { $id = $sections[$i]; } else { $id = $id ."_". $sections[$i]; }
		}
	

	}
}


