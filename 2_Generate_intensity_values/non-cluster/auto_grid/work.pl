use Parallel::ForkManager;
use strict;
use warnings;

my @initialImages = <*>;
my $MAX_PROCESSES = 0;
my $pm = 0;

foreach my $file (@initialImages) {

    if($file =~ /.png/){
        print "processing $file...\n";
        my @tmp=split(/\./,$file);
        my $name="";
        for(my $i=0;$i<(@tmp-1);$i++) {
            if($name eq "") { $name = $tmp[$i]; } else { $name=$name.".".$tmp[$i];}
        }

        my $exten=$tmp[(@tmp-1)];
        my $orig=$name.".".$exten;

    $pm = new Parallel::ForkManager($MAX_PROCESSES);
    my $pid = $pm->start and next;
        system("perl magicPlate.pl -i ".$orig." -min 4 -max 160 -d 1");
    $pm->finish; # Terminates the child process

     }
} 

