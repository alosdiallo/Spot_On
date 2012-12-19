use strict;
use English;

my %hash=();
my $plate_home = "/home/dialloa/nearline/701/";
my $home_base = "/home/dialloa/";
chdir $plate_home;
my @initialImages = <*>;
chdir $home_base;
foreach my $file (@initialImages) {
    if($file =~ /.png/){
	my @tmp=split(/\./,$file);
	my $name="";
	for(my $i=0;$i<(@tmp-1);$i++) {
	    if($name eq "") { $name = $tmp[$i]; } else { $name=$name.".".$tmp[$i]; }
	}
	my $exten=$tmp[(@tmp-1)];
	
	my $orig=$name.".".$exten;
	
	system("qsub processPlates /nearline/701/".$orig);
    }
}
