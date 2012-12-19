use strict;
use English;

my %hash=();
my @initialImages = <*>;

foreach my $file (@initialImages) {
    #print "$file\n";
    
    #if(($file =~ /.png/) and ($file !~ /.cropped./g)) {
    if($file =~ /.png/){
	print "Processing files $file.....\n";
	my @tmp=split(/\./,$file);
	my $name="";
	for(my $i=0;$i<(@tmp-1);$i++) {
	    if($name eq "") { $name = $tmp[$i]; } else { $name=$name.".".$tmp[$i]; }
	}
	my $exten=$tmp[(@tmp-1)];
	
	my $orig=$name.".".$exten;
	my $xcoord = $orig;
	my $ycoord = $orig;
	$xcoord =~ s/.png/._x_coords.txt/;
	$ycoord =~ s/.png/._y_coords.txt/;
	
	
	system("perl magicPlate.pl -i ".$orig." -xgo ".$xcoord." -ygo ".$ycoord." -d 1");
    }
}




