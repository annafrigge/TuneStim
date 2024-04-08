#!/bin/bash -l

##Run like sbatch Pipeline.sh '/proj/sens2022530/patient_data/PilotDBS_1' {"'dx'"} 'DISTAL Minimal (Ewert 2017)' {"'STN motor'"} {"'STN limbic'"} 2

#SBATCH -A sens2022530
#SBATCH -n 2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH -t 01:40:00
#SBATCH --output=/castor/project/proj/nobackup/code/OptiStim/sbatchOutput/%j.out

module load comsol/6.0
module load matlab/R2020b

#cd /proj/sens2022530/nobackup/code/new_code

IFS=','
a='{'
b='}'

hand="${a}"
for i in ${2}
do
 var="'${i}'"
 hand=${hand}"${var}",
done
hand="${hand}${b}"
echo "$hand"

targets="${a}"
for i in ${6}
do
 var="'${i}'"
 targets=${targets}"${var}",
done
targets="${targets}${b}"
echo "$targets"


constraints="${a}"
for i in ${7}
do
 var="'${i}'"
 constraints=${constraints}"${var}",
done
constraints="${constraints}${b}"
echo "$constraints"


matlab -nodesktop -nodisplay -nosplash -r "main('$1',$hand,'$3',$4,'$5',$targets,$constraints,$8,$9,${10},'${11}',${12})"


#sbatch Pipeline.sh '/Users/linasundqvist/Desktop/DBS_thesis/patients/Infinity_3' 'dx,sin' 'S:t Jude 1331' '[120,0]' 'DISTAL Minimal (Ewert 2017)' 'STN motor' 'STN limbic,STN associative' 200 90 1 'native'

