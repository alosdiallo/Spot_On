#! /usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;
use Math::Complex;


my $input = $ARGV[0];
open (DATAFILE, $input) or die $!;
open(OUT,">final.output_p_r.txt");

my ($line,$fMeasure,$filename,$recall,$precision,$z_score,$computer_calls,$johns_calls,$false_negatives,$false_positives,$true_positives,$count);
$fMeasure=$filename=$recall=$precision=$z_score=$computer_calls=$johns_calls=$false_negatives=$false_positives=$true_positives=$count = 0;



#$hash{zscore}{platename}[0]=tp
my %stats=();
my %zscore=();
while($line = <DATAFILE>){ 
    # Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    my @temp = split(/\t/, $line);
	$true_positives = $temp[0];
	$false_positives = $temp[1];
	$false_negatives = $temp[2];
	$johns_calls = $temp[3];
	$computer_calls = $temp[4];
	$z_score = $temp[5];
	$filename = $temp[6];
	$stats{$z_score}{$filename}[0] = $true_positives;
	$stats{$z_score}{$filename}[1] = $false_positives;
	if(exists($stats{$z_score}{$filename}[2])) { print "HUGE ERROR\n"; }
	$stats{$z_score}{$filename}[2] = $johns_calls;
	$stats{$z_score}{$filename}[3] = $computer_calls;
	$stats{$z_score}{$filename}[4] = $filename;
	$stats{$z_score}{$filename}[5] = $false_negatives;
	$zscore{$z_score}++;
}

my $false_negatives_new = 0;
my $false_positives_new = 0;
my $true_positives_new = 0;
my $johns_calls_new = 0; 
my $computer_calls_new = 0;
my $file_name = 0;

foreach $z_score ( sort keys %stats ) {
	#print "$z_score\n";
	foreach $filename( keys %{$stats{$z_score}} ){
		#print "\t$filename\n";
		my $tp = $stats{$z_score}{$filename}[0];
		my $fp = $stats{$z_score}{$filename}[1];
		my $jc = $stats{$z_score}{$filename}[2];
		my $cc = $stats{$z_score}{$filename}[3];
		my $fn = $stats{$z_score}{$filename}[4];
		my $fan = $stats{$z_score}{$filename}[5];
		#print "\t\t$tp\t$fp\t$jc\t$cc\t$fn\t$fan\n";
		$false_positives_new = $false_positives_new + $fp;
		$true_positives_new = $true_positives_new + $tp;
		$johns_calls_new = $johns_calls_new + $jc; 
		$computer_calls_new = $computer_calls_new + $cc;
		$false_negatives_new = $false_negatives_new + $fan; 
	}
	
	my $precision = $true_positives_new/$computer_calls_new;
	my $recall = $true_positives_new/$johns_calls_new;
	
	my $FN = $false_negatives_new/$johns_calls_new;
	$FN = $FN * 100;
	my $FP = $false_positives_new/($false_positives_new + $true_positives_new);
	$FP = $FP * 100;
	print OUT "$FN\t$FP\t$z_score\n";
	#print OUT "$false_negatives_new\t$true_positives_new\t$z_score\n";
	#print "p=$precision\tr=$recall\n";
	#print "tp=$true_positives_new\tfp=$false_positives_new\tfn=$false_negatives_new\tjc=$johns_calls_new\tcc=$computer_calls_new\n\n";
	$false_positives_new = 0;
	$true_positives_new = 0;
	$johns_calls_new = 0;
	$computer_calls_new = 0;
	$false_negatives_new = 0;
	$file_name = 0;
	$precision = 0;
	$recall = 0;
	$FN = 0;
	$FP = 0;
}



close(OUT);
close (DATAFILE);