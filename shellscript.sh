#!/bin/bash


#Run with '/Users/linasundqvist/Desktop/DBS_thesis/patients/Infinity_3' {"'dx'"} 'DISTAL Minimal (Ewert 2017)' {"'STN motor'"} {"'STN limbic'"} 1

echo $1
echo $2 
echo $3
echo $4
echo $5
echo $6
echo $7
echo $8
echo $9
echo ${10}
echo ${11}


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



cd /Users/linasundqvist/Desktop/DBS_thesis/new_code

/Applications/MATLAB_R2021b.app/bin/matlab -nodisplay -r "main('$1',$hand,'$3',$4,'$5',$targets,$constraints,$8,$9,${10},'${11}'); exit"


exit 1

#system('./shellscript.sh ''/Users/linasundqvist/Desktop/DBS_thesis/patients/Infinity_3'' ''dx,sin'' ''S:t Jude 1331'' ''[120,0]'' ''DISTAL Minimal (Ewert 2017)'' ''STN motor'' ''STN limbic,STN associative'' 200 90 1 ''native''')