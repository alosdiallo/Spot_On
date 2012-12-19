#! /usr/bin/perl
use warnings;
use strict;


my %tfIntensity=();
my %tfSize=();
my %arrayFileHash=();
my $data = 0;
my $size = 0;
my $intensity_file_name = 0;
my $size_file_name = 0;
my $arrayFile = 0;
my @files = <*>;
foreach my $file (@files) {
	if($file =~ /cropped.resized.grey.png.red.median.colony.txt$/) {
		$data = $file;
		my @tmp=split(/_/,$data);
		my @temp = split(/\_/,$file);
		$intensity_file_name = $temp[0]."_".$temp[1]."_".$temp[2];
		#fix for retarted naming
		my $n=$tmp[2];
		my ($plateType);
		if($n eq "N") {
			$plateType=$tmp[3];
		} else {
			$plateType=$tmp[2];
		}
	    $arrayFile=$plateType.".txt";
		$intensity_file_name = $temp[0]."_".$temp[1]."_".$plateType;
		$tfIntensity{$intensity_file_name}{'data'}=$data;

	}


}

foreach $intensity_file_name ( keys %tfIntensity ) {
		my $intensityFile = $tfIntensity{$intensity_file_name}{'data'};
		print "\nprocessing $intensityFile...\n";
		system ("perl program3.pl $intensityFile medians.txt");
		print "\tperl program3.pl $intensityFile medians.txt\n";
	
}
	