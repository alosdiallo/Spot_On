#! /usr/bin/perl

use strict;
use warnings;
use POSIX;
use Data::Dumper;


###########################################
# opening the files and getting the data. 
###########################################

#Things to change later:
#Change row_array to column_array for all row array varrients 
 
my $input_matrix = $ARGV[0];
my $input_array = $ARGV[1];
my $calls = $ARGV[2];
my $input_size = $ARGV[3];
my $input_zscore = $ARGV[4];
my $input_norm_matrix = $ARGV[5];
my $restT = $ARGV[6];
my $tf_names = $ARGV[7];
my $bait_names = $ARGV[8];


sub matrix_array($){
	my ($line,$i,$k,$j,$element);
	my (@main_2D_array, @row_array, @oneD_array);
	$line=$i=$k=$j=$element = 0;
	my $input_matrix = shift;
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
	
	
	close (MATRIX);
	return(\@main_2D_array,\@oneD_array,\@row_array,$i);
}


sub small_values($$$$){
	my $row_array_ref = shift;
	my $main_2D_array_ref = shift;
	my $i = shift;
	my $oneD_array_ref = shift;
	my @row_array = @$row_array_ref;
	my @main_2D_array = @$main_2D_array_ref;
	my @oneD_array = @$oneD_array_ref;
	my @reduced_val = ();
	my $count=@oneD_array;  
	my $working = ($count / 2);
	my @sorted_list = sort {$a <=> $b} @oneD_array;
	my $median = $sorted_list[$working];
	my ($l,$m);

	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++){
			$reduced_val[$l][$m] = $main_2D_array[$l][$m] - $median;
		}
	}
		
	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++){
			if($reduced_val[$l][$m] > 0){
				$reduced_val[$l][$m] = 0;
			}
		}
	}
	return(\@reduced_val);
}


sub normalization($){
	my $input_norm_matrix = shift;
	open (NORMMATRIXVALUES, $input_norm_matrix) or die $!;
	my ($iN, $jN, $kN,$lineN,@main_2D_arrayN,@oneD_arrayN,@row_arrayN); 
	$lineN = $iN = $jN = $kN = 0;
	my $elementN = 0;

	while($lineN = <NORMMATRIXVALUES>){ 
		# Chop off new line character, skip the comments and empty lines.                 
		chomp($lineN); 
		#print OUT "$lineN\n";
		@row_arrayN = split(/\t/, $lineN);
		$jN=0;
		foreach $elementN (@row_arrayN){
			$main_2D_arrayN[$iN][$jN++] = $elementN;
			$oneD_arrayN[$kN++]=$elementN;
			#print OUT "\t$main_2D_arrayN[$iN][$jN]\n";
		}
		$iN++;
	}
	close (NORMMATRIXVALUES);
	return(\@main_2D_arrayN,\@oneD_arrayN);	
}


sub colony_zscore($){
	my $input_zscore = shift;
	open (COLONYZSCORE, $input_zscore) or die $!;
	 my ($lineZ,@row_array_zscore,$elementZ,$q,$o,@main_2D_array_zscore,@oneD_array_zscore,$f);
	$lineZ=$elementZ=$q=$o=$f= 0;
	
	 while($lineZ = <COLONYZSCORE>){ 
		# Chop off new line character, skip the comments and empty lines.                 
		chomp($lineZ); 
		@row_array_zscore = split(/\t/, $lineZ);
		$o=0;
		foreach my $elementZ (@row_array_zscore){
			$main_2D_array_zscore[$q][$o++] =$elementZ;
			#print "$main_2D_array_zscore[$q][$o++]\n";
			$oneD_array_zscore[$f++]=$elementZ;

		}
		$q++;
	}
	
	
	close (COLONYZSCORE);
	return(\@main_2D_array_zscore,\@oneD_array_zscore);
}



sub tf_array($){
	my (@main_2D_tfarray, @row_tfarray, @oneD_tfarray);
	my $input_array = shift;
	my ($tfarray,$tfelement,$s,$p,$r);
	$tfarray=$tfelement=$s=$p=$r = 0;
	open (TFARRAY, $input_array) or die $!;

	#for the TF array
	while($tfarray = <TFARRAY>){ 
		# Chop off new line character, skip the comments and empty lines.                 
		chomp($tfarray); 
		@row_tfarray = split(/\s/, $tfarray);
		$p=0;
		foreach $tfelement (@row_tfarray){
			$main_2D_tfarray[$s][$p++] =$tfelement;
			$oneD_tfarray[$r++]=$tfelement;
		}
		$s++;
	}
	close (TFARRAY);
	return(\@main_2D_tfarray,\@oneD_tfarray);
}



sub colony_Size($){
	my (@main_2D_size_array, @row_size_array, @oneD_size_array);
	my $input_size = shift;
	open (COLONYSIZE, $input_size) or die $!;
	
	my ($size_value,$size_element,$c,$z,$w);
	$size_value=$size_element=$c=$z=$w = 0;
	
	#for the size matrix #added 12/8/10
	while($size_value = <COLONYSIZE>){ 
		# Chop off new line character, skip the comments and empty lines.                 
		chomp($size_value); 
		@row_size_array = split(/\t/, $size_value);
		$w=0;
		foreach $size_element (@row_size_array){
			$main_2D_size_array[$z][$w++] =$size_element;
			$oneD_size_array[$c++]=$size_element;
		}
		$z++;

	}
	close (COLONYSIZE);
	return(\@main_2D_size_array,\@oneD_size_array);
}


sub file_Name($){
	my @temp=();
	my ($filename,$plateType,$plateStart,$plateEnd,$n,$long_name);
	$filename=$plateType=$plateStart=$plateEnd=$n = 0;
	my $input_matrix = shift;


	#Saving the file name to compare it with TF's associated with it.	
	#take the basename of the path.  
	@temp = split(/\//,$input_matrix);
	$filename=$temp[@temp-1];
	@temp=();
	@temp = split(/\_/,$filename);
	$filename = $temp[0]."_".$temp[1];
	#fix for retarted naming
	$n=$temp[2];

	if($n eq "N") {
		$plateType=$temp[3];
	} else {
		$plateType=$temp[2];
	}

	($plateStart,$plateEnd)=split(/-/,$plateType);
	$long_name = $filename."_".$plateType; #added 11/24/2010
	return($filename,$plateType,$plateStart,$plateEnd,$long_name);
}

#fix naming
sub standardizeKey ($) {
                my $spotKey = shift;
                
                my ($plateNum,$coordinates)=split(/-/,$spotKey);

                $plateNum =~ s/^0+//;
                $coordinates =~ s/([A-Z])0+/$1/;

                my $convertedKey=$plateNum . "-" . $coordinates;
                
                #print "$spotKey -> $convertedKey\n";
                
                return($convertedKey);
}

sub standardizeKeyBait ($) {
                my $spotKey = shift;
                
                my ($plateNum,$coordinates)=split(/_/,$spotKey);

                $plateNum =~ s/^0+//;
                $coordinates =~ s/([A-Z])0+/$1/;

                my $convertedKey=$plateNum . "-" . $coordinates;
                
                #print "$spotKey -> $convertedKey\n";
                
                return($convertedKey);
}

#Inputing Johns list

sub human_Calls($$$$){
my %goldcalls=();

my $filename = shift;
my $JohnsCalls = shift;
my $plateStart = shift;
my $plateEnd = shift;
open (JOHNSCALLS, $calls) or die $!;
my ($line,@temp,$gold_tf,$n,$type,$pos,$prey_gene,$plate_name);
$line=0;
while($line = <JOHNSCALLS>){ 
    # Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
   @temp = split(/\t/, $line);

	$gold_tf=$temp[3];

	$plate_name = $temp[0];

	$gold_tf = 	standardizeKey($gold_tf);

	($type,$pos)=split(/-/,$gold_tf);
	
	if($plate_name eq $filename) {
		if(($type >= $plateStart) and ($type <= $plateEnd)) {
			$goldcalls{$gold_tf} = 1;
			#print OUT "$filename\t$gold_tf\n";


		}
	}
}

	close (COLONYSIZE);
	return(\%goldcalls);
}


sub restrict_List($){
my $restT = shift;
open (RESTT, $restT) or die $!;
my %restT=();
my $linemed = 0;
while($linemed = <RESTT>){                
    chomp($linemed); 
    my @temp = split(/\t/, $linemed);
	my $all_baits = $temp[0];
	#$all_baits = standardizeKeyBait($all_baits);

	$restT{$all_baits} = $all_baits;
}
close (RESTT);
return(\%restT);
}


sub tf_names($){
my $line = 0;
my $tf_names = shift;
my %tf_more_info=();
open (TFNAMES, $tf_names) or die $!;	
while($line = <TFNAMES>){ 
    ###Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    my @temp = split(/\t/, $line);
			my $arraytfname = $temp[0];
			my $orf = $temp[1];
			my $genename = $temp[2];
			$tf_more_info{$arraytfname} = $arraytfname."|".$orf."|".$genename;
			
}	
return(\%tf_more_info);
close (TFNAMES);
}



sub bait_names($){
my $line = 0;
my $baitSID = 0;
my %bait_more_info=();
open (BAITNAMES, $bait_names) or die $!;
while($line = <BAITNAMES>){ 
    ##Chop off new line character, skip the comments and empty lines.                 
    chomp($line); 
    my @temp = split(/\t/, $line);
			$baitSID = $temp[0];
			my $baitName = $temp[1];
			# my $baitSN = $temp[2];
			# my $baitP = $temp[3];
			$bait_more_info{$baitSID} = $baitSID."|".$baitName;
			
}	
return(\%bait_more_info);
close (BAITNAMES);

}

sub empty(){
	my @empty_spots = ("10-C10","10-C11","10-C12","10-C6","10-C7","10-C8","10-C9","10-H12","11-B10","11-B11","11-B12","11-C1","11-C10","11-C11","11-C12","11-C2","11-C3","11-C4","11-C5","11-C6","11-C7","11-C8","11-C9","11-D1","11-D10","11-D11","11-D12","11-D2","11-D3","11-D4","11-D5","11-D6","11-D7","11-D8","11-D9","11-E1","11-E10","11-E11","11-E12","11-E2","11-E3","11-E4","11-E5","11-E6","11-E7","11-E8","11-E9","11-F1","11-F10","11-F11","11-F12","11-F2","11-F3","11-F4","11-F5","11-F6","11-F7","11-F8","11-F9","11-G1","11-G10","11-G11","11-G12","11-G2","11-G3","11-G4","11-G5","11-G6","11-G7","11-G8","11-G9","11-H1","11-H10","11-H11","11-H12","11-H2","11-H3","11-H4","11-H5","11-H6","11-H7","11-H8","11-H9","12-A1","12-A10","12-A11","12-A12","12-A2","12-A3","12-A4","12-A5","12-A6","12-A7","12-A8","12-A9","12-B1","12-B10","12-B11","12-B12","12-B2","12-B3","12-B4","12-B5","12-B6","12-B7","12-B8","12-B9","12-C1","12-C10","12-C11","12-C12","12-C2","12-C3","12-C4","12-C5","12-C6","12-C7","12-C8","12-C9","12-D1","12-D10","12-D11","12-D12","12-D2","12-D3","12-D4","12-D5","12-D6","12-D7","12-D8","12-D9","12-E1","12-E10","12-E11","12-E12","12-E2","12-E3","12-E4","12-E5","12-E6","12-E7","12-E8","12-E9","12-F1","12-F10","12-F11","12-F12","12-F2","12-F3","12-F4","12-F5","12-F6","12-F7","12-F8","12-F9","12-G1","12-G10","12-G11","12-G12","12-G2","12-G3","12-G4","12-G5","12-G6","12-G7","12-G8","12-G9","12-H1","12-H10","12-H11","12-H12","12-H2","12-H3","12-H4","12-H5","12-H6","12-H7","12-H8","12-H9","1-H12","2-H12","3-H12","4-H12","5-H12","6-H12","7-H12","8-H12","9-C10","9-C11","9-C12","9-H10","9-H12","9-H12","9-H7","9-H8","9-H9");
	my @ignore_bait = (	"1005_G02","1077_A02","1077_A11","1005_C09","1027_E01","VV_B11","1005_B07","1072_H01","1078_B05","1077_C06","1076_D07","1005_E12","1040_B01","1077_C11","1006_B02","1005_H05","1076_C03","1074_F06");
	my ($l,$m,$blank);
	my %empty_spots_tf;
	my %empty_bait;

	for($l=0; $l<@empty_spots; $l++){
		$blank = $empty_spots[$l];
		$empty_spots_tf{$blank} = 1;
	}
	for($l=0; $l<@ignore_bait; $l++){
		$blank = $ignore_bait[$l];
		$empty_bait{$blank} = 1;
	}
return(\%empty_spots_tf,\%empty_bait);
}


sub original_matrix($$){
	my $row_array_ref = shift;
	my $main_2D_array_ref = shift;
	my $i = shift;
	my @row_array = @$row_array_ref;
	my @main_2D_array = @$main_2D_array_ref;
	my $total=0;
	my ($l,$m,@array_of_median_row,@new_median_value);

	for($l=0; $l<$i; $l++){
		my $midpoint = (scalar @row_array)/2;
		my @temp_array = ();
		
		for($m=0; $m<@row_array; $m++){	
			$temp_array[$m] = $main_2D_array[$l][$m];
		}
		@temp_array = sort{$a <=> $b} @temp_array;
		$array_of_median_row[$l] = $temp_array[$midpoint];
		$total = $total + $array_of_median_row[$l];
	}
	my $average = $total / $i;
	for($l=0; $l<$i; $l++){
		$new_median_value[$l] = $average / $array_of_median_row[$l];
	}

	my @original_values;

	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++){
		$original_values[$l][$m]  = $main_2D_array[$l][$m];
		}
	}
	return(\@original_values,\@new_median_value);
}



sub top_row_median ($$) {
	my $row_array_ref = shift;
	my $main_2D_array_ref = shift;
	my ($l,$m);

	my @main_2D_array = @$main_2D_array_ref;
	my @row_array = @$row_array_ref;
	my $top_row_median = 0;
	my @top_row = ();
	my $counter_new = 0;

	for($l=0; $l<1; $l++){
		for($m=0; $m<@row_array; $m++) {
			$top_row[$m] = $main_2D_array[$l][$m]; 
		}
	}
	$counter_new=@top_row;  
	my $workingAB = ($counter_new / 2);
	my @sorted_listAB = sort {$a <=> $b} @top_row;
	$top_row_median= $sorted_listAB[$workingAB];
	return($top_row_median);
}




sub RC_normalized_matrix($$$){
	my $row_array_ref = shift;
	my $main_2D_array_ref = shift;
	my $i = shift;
	my @main_2D_array = @$main_2D_array_ref;
	my @row_array = @$row_array_ref;
	my ($l,$m,@array_of_median_col);
	my (@array_of_median_row,@new_median_value,@temp_array,$average,@original_values,$size);
	#*******************************************************************
	#work to normalize
	#*******************************************************************

	#*************************************************
	#Obtain an array with normalized row values
	#*************************************************
	my $total=0;
	for($l=0; $l<$i; $l++){
		my $midpoint = (scalar @row_array)/2;
		
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
		$original_values[$l][$m]  = $main_2D_array[$l][$m];
		
		}
	}	
	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++){
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
		my $midpoint = ($i)/2;
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
	return(\@main_2D_array);
}



sub tfHash_Sub($$$$$$$$$$$$$$){
	my $bait_more_info = [];
	my $tf_more_info = [];
	my $empty_bait = [];
	my $main_2D_array_ref = shift;
	my $main_2D_tfarray_ref = shift;
	my $zscore_array_final_ref = shift;
	my $row_array_ref = shift;
	my $main_2D_size_array_ref = shift;
	my $i = shift;
	my $reduced_val_array_ref = shift;
	$bait_more_info = shift;
	$tf_more_info = shift;	
	my $filename = shift;
	$empty_bait = shift;
	my $original_values_ref = shift;

	my $main_2D_arrayN_ref = shift;
	my ($l,$m,$coord,$tfName);
	my @main_2D_array = @$main_2D_array_ref;
	my @main_2D_tfarray = @$main_2D_tfarray_ref;
	my @zscore_array_final = @$zscore_array_final_ref;
	my @row_array = @$row_array_ref;
	my @main_2D_size_array = @$main_2D_size_array_ref;
	my @reduced_val_array = @$reduced_val_array_ref;
	my @original_values = @$original_values_ref;

	my @main_2D_arrayN = @$main_2D_arrayN_ref;

	my %tfCount=();
	my %tfLookUp=();
	my %zscorehash =();
	my %tfData = ();
	my %small_hash = ();
	
	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++) {
			my $colonyName = $main_2D_tfarray[$l][$m];
			$tfName = substr($colonyName, 0,-2);			
			$coord = $l.",".$m;
			push(@{$tfLookUp{$tfName}},$coord);
		}
	}


	my $count=0;
	for($l=0; $l<$i; $l++){
		for($m=0; $m<@row_array; $m++) {
			my $zscoreValue=$zscore_array_final[$l][$m];
			my $size=$main_2D_size_array[$l][$m];#added 12/8/10
			my $rawValue=$main_2D_array[$l][$m];
			my $original = $original_values[$l][$m];
			my $normal_value = $main_2D_arrayN[$l][$m];
			my $reduced_val = $reduced_val_array[$l][$m];
			my $keynew = substr($main_2D_tfarray[$l][$m], 0,-2);
			if($reduced_val < 0){
				$small_hash{$keynew} = $reduced_val;
	
			}
			$count++;
			
			my $key = substr($main_2D_tfarray[$l][$m], 0,-2);	
			$zscorehash{$key} = $zscoreValue;
			
			my $index=0;
			if(exists($tfCount{$key})) { 
				$index=$tfCount{$key};
			}
			
			$coord=$l.",".$m;
			$tfData{$key}{'zscore'}[$index]=$zscoreValue;
			
			$tfData{$key}{'raw'}[$index]=$rawValue;
			$tfData{$key}{'norm'}[$index]=$normal_value;
			$tfData{$key}{'orig'}[$index]=$original;
			$tfData{$key}{'coord'}[$index]=$coord;
			$tfData{$key}{'size'}[$index]=$size;#added 12/8/10
			$tfCount{$key}++;
		}

	}
	

	return(\%tfCount,\%tfLookUp,\%tfData);
}


sub bleed_over($$$){
	my $tfCount = [];
	my $tfLookUp = [];
	my $tfData = [];
	my ($l,$m,$nHits,$nPos);	
	my (@coord_array,$i,$counter,$avg,$sum,$value,$x,$y,$nIgnored,$key);
	$avg=$counter=$i=$sum=$value=0;
	$tfCount = shift;
	$tfLookUp = shift;
	$tfData = shift;
	my %restricted_hash=();
	my %tfHits=();
	my %ignore=();
	my $bleedOverthreshold = 0;
	my ($topLeft,$topLeftOne,$topLeftTwo,$topLeftThree,$topRightOne,$topRightTwo,$topRightThree,$botLeftOne,$botLeftTwo,$botRightThree,$topRight,$botLeft);
	my ($botLeftThree,$botRight,$botRightOne,$botRightTwo);
	foreach $key ( keys %$tfCount ) {	
		$bleedOverthreshold = 200;
		$nHits=$tfCount->{$key};
		
		$nPos=0;
		for($i=0;$i<$nHits;$i++) {
			$value = $tfData->{$key}->{'orig'}[$i];
			if($value > $bleedOverthreshold) {
				$nPos++;
			}
		}
			
		if($nPos >= 3) {
			$sum=$avg=0;
			for($i=0;$i<$nHits;$i++) {
				$value=$tfData->{$key}->{'orig'}[$i];
				$sum += $value;
			}
			$avg=$sum/$nHits;			
			$topLeft=$tfLookUp->{$key}[0];
			$coord_array[$counter] = $topLeft;
			$counter++;
			$restricted_hash{$key}{$topLeft} = 1;
			($y,$x) = split(/,/,$topLeft);
			$topLeftOne=$y.",".($x-1);
			$topLeftTwo = ($y-1).",".($x-1);
			$topLeftThree = ($y-1).",".$x;
			#print "Top Left ref=$topLeft\t\t$topLeftOne\t$topLeftTwo\t$topLeftThree\n";
			$ignore{$topLeftOne} = 1;
			$ignore{$topLeftTwo} = 1;
			$ignore{$topLeftThree} = 1;
			
			$topRight=$tfLookUp->{$key}[1];
			$coord_array[$counter] = $topRight;
			$counter++;
			$restricted_hash{$key}{$topRight} = 1;
			($y,$x) = split(/,/,$topRight);
			$topRightOne = ($y-1).",".$x;
			$topRightTwo = ($y-1).",".($x+1);
			$topRightThree = $y.",".($x+1);
			#print "Top Right ref=$topRight\t\t$topRightOne\t$topRightTwo\t$topRightThree\n";
			$ignore{$topRightOne} = 1;
			$ignore{$topRightTwo} = 1;
			$ignore{$topRightThree} = 1;
			
			$botLeft=$tfLookUp->{$key}[2];
			$coord_array[$counter] = $botLeft;
			$counter++;
			$restricted_hash{$key}{$botLeft} = 1;
			($y,$x) = split(/,/,$botLeft);
			$botLeftOne = ($y+1).",".$x;
			$botLeftTwo = ($y+1).",".($x-1);
			$botLeftThree =$y.",".($x-1);
			#print "Bottom Left ref=$botLeft\t\t$botLeftOne\t$botLeftTwo\t$botLeftThree\n";
			$ignore{$botLeftOne} = 1;
			$ignore{$botLeftTwo} = 1;
			$ignore{$botLeftThree} = 1;
			
			$botRight=$tfLookUp->{$key}[3];
			$coord_array[$counter] = $botRight;
			$counter++;
			$restricted_hash{$key}{$botRight} = 1;
			($y,$x) = split(/,/,$botRight);
			$botRightOne =$y.",".($x+1);
			$botRightTwo = ($y+1).",".($x+1);
			$botRightThree = ($y+1).",".$x;
			#print "Bottom Right ref=$botRight\t\t$botRightOne\t$botRightTwo\t$botRightThree\n";
			$ignore{$botRightOne} = 1;
			$ignore{$botRightTwo} = 1;
			$ignore{$botRightThree} = 1;
			$tfHits{$key} = 1;
			
		}
	}

	$nIgnored=keys %ignore;

	#altering to allow for the cross
	my %limited_ignore=();
	$counter = 0;
	foreach $key ( keys %$tfCount ) {	
		$bleedOverthreshold = 200;
		$nHits=$tfCount->{$key};
		$nPos=0;
		for($i=0;$i<$nHits;$i++) {
			$value = $tfData->{$key}->{'orig'}[$i];
			if($value > $bleedOverthreshold) {
				$nPos++;
			}
		}
			
		if($nPos >= 1) {
			$sum=$avg=0;
			for($i=0;$i<$nHits;$i++) {
				$value=$tfData->{$key}->{'orig'}[$i];
				$sum += $value;
			}
			$avg=$sum/$nHits;
			
			$topLeft=$tfLookUp->{$key}[0];
			$coord_array[$counter] = $topLeft;
			$counter++;
			$restricted_hash{$key}{$topLeft} = 1;
			($y,$x) = split(/,/,$topLeft);
			$topLeftOne=$y.",".($x-1);
			$topLeftTwo = ($y-1).",".($x-1);
			$topLeftThree = ($y-1).",".$x;
			#print "Top Left ref=$topLeft\t\t$topLeftOne\t$topLeftTwo\t$topLeftThree\n";
			$limited_ignore{$topLeftOne} = 1;
			$limited_ignore{$topLeftTwo} = 1;
			$limited_ignore{$topLeftThree} = 1;
			
			$topRight=$tfLookUp->{$key}[1];
			$coord_array[$counter] = $topRight;
			$counter++;
			$restricted_hash{$key}{$topRight} = 1;
			($y,$x) = split(/,/,$topRight);
			$topRightOne = ($y-1).",".$x;
			$topRightTwo = ($y-1).",".($x+1);
			$topRightThree = $y.",".($x+1);
			#print "Top Right ref=$topRight\t\t$topRightOne\t$topRightTwo\t$topRightThree\n";
			$limited_ignore{$topRightOne} = 1;
			$limited_ignore{$topRightTwo} = 1;
			$limited_ignore{$topRightThree} = 1;
			
			$botLeft=$tfLookUp->{$key}[2];
			$coord_array[$counter] = $botLeft;
			$counter++;
			$restricted_hash{$key}{$botLeft} = 1;
			($y,$x) = split(/,/,$botLeft);
			$botLeftOne = ($y+1).",".$x;
			$botLeftTwo = ($y+1).",".($x-1);
			$botLeftThree =$y.",".($x-1);
			#print "Bottom Left ref=$botLeft\t\t$botLeftOne\t$botLeftTwo\t$botLeftThree\n";
			$limited_ignore{$botLeftOne} = 1;
			$limited_ignore{$botLeftTwo} = 1;
			$limited_ignore{$botLeftThree} = 1;
			
			$botRight=$tfLookUp->{$key}[3];
			$coord_array[$counter] = $botRight;
			$counter++;
			$restricted_hash{$key}{$botRight} = 1;
			($y,$x) = split(/,/,$botRight);
			$botRightOne =$y.",".($x+1);
			$botRightTwo = ($y+1).",".($x+1);
			$botRightThree = ($y+1).",".$x;
			#print "Bottom Right ref=$botRight\t\t$botRightOne\t$botRightTwo\t$botRightThree\n";
			$limited_ignore{$botRightOne} = 1;
			$limited_ignore{$botRightTwo} = 1;
			$limited_ignore{$botRightThree} = 1;
			
			#print OUT"\t$key\t$topLeft\t$topRight\t$botLeft\t$botRight\n";
		}
	}
	return(\%tfHits,\%ignore,\%limited_ignore);
}




sub restricted_Hashes($$$){
	my $tfData = [];
	my $ignore = [];
	my $limited_ignore = [];
	$tfData = shift;
	$ignore = shift;
	$limited_ignore = shift;
	my ($key,$i,$y,$x);
	my ($l,$m);	
	my %tf_restricted_hash=();
	my %tf_Limited_restricted_hash=();
	my $number_of_colonies_for_tf = 4;
	foreach $key ( keys %$tfData ) {	
			
		for($i=0;$i<$number_of_colonies_for_tf;$i++) {
			my $final_coord=$tfData->{$key}->{'coord'}[$i];
			my $final_zscore=$tfData->{$key}->{'zscore'}[$i];
			my $raw_value_new=$tfData->{$key}->{'raw'}[$i];
			my $size_element = $tfData->{$key}->{'size'}[$i];
			($y,$x) = split(/,/,$final_coord);
			
			if(exists($ignore->{$final_coord})) {
				$tf_restricted_hash{$key} = 1;
			}
			if(exists($limited_ignore->{$final_coord})) {
				$tf_Limited_restricted_hash{$key} = 1;
			}	
		}	
	}
	return(\%tf_restricted_hash,\%tf_Limited_restricted_hash);
}




sub test_mode($$$$$$$){
	my $tfCount = [];
	my $tfData = [];
	my $ignore = [];
	my $empty_spots_tf = [];
	my $empty_bait = [];
	my $goldcalls = [];
	$tfCount = shift;
	$tfData = shift;
	$ignore = shift;
	$empty_spots_tf = shift;
	my $long_name = shift;
	$empty_bait = shift;
	my $filename = shift;
	$goldcalls = shift;
	my ($l,$m,$i,$posThreshold,$raw_value,$incrementor,$tfName);	


	$raw_value = 0;
	$incrementor=0.01; 
	if (!exists($empty_bait->{$filename})) {

		for($posThreshold=0;$posThreshold<=10;$posThreshold=$posThreshold+$incrementor) {
			my %finalTFcalls=();
			foreach $tfName (keys %$tfCount ) {	
			
				my $nHits=$tfCount->{$tfName};
				my $nPos=0;
				for($i=0;$i<$nHits;$i++) {
					my $zscore=$tfData->{$tfName}->{'zscore'}[$i];
					my $coord=$tfData->{$tfName}->{'coord'}[$i];
					$raw_value=$tfData->{$tfName}->{'raw'}[$i];#Added 11/24/10
					next if(exists($ignore->{$coord}));
					next if(exists($empty_spots_tf->{$tfName}));
					
					if($zscore > $posThreshold) {

						$nPos++;
					}
					
				}
				
				if($nPos >= 2) {
					$finalTFcalls{$tfName}=1;
				}
			}

			my $platinumCalls=keys (%finalTFcalls);
			my $goldCalls=keys (%$goldcalls);
			
			my $numOfPos=0;
			foreach $tfName ( keys %finalTFcalls ) {
				if(exists($goldcalls->{$tfName})) {
					$numOfPos++;
				}
			}
			
			my $falsePositives=0;
			foreach $tfName ( keys %finalTFcalls ) {
				if(!exists($goldcalls->{$tfName})) {
					$falsePositives++;
				}
			}
			
			my $falseNegatives=0;
			foreach $tfName ( keys %$goldcalls ) {
				if(!exists($finalTFcalls{$tfName})) {
					$falseNegatives++;
				}
			}
			
			my ($precision,$recall);
			if(($goldCalls == 0) or ($platinumCalls == 0)) {

				$precision=0;
				$recall=0;
			} else {
				$precision = ($numOfPos/$platinumCalls);
				$recall = ($numOfPos/$goldCalls);
			} 

			print   OUT "$numOfPos\t$falsePositives\t$falseNegatives\t$goldCalls\t$platinumCalls\t$posThreshold\t$long_name\n"; #Added 11/23/10
		}
	}

		return();
}


sub shortList($$$$$$$$$$$){
	my $tfCount = [];
	my $tfData = [];
	my $ignore = [];
	my $empty_spots_tf = [];
	my $empty_bait = [];
	my $tf_Limited_restricted_hash = [];
	my $bait_more_info = [];
	my $tf_more_info = [];
	$tfCount = shift;
	$tfData = shift;
	$ignore = shift;
	$empty_spots_tf = shift;
	my $long_name = shift;
	my $filename = shift;
	$empty_bait = shift;
	$tf_Limited_restricted_hash = shift;
	$bait_more_info = shift;
	$tf_more_info = shift;
	my $top_row_median_value = shift;	
	my ($l,$i,$m,$total_raw_value,$total_raw_zscore,$total_raw_zscore_normal,$avg_raw_value,$avg_raw_zscore,$avg_raw_zscore_normal,$no_non_ignored,$stdev_z,$stdev_r,$total_sq_z,);	
	my ($total_sq_z_normal,$total_sq_r,$squared_deviation_score,$squared_deviation_score_normal,$squared_deviation_raw,$deviation_raw,$deviation_score,$deviation_score_normal,$raw_value);
	my ($zscore,$zscore_prime,$coord, $nHits,$nPos,$tfName,$norm,$raw_size);
	$total_raw_value=$total_raw_zscore=$total_raw_zscore_normal=$avg_raw_value=$avg_raw_zscore=$avg_raw_zscore_normal=$no_non_ignored=$stdev_z=$stdev_r=$total_sq_z=0;
    $total_sq_z_normal=$total_sq_r=$squared_deviation_score=$squared_deviation_score_normal=$squared_deviation_raw=$deviation_raw=$deviation_score=$deviation_score_normal=$raw_value=0;

	my %finalTFcalls=();
	my $number_of_colonies_for_tf = 4;

	foreach $tfName (keys %$tfCount ) {	
		$zscore = 0;
		$coord = 0;
		$nHits=$tfCount->{$tfName};
		$nPos=0;

		$total_raw_value = 0;
		$total_raw_zscore = 0;
		$no_non_ignored = 0;
		$avg_raw_value = 0;
		$avg_raw_zscore = 0;
		$avg_raw_zscore_normal = 0;

		for($i=0;$i<$number_of_colonies_for_tf;$i++) {
			$zscore=$tfData->{$tfName}->{'zscore'}[$i];
			$coord=$tfData->{$tfName}->{'coord'}[$i];
			$raw_value=$tfData->{$tfName}->{'raw'}[$i];#Added 11/24/10
			next if(exists($ignore->{$coord}));
			next if(exists($empty_spots_tf->{$tfName}));

			my $chosen_cut_off = 2.14;
			if($zscore >= $chosen_cut_off) {
				$nPos++;
			}
			$no_non_ignored++;
		}

		if($nPos >= 2) {
			$finalTFcalls{$tfName}=$nPos;
		}	
	}

	my %average_holder=();
	foreach $tfName (keys %finalTFcalls ) {
	
		$number_of_colonies_for_tf = 4;
		$zscore = 0;
		$zscore_prime = 0;
		$coord = 0;
		$nHits=$tfCount->{$tfName};
		$nPos=0;	
		$nPos=$finalTFcalls{$tfName};
		$total_raw_value = 0;
		$total_raw_zscore_normal = 0;
		my $avg_size = 0;
		my $size_total_value = 0;
		my $norm_total_value = 0;
		my $count = 0;	
		for($i=0;$i<$number_of_colonies_for_tf;$i++) {

			$zscore=$tfData->{$tfName}->{'zscore'}[$i];
			$coord=$tfData->{$tfName}->{'coord'}[$i];
			$raw_value=$tfData->{$tfName}->{'raw'}[$i];#Added 11/24/10
			$norm=$tfData->{$tfName}->{'norm'}[$i];
			$raw_size = $tfData->{$tfName}->{'size'}[$i];
			if((!exists($ignore->{$coord})) and ($zscore >= 2.14)) {
				$total_raw_value = $raw_value + $total_raw_value;
				$total_raw_zscore = $total_raw_zscore + $zscore;
				$total_raw_zscore_normal = $total_raw_zscore_normal + $zscore;
				$size_total_value = $size_total_value + $raw_size;
				$norm_total_value = $norm_total_value + $norm;
				$count++;
			}
		}
		
		$squared_deviation_raw = 0;
		$squared_deviation_score = 0;
		$squared_deviation_score_normal = 0;
		$avg_raw_value =  $total_raw_value/$count;
		$avg_raw_zscore = $total_raw_zscore/$count;
		$avg_raw_zscore_normal = $total_raw_zscore_normal/$count;
		$avg_size = $size_total_value/$count;
		my $avg_norm = $norm_total_value/$count;


		$total_sq_z = 0;
		$total_sq_z_normal = 0;
		$total_sq_r = 0;
		$stdev_z = 0;
		$stdev_r = 0;
		my $avg_val_z = 0;
		my $avg_val_z_normal = 0;
		my $avg_val_r = 0;
		$count = 0;
		for($i=0;$i<$number_of_colonies_for_tf;$i++) {
			$zscore=$tfData->{$tfName}->{'zscore'}[$i];
			$coord=$tfData->{$tfName}->{'coord'}[$i];
			$raw_value=$tfData->{$tfName}->{'raw'}[$i];
			if((!exists($ignore->{$coord})) and ($zscore >= 2.14)) {
			$deviation_score = $zscore - $avg_raw_zscore;
			$deviation_score_normal = $zscore - $avg_raw_zscore_normal;
			$deviation_raw = $raw_value - $avg_raw_value;
			$squared_deviation_score = $deviation_score**2;
			$squared_deviation_score_normal = $deviation_score_normal**2;
			$squared_deviation_raw = $deviation_raw**2;
			$total_sq_z = $total_sq_z + $squared_deviation_score;
			$total_sq_z_normal = $total_sq_z_normal + $squared_deviation_score_normal;
			$total_sq_r = $total_sq_r + $squared_deviation_raw;
			$count++;
			}
		}
		my $tffile = $tf_more_info->{$tfName};
		my ($arraytfname,$orf,$genename) = split(/\|/,$tffile);
		my $baitFile = $bait_more_info->{$filename};
		my ($baitSID,$baitName) = split(/\|/,$baitFile);

		
	# foreach $key ( keys %small_hash ) {
		# if (!exists($empty_bait->{$filename})) {
			# my $baitFile = $bait_more_info->{$filename};
			# my ($baitSID,$baitName) = split(/\|/,$baitFile);
			# my $tffile = $tf_more_info->{$key};
			# my ($arraytfname,$orf,$genename) = split(/\|/,$tffile);

			# if (exists($bait_more_info->{$filename})) {
				# if (exists($tf_more_info->{$key})) { 
					# print OUT "$filename\t$key\n";			
				# }
			# }
		# }
	# }

	if (!exists($empty_bait->{$filename})) {
		if (exists($tf_Limited_restricted_hash->{$tfName})) {
			#print OUT "$filename\t$tfName\t$nPos\t$avg_norm\t$avg_raw_zscore\t$avg_raw_zscore_normal\t$avg_raw_value\t$avg_size\t$top_row_median_value\tBO\n";
		}
		#else {print OUT "$filename\t$tfName\t$nPos\t$avg_norm\t$avg_raw_zscore\t$avg_raw_zscore_normal\t$avg_raw_value\t$avg_size\t$top_row_median_value\n";}
		}
	}	

	return(\%finalTFcalls);

}

sub selective_lists($$){
	my $finalTFcalls = [];
	my $goldcalls = [];
	$finalTFcalls = shift;
	$goldcalls = shift;
	my $key = 0;
	my %finalTFcalls_not=();
	foreach $key (keys %$goldcalls) {
		if(!exists($finalTFcalls->{$key})){
			$finalTFcalls_not{$key} = 1;
		}
	}

	my %goldcalls_not=();
	foreach $key (keys %$finalTFcalls) {
		if(!exists($goldcalls->{$key})){
			$goldcalls_not{$key} = 1;
			
		}
	}
	return(\%finalTFcalls_not,\%goldcalls_not);
}

sub long_list($$$$$$$$){
my $finalTFcalls = [];
my $tf_restricted_hash = [];
my $tfData = [];
my $tf_more_info = [];
my $bait_more_info = [];
my ($l,$m,$i);
$finalTFcalls = shift;
$tf_restricted_hash = shift;
$tfData = shift;
$tf_more_info = shift;
$bait_more_info = shift;
my $filename = shift;
my $plateType = shift;
my $median = shift;
my $infostring = 0;
my $tffile = 0;
my $baitfile = 0;
my $key = 0;
my $number_of_colonies_for_tf = 4;

foreach $key ( keys %$tfData ) {		
	for($i=0;$i<$number_of_colonies_for_tf;$i++) {
		my $final_coord=$tfData->{$key}->{'coord'}[$i];
		my $final_zscore=$tfData->{$key}->{'zscore'}[$i];
		my $raw_value_new=$tfData->{$key}->{'raw'}[$i];
		my $size_element = $tfData->{$key}->{'size'}[$i];
		my $normal_value = $tfData->{$key}->{'norm'}[$i];
		my $originalVal = $tfData->{$key}->{'orig'}[$i];
		my($y,$x) = split(/,/,$final_coord);
			if(exists($finalTFcalls->{$key})) {
					if(exists($tf_restricted_hash->{$key})) {
						print OUT "$filename\t$plateType\t$key\t$y\t$x\t$originalVal\t$raw_value_new\t$normal_value\t$final_zscore\t$median\tPositive\tBO\n";
					}
					else{
						 print OUT "$filename\t$plateType\t$key\t$y\t$x\t$originalVal\t$raw_value_new\t$normal_value\t$final_zscore\t$median\tPositive\n";
					}	
					
				}
				else{
					if(exists($tf_restricted_hash->{$key})) {
						print OUT"$filename\t$plateType\t$key\t$y\t$x\t$originalVal\t$raw_value_new\t$normal_value\t$final_zscore\t$median\tNegative\tBO\n";
					}
					else{
						print OUT "$filename\t$plateType\t$key\t$y\t$x\t$originalVal\t$raw_value_new\t$normal_value\t$final_zscore\t$median\tNegative\n";
					}
				}		
	}
}


return();
}


sub controler(){

#OUTPUT file
open(OUT,">>"."output.list.txt");
#OUTPUT file

#Declaration
my ($matrixTwoD,$matrixOneD,$row_array,$main_2D_arrayN,$oneD_arrayN,$reduced_val,$iN, $jN, $kN,$countN,$sorted_listN,$medianN,$workingN,$totalN,$lineN);
my ($main_2D_array_zscore,$oneD_array_zscore,$main_2D_tfarray,$oneD_tfarray,$elementZ,$q,$o,$f,$lineZ,$elementN,$filename,$plateType,$plateStart,$plateEnd,$n);
my ($main_2D_size_array,$oneD_size_array,$goldcalls,$restT_val,$bait_more_info,$tf_more_info,$empty_spots_tf,$empty_bait,$new_median_value,$original_values);
my ($tfCount,$tfData,$tfLookUp,$tfHits,$ignore,$limited_ignore,$tf_restricted_hash,$tf_Limited_restricted_hash,$finalTFcalls,$finalTFcalls_not,$goldcalls_not);
my ($top_row_median_value,$zmedian,$zprime,$main_2D_array,$i,$long_name);
my (@reduced_val_array,@zprime,@main_2D_array,@row_array_zscore,@main_2D_array_zscore,@oneD_array_zscore,@original_values,@main_2D_arrayN);
my (@oneD_array,@row_array,@main_2D_tfarray,@oneD_tfarray,@main_2D_size_array,@oneD_size_array,@zscore_array_final,@new_median_value,@oneD_arrayN);
$goldcalls=$bait_more_info=$restT_val=$tf_more_info=$empty_spots_tf=$empty_bait=$tfCount=$tfData=$tfLookUp=$tfHits=$ignore=$limited_ignore=$tf_restricted_hash=$tf_Limited_restricted_hash=$finalTFcalls=$finalTFcalls_not=$goldcalls_not=[];
$top_row_median_value=$zmedian=$sorted_listN=$medianN=$workingN=$totalN=$lineN=$iN=$jN=$kN=$countN=$lineZ=$elementZ=$q=$o=$f=$elementN=0;


#subrutine calls
($matrixTwoD,$matrixOneD,$row_array,$i)=&matrix_array($input_matrix);
@main_2D_array = @$matrixTwoD;
@oneD_array = @$matrixOneD;
@row_array = @$row_array;

($reduced_val)=&small_values(\@row_array,\@main_2D_array,$i,\@oneD_array);
@reduced_val_array = @$reduced_val;

($main_2D_arrayN,$oneD_arrayN)=&normalization($input_norm_matrix);
@main_2D_arrayN = @$main_2D_arrayN;
@oneD_arrayN = @$oneD_arrayN;

($main_2D_array_zscore,$oneD_array_zscore)=&colony_zscore($input_zscore);
@zscore_array_final = @$main_2D_array_zscore;
@oneD_array_zscore = @$oneD_array_zscore;

($main_2D_tfarray,$oneD_tfarray)=&tf_array($input_array);
@main_2D_tfarray = @$main_2D_tfarray;
@oneD_tfarray = @oneD_tfarray;

($main_2D_size_array,$oneD_size_array)=&colony_Size($input_size);
@main_2D_size_array = @$main_2D_size_array;
@oneD_size_array = @$oneD_size_array;

($filename,$plateType,$plateStart,$plateEnd,$long_name)=&file_Name($input_matrix);

($goldcalls)=&human_Calls($filename,$calls,$plateStart,$plateEnd);

($restT_val)=&restrict_List($restT);

($tf_more_info)=&tf_names($tf_names);

($bait_more_info)=&bait_names($bait_names);

($empty_spots_tf,$empty_bait)=&empty();

($original_values,$new_median_value)=&original_matrix(\@row_array,\@main_2D_array,$i);
@original_values = @$original_values;
@new_median_value = @$new_median_value;

($top_row_median_value) = &top_row_median(\@row_array,\@main_2D_array);

($main_2D_array)=&RC_normalized_matrix(\@row_array,\@main_2D_array,$i);
@main_2D_array = @$main_2D_array;


($tfCount,$tfLookUp,$tfData)=&tfHash_Sub(\@main_2D_array,\@main_2D_tfarray,\@zscore_array_final,\@row_array,\@main_2D_size_array,$i,\@reduced_val_array,$bait_more_info,$tf_more_info,$filename,$empty_bait,\@original_values,\@main_2D_arrayN);

($tfHits,$ignore,$limited_ignore)=&bleed_over($tfCount,$tfLookUp,$tfData);

($tf_restricted_hash,$tf_Limited_restricted_hash)=&restricted_Hashes($tfData,$ignore,$limited_ignore);
my $test_mode = "no";
my $type_of_list = "short";
my $type_of_list_end = "long";


if ($test_mode eq "yes"){
	()=&test_mode($tfCount,$tfData,$ignore,$empty_spots_tf,$long_name,$empty_bait,$filename,$goldcalls);
}

if ($test_mode eq "no"){

	if ($type_of_list eq "short"){
	
		($finalTFcalls)=&shortList($tfCount,$tfData,$ignore,$empty_spots_tf,$long_name,$filename,$empty_bait,$tf_Limited_restricted_hash,$bait_more_info,$tf_more_info,$top_row_median_value);
		
		if ($type_of_list_end eq "long"){
			($finalTFcalls_not,$goldcalls_not)=&selective_lists($finalTFcalls,$goldcalls);
			()=&long_list($finalTFcalls,$tf_restricted_hash,$tfData,$tf_more_info,$bait_more_info,$filename,$plateType,$top_row_median_value);
		}
	}	
}

close (OUT);

}


()=&controler();
