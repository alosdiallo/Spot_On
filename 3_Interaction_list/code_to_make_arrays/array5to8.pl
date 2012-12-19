#!/usr/bin/perl
use English;


my @alphab = (A,A,A,A,B,B,B,B,C,C,C,C,D,D,D,D,E,E,E,E,F,F,F,F,G,G,G,G,H,H,H,H);
my @newone = (5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6,5,5,6,6);
my @newthree = (7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8,7,7,8,8);
my @onetwo = (1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2);
my @threefour = (3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3,4,3);
my @m = (1 .. 12);
my $col = 0;
my @j = (1..48);
my $k = 32;
my $g = 0;
my $row = 0;
my $size = scalar @j;
my $p = 0;
my $g = 0;
my $value = 0;
my $count = 0;
my $counter = 0;
my $holder = 0;

for($row = 0; $row< $k; $row ++){
	$value = 0;
	$count = 0;
	if($holder > 3)
	{
		$holder = 0;
	}
		if($holder > 1)
		{
			for($col = 0; $col < $size; $col ++){
			if ($row % 2)
			{
				
				if($count > 3)
				{
					$value ++;
					$count = 0;
				}
				print  $newthree[$col],"-",$alphab[$row],$m[$value],"-",$threefour[$col]," ";
				$count ++;
				
			
			}
			else
			{
				if($count > 3)
				{
					$value ++;
					$count = 0;
				}
				print  $newthree[$col],"-",$alphab[$row],$m[$value],"-",$onetwo[$col], " ";	
				$count ++;
				
			} 
			
			if($value == 13)
			{
				$value = 0;
				$count = 0;
			}
			}
		}
		else
		{
		for($col = 0; $col < $size; $col ++)
		{
			if ($row % 2)
			{
				
				if($count > 3)
				{
					$value ++;
					$count = 0;
				}
				print  $newone[$col],"-",$alphab[$row],$m[$value],"-",$threefour[$col]," ";
				$count ++;
				
				
			}
			else
			{
				if($count > 3)
				{
					$value ++;
					$count = 0;
				}
				print  $newone[$col],"-",$alphab[$row],$m[$value],"-",$onetwo[$col], " ";	
				$count ++;
			} 
			
			if($value == 13)
			{
				$value = 0;
				$count = 0;
				
			}
		}
		}
	
	$holder ++;
	print "\n";
}