#!/bin/bash 

pkill -f "comsol mphser"
#module load comsol/6.0

#comsol mphserver -silent &
comsolmphserver.exe -silent &

max=$1
for ((i=0;i<$max;i++))
    do
        
	let "prt=2036+${i}"
	
	comsol -np 1 server -port $prt -silent &
	echo $prt
done

echo 'waiting for ports to start listening ...'
while ! nc -z localhost 2036; do
	sleep 1 
    echo 'waiting...'
done

