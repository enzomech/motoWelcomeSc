#!/bin/bash


directory="./motoRun"
sleep_time=0.02

find "$directory" -name "*Run*.txt" | sort -Vr | while read fichier; do
	clear
        cat "$fichier"
	sleep $sleep_time
done

clear

cat motoEnd.txt
