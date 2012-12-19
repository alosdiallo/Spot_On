#! /usr/bin/perl
#*******************************************************************
#Creating a Zscore file
#
#This program will take the list of values and construct indevidual 
#files with zscore valus from the different plates
#*******************************************************************
use strict;
use warnings;
use POSIX;
use Data::Dumper;
use Math::Complex;

my($l,$m,$total_deviation,$tmpSize,$line,$fMeasure,$filename,$recall,$precision,$index,$z_score,$computer_calls,$intensity,$zscore,$coord,$array,$bait,$count,$tfCount,$i,$key,$total);
$l=$m=$fMeasure=$total_deviation=$filename=$tmpSize=$recall=$precision=$z_score=$index=$computer_calls=$intensity=$coord=$array=$bait=$zscore=$count=$i=$key=$total = 0;
my @tfdata;
my @zscoreA;
my $tfSize = 0;
my $input = $ARGV[0];
open (DATAFILE, $input) or die $!;
my @zscore_array;
my @raw_array;
my @zscore_array_final;

my %tfCount=();
my %baitCount=();
my %tfData=();

while($line = <DATAFILE>){ 

    # Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    my @temp = split(/\t/, $line);
	
	$bait = $temp[0];
	$array = $temp[1];
	$coord = $temp[2];
	$intensity = $temp[3];
	$zscore = $temp[4];
	
	if(exists($tfCount{$bait})) {
		$index=$tfCount{$bait};
	} else {
		$tfCount{$bait}=$index=0;
	}
	
	$tfData{$bait}[$index]{'coord'}=$coord;
    $tfData{$bait}[$index]{'array'}=$array;
    $tfData{$bait}[$index]{'intensity'}=$intensity;
	$tfData{$bait}[$index]{'zscore'}=$zscore;
	$tfCount{$bait}++;

}

my @tmp;
$| = 1;
$tfSize=@tfdata;
foreach $bait (keys %tfData) {
	
	my $tmpRef=$tfData{$bait};
	my @tmp=@$tmpRef;
	my $tmpSize=@tmp;
	
	for($i=0;$i<$tmpSize;$i++) {
		$coord=$tfData{$bait}[$i]{'coord'};
		$array=$tfData{$bait}[$i]{'array'};
		$intensity=$tfData{$bait}[$i]{'intensity'};
		$zscore=$tfData{$bait}[$i]{'zscore'};
		my $name = $bait."_".$array."_5mM_Xgal_7d_W";
		open(OUT,">$name.cropped.resized.grey.png.zscore.txt");
		my($y,$x) = split(/,/,$coord);
		$zscore_array[$y][$x] = $zscore;
		$raw_array[$y][$x] = $intensity;
		
	}
	
	
	

#***Using first zscore to compute a second zscore***	
my $total = 0;
my $count = 0;
my $avg = 0;
my $total_deviation=0;


for($l=0; $l<32; $l++){
	for($m=0; $m<48; $m++){			
		if($zscore_array[$l][$m] < 2) {
			$total=$total+$raw_array[$l][$m];
			$count++;
		}
	}
}

$avg=$total/$count;
$total_deviation=0;
my $nSquares=0;

for($l=0; $l<32; $l++){
    for($m=0; $m<48; $m++) {	
		if($zscore_array[$l][$m] < 2) {
			my $deviation=($raw_array[$l][$m]-$avg);
			my $sqr_deviation=$deviation**2;
			$total_deviation=$total_deviation+$sqr_deviation;
			$nSquares++;
		}
	}
}


$total_deviation = $total_deviation / ($nSquares-1);
my $stdv = sqrt($total_deviation);

for($l=0; $l<32; $l++){
	for($m=0; $m<48; $m++) {		
		$zscore_array_final[$l][$m] = (($raw_array[$l][$m]-$avg)/$stdv);
	}
}
	
	
#printing the zscore values out
	for($l=0; $l<32; $l++){
	  		for($m=0; $m<48; $m++) {		
				print OUT "$zscore_array[$l][$m]\t";
			}
			print OUT "\n";
	}		
	
}

	

close(OUT);
close (DATAFILE);
