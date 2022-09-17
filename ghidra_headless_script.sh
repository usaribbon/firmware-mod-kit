#!/bin/bash

elfDir=/mnt/raw_firmwares/elf/
ghidraDir=/mnt/raw_firmwares/ghidraprj/
ghidraScriptDir=/mnt/firmddle-ghidrascript/
ghidraMainDir=$1

if [ $# != 1 ]; then
    echo 引数エラー: Ghidraディレクトリの場所を入力してください。例）/Users/test/ghidra_10.1.5_PUBLIC/
    exit 1
fi

find ${elfDir} -type f -print0 | while read -d $'\0' elflist
do
	prjName=$(basename ${elflist} .bin.list)
	echo ${prjName}
	echo ${ghidraDir}${prjName}'.rep'
	if [[ -f ${ghidraDir}${prjName}'.rep' ]]; then
		while read -r elfline;
		do
			/root/firmusa/ghidra_10.1.5_PUBLIC/support/analyzeHeadless ${ghidraDir} ${prjName} -scriptPath ${ghidraScriptDir} -postScript Yoda20220907_API_Headless.java -import ${elfPath} -overwrite
		done < ${elflist}
	else
		while read -r elfline;
		do
			/root/firmusa/ghidra_10.1.5_PUBLIC/support/analyzeHeadless ${ghidraDir} ${prjName} -scriptPath ${ghidraScriptDir} -postScript Yoda20220907_API_Headless.java -import ${elfPath}
		done < ${elflist}
	fi
done
