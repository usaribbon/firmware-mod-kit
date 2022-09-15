#!/bin/bash

elfDir=/mnt/raw_firmwares/elf/
ghidraDir=/mnt/raw_firmwares/ghidraprj/

find ${elfDir} -type f -print0 | while read -d $'\0' elflist
do
	prjName=$(basename ${elflist} .bin.list)
	echo ${prjName}
	echo ${ghidraDir}${prjName}'.rep'
	if [[ -f ${ghidraDir}${prjName}'.rep' ]]; then
		echo 'hell'
	else
		while read -r elfline;
		do
			echo ${elfline}
		   /root/firmusa/ghidra_10.1.5_PUBLIC/support/analyzeHeadless ${ghidraDir} ${prjName} -import ${elfline}
		done < ${elflist}
		
	fi
done