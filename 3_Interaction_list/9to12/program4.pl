#! /usr/bin/perl
#*******************************************************************
#Creating Zscore values 
#
#This program will create zscore values and append them to the list 
#*******************************************************************
use strict;
use warnings;
use POSIX;
use Data::Dumper;
use Math::Complex;

my ($total_deviation,$line,$fMeasure,$filename,$recall,$precision,$z_score,$computer_calls,$intensity,$coord,$array,$bait,$count,$tfCount,$i,$index,$total);
$fMeasure=$total_deviation=$filename=$recall=$precision=$z_score=$computer_calls=$intensity=$coord=$array=$bait=$count=$i=$index=$total = 0;
my ($l,$m);
my @tfdata;
my @zscoreA;
my $tfSize = 0;
my $input = $ARGV[0];
open (DATAFILE, $input) or die $!;
open(OUT,">final.output_p_r.txt");


while($line = <DATAFILE>){ 

    # Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    my @temp = split(/\t/, $line);
	
	$bait = $temp[0];
	$array = $temp[1];
	$coord = $temp[2];
	$intensity = $temp[3];
	#($l,$m) = split(/,/,$coord);
	$tfdata[$index]{'coord'} = $coord;
	$tfdata[$index]{'bait'} = $bait;
	$tfdata[$index]{'array'} = $array;
	$tfdata[$index]{'intensity'} = $intensity;
	$index ++;

}


$tfSize=@tfdata;
for($i=0;$i<$tfSize;$i++) {
	my $hashRef=$tfdata[$i];
	#$bait=$hashRef->{'bait'};
	#$coord=$hashRef->{'coord'};
	#$array=$hashRef->{'array'};
	$intensity=$hashRef->{'intensity'};
	$total = $total + $intensity; 
	
}
	
my $NORMALIZEDavg = $total / $tfSize;


for($i=0;$i<$tfSize;$i++) {
	my $hashRef=$tfdata[$i];
	$intensity=$hashRef->{'intensity'};
	$intensity = $intensity - $NORMALIZEDavg;
	$intensity = $intensity * $intensity;
	$total_deviation = $total_deviation + $intensity;

}

$total_deviation = $total_deviation / ($tfSize - 1);
my $NORMALIZEDstdv = sqrt($total_deviation);


for($i=0;$i<$tfSize;$i++) {
	my $hashRef=$tfdata[$i];
	$intensity=$hashRef->{'intensity'};
	$bait=$hashRef->{'bait'};
	$coord=$hashRef->{'coord'};
	$array=$hashRef->{'array'};
	my $zscore = (($intensity-$NORMALIZEDavg)/$NORMALIZEDstdv);

	print OUT "$bait\t$array\t$coord\t$intensity\t$zscore\n";

}








close(OUT);
close (DATAFILE);