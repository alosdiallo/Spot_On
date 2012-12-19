#! /usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;
my ($j,$k,$i,$line,$element,@row_array,@oneD_array,@main_2D_array,$working,@sorted_list,$median,$count);
$j=$k=$i=$line=$element=$working=$median=$count = 0;
my $input_matrix = $ARGV[0];
open (MATRIX, $input_matrix) or die $!;


while($line = <MATRIX>){ 
    # Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    @row_array = split(/\t/, $line);
    $j=0;
    foreach $element (@row_array){
		$main_2D_array[$i][$j++] =$element;
		$oneD_array[$k++]=$element;
    }
    $i++;
}
open(OUT,">>"."medians.txt");
$count=@oneD_array;  
$working = floor($count / 2);
@sorted_list = sort {$a <=> $b} @oneD_array;
$median = $sorted_list[$working];

print OUT "$median\n";

close(OUT);
close (MATRIX);