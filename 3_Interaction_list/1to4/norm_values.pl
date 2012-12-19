#! /usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;

my $input_matrix = $ARGV[0];
my $input = $ARGV[1];


my $nf = 0;
open (MEDIANS, $input) or die $!;
my $median_of_medians = 0;

my ($j,$k,$i,$m,$l,$line,$element,@row_array,@oneD_array,@main_2D_array,$working,@sorted_list,$median,$count);
$j=$k=$i=$line=$m=$l=$element=$working=$median=$count = 0;

open (MATRIX, $input_matrix) or die $!;
my $avg = 0;


#Creating the matrix
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

my @temp=();

#Saving the file name to compare it with TF's associated with it.	
#take the basename of the path.  
@temp = split(/\//,$input_matrix);
my $filename=$temp[@temp-1];
@temp=();
@temp = split(/\_/,$filename);
$filename = $temp[0]."_".$temp[1];
#fix for retarted naming
my $n=$temp[2];
my ($plateType);
if($n eq "N") {
	$plateType=$temp[3];
} else {
	$plateType=$temp[2];
}


my ($plateStart,$plateEnd)=split(/-/,$plateType);


#working out the median
$count=@oneD_array;  
$working = floor($count / 2);
@sorted_list = sort {$a <=> $b} @oneD_array;
$median = $sorted_list[$working];
my @oneD_arrayA = ();
my $lineA  = 0;
my @sorted_listA = ();
my $countA = 0;
my $w = 0;
my $main_2D_array_nf = 0;
#flush buffer
$| = 1;

#obtaining the median of the medians
while($lineA = <MEDIANS>){ 
$oneD_arrayA[$w++]=$lineA;
}

#Calculating the normalization factor for this plate
$countA=@oneD_arrayA;  
my $workingA = ($countA / 2);
@sorted_listA = sort {$a <=> $b} @oneD_arrayA;
my $medianA = $sorted_listA[$workingA];
$nf = $medianA/$median;

open(OUT,">$input_matrix.norm_values.txt");
#Row column normalization
#*************************************************
#Obtain an array with normalized row values
#*************************************************
my $midpoint = 0;
my $total=0;
my (@temp_array,$average,@new_median_value,@array_of_median_row,@array_of_median_col,$size);
$size = $average = 0;
for($l=0; $l<$i; $l++){
	$midpoint = (scalar @row_array)/2;
    @temp_array = ();
    
	for($m=0; $m<@row_array; $m++){	
		$temp_array[$m] = $main_2D_array[$l][$m];
	}
	@temp_array = sort{$a <=> $b} @temp_array;
	$array_of_median_row[$l] = $temp_array[$midpoint];
	$total = $total + $array_of_median_row[$l];
}
$average = $total / $i;
for($l=0; $l<$i; $l++){
	$new_median_value[$l] = $average / $array_of_median_row[$l];
}

for($l=0; $l<$i; $l++){
	for($m=0; $m<@row_array; $m++){
		#values normalized for rows.
		$main_2D_array[$l][$m] = $main_2D_array[$l][$m] * $new_median_value[$l];
	}
}
@new_median_value = ();
#*************************************************
#Obtain an array with normalized row values
#**********************************************End

#*************************************************
#Obtain an array with normalized column values
#*************************************************
$total=0;

for($m=0; $m<@row_array; $m++){
$midpoint = ($i)/2;
@temp_array = ();
	for($l=0; $l<$i; $l++){
		$temp_array[$l] = $main_2D_array[$l][$m];	
	}
	@temp_array = sort{$a <=> $b} @temp_array;
	$array_of_median_col[$m] = $temp_array[$midpoint];
	$total = $total + $array_of_median_col[$m];
	
}

$size = scalar @row_array;
$average = $total / $size;

for($m=0; $m<@row_array; $m++){
	#print "the values for $array_of_median_col[$m] are:". $array_of_median_col[$m]. "\n";
	$new_median_value[$m] = $average / $array_of_median_col[$m];
	#print "The value for average is: ", $average, "\n";
}

for($m=0; $m<@row_array; $m++){
	for($l=0; $l<$i; $l++){
		#values normalized for rows.
		$main_2D_array[$l][$m] = $main_2D_array[$l][$m] * $new_median_value[$m];		
	}
}

# Plate to plate normalization
# creating the new intensity value that has been normalized
for($l=0; $l<$i; $l++){
	for($m=0; $m<@row_array; $m++) {
		$main_2D_array[$l][$m] = $main_2D_array[$l][$m] * $nf;

	}

}

#Printing the normalized values
my $coord = 0;
#printout of the results
for($l=0; $l<$i; $l++){
	for($m=0; $m<@row_array; $m++) {
		$coord=$l.",".$m;
		#print OUT "$filename\t$plateStart-$plateEnd\t$coord\t$main_2D_array[$l][$m]\n";
		#print "$nf\t$main_2D_array[$l][$m]\t$main_2D_array_nf\n";
		print OUT "$main_2D_array[$l][$m]\t";
	}
	print OUT"\n";
}


close(OUT);
close(MATRIX);
close(MEDIANS);