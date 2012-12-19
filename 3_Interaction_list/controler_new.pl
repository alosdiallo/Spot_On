

#! /usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;


my $one = "1to4";
my $five = "5to8";
my $nine = "9to12";
my $back = "..";
my $dataF = "dataFiles";



print "\tRemoving out file...\n";
system ("rm dataFiles/output.list.txt");
system ("rm dataFiles/final.output_p_r.txt");

print "\tDone\n\n";

print "\tRemoving old zscore files...\n";
system ("rm 9to12/mediansN.txt");
system ("rm 1to4/mediansN.txt");
system ("rm 5to8/mediansN.txt");
system ("rm 1to4/long9-12.txt");
system ("rm 5to8/long9-12.txt");
system ("rm 9to12/long9-12.txt");
system ("rm 9to12/final.output_p_r.txt");
system ("rm 1to4/final.output_p_r.txt");
system ("rm 5to8/final.output_p_r.txt");
system ("rm 1to4/*.zscore.txt");
system ("rm 5to8/*.zscore.txt");
system ("rm 9to12/*.zscore.txt");
system ("rm dataFiles/10[0-6]*.zscore.txt");
system ("rm dataFiles/107[0-5]*.zscore.txt");
system ("rm dataFiles/107*.zscore.txt");
system ("rm dataFiles/*.zscore.txt");
system ("rm 1to4/*.norm_values.txt");
system ("rm 5to8/*.norm_values.txt");
system ("rm 9to12/10*.norm_values.txt");
system ("rm 9to12/*.norm_values.txt");
system ("rm dataFiles/10[0-6]*.norm_values.txt");
system ("rm dataFiles/107[0-5]*.norm_values.txt");
system ("rm dataFiles/107*.norm_values.txt");
system ("rm dataFiles/*.norm_values.txt");
print "\tDone\n\n";

print "\tCreating new zscore files...\n";
chdir $one;
system ("perl processALL.pl");
system ("perl processALL2.pl");
system ("perl program4.pl long9-12.txt");
system ("perl program5.pl final.output_p_r.txt");
system ("perl processALL_norm.pl");
system ("cp *.zscore.txt ../dataFiles/");
system ("cp *.norm_values.txt ../dataFiles/");
chdir $back; 
chdir $five;
system ("perl processALL.pl");
system ("perl processALL2.pl");
system ("perl program4.pl long9-12.txt");
system ("perl program5.pl final.output_p_r.txt");
system ("perl processALL_norm.pl");
system ("cp *.zscore.txt ../dataFiles/");
system ("cp *.norm_values.txt ../dataFiles/");
chdir $back;
chdir $nine;
system ("perl processALL.pl");
system ("perl processALL2.pl");
system ("perl program4.pl long9-12.txt");
system ("perl program5.pl final.output_p_r.txt");
system ("perl processALL_norm.pl");
system ("cp *.zscore.txt ../dataFiles/");
system ("cp *.norm_values.txt ../dataFiles/");
print "\tDone\n\n";

print "\tGenerating stats\n";
chdir $back;
chdir $dataF;
system ("pwd");
system ("perl ../processALL.pl");
print "\tDone\n\n";

 
