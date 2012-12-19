#!/bin/sh
#$ -V
#$ -cwd
#$ -o $HOME/sge_jobs_output/sge_job.$JOB_ID.out -j y
#$ -S /bin/bash
#$ -m beas

#take workDir as input
plateImage=${1}
plateName=`basename ${plateImage}`

#setup necessary paths
jobDir=$HOME/scratch/jobid_$JOB_ID


#create scratch space
mkdir ${jobDir}

jobShell=${jobDir}/${plateName}.sh
	
#initialize result folders
resultData=${HOME}/nearline/${plateName}
resultDataNew=${HOME}/nearline/
#mkdir -p ${resultData}

xcoord=${plateName//png/_x_coords.txt}
ycoord=${plateName//png/_y_coords.txt}
# ---
echo "the coord file is ${xcoord}";
#copy input files to scratch
cp ${HOME}/${plateImage} ${jobDir}/.
cp ${jobDir}/${plateName} ${resultDataNew}/results/
cp ${HOME}/nearline/701/${xcoord} ${jobDir}/.
cp ${HOME}/nearline/701/${ycoord} ${jobDir}/.



#check to see if copy was successful
if [ ! -f ${jobDir}/${plateName} ]
then
	echo "ERROR - could not find the file (${jobDir}/${plateName})\nexiting.\n";
	exit
fi

# now do something
echo "perl /home/dialloa/magicPlate_manual.pl -i ${jobDir}/${plateName} -xgo ${jobDir}/${xcoord} -ygo ${jobDir}/${ycoord} -nhood 4 -r 10 -min 2 -max 120 -d 0" >> ${jobShell}


chmod 744 ${jobShell}
${jobShell}


# now copy results back to nearline
data_ending=${plateName//.png/_DATA/}

#Creating varriables so that I can copy over the results.
data_folder=$jobDir/${data_ending}
median_colony=${plateName//png/red.median.colony.txt}
median_all=${plateName//png/red.median.all.txt}
size_values=${plateName//png/size.txt}
final_image=${plateName//png/png.clean.centers.lines.outer.final.png}

#Copying over the results to nearline

cp ${jobDir}/${final_image} ${resultDataNew}/results/.
cp ${data_folder}${median_all} ${resultDataNew}/results/.
cp ${data_folder}${median_colony} ${resultDataNew}/results/.
cp ${data_folder}${size_values} ${resultDataNew}/results/.
#all done now