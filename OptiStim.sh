#!/bin/bash -l

##Run like sbatch Pipeline.sh '/proj/sens2022530/patient_data/PilotDBS_1' {"'dx'"} 'DISTAL Minimal (Ewert 2017)' {"'STN motor'"} {"'STN limbic'"} 2

#SBATCH -A sens2022530
#SBATCH -n 8
#SBATCH -t 01:40:00

module load comsol/6.0
module load matlab/R2020b

#cd /proj/sens2022530/nobackup/code/new_code



matlab -nodesktop -nodisplay -nosplash -r "main('$1',$2,'$3',$4,$5,$6,$7,$8,$9 )"



