#!/bin/bash

function unzip_file(){
    find /mnt/windows/output -name "*.zip" -print0 | while read -d $'\0' zipfile
    do
	unzipped_filename=`echo ${zipfile} | tr -d .zip`
	unzipped_dir=`dirname ${zipfile}`
        if [[ ! -f ${unzipped_filename} ]];then
            echo "unzipping... ${zipfile}"
            unzip -n ${zipfile} -d ${unzipped_dir}
	    mv ${zipfile} ${zipfile}opened
	fi
    done
}

function extract_elf(){
    find /mnt/windows/output -name "*.bin" -print0 | while read -d $'\0' file
    do
        dir=`dirname ${file}`
        newfilename=`dirname ${file} | sed "s/\/mnt\/windows\/output\//_/g" | tr / _`
	newfilepath=${dir}/${newfilename}.bin
	if [[ ! -f ${dir}/${newfilename}.bin ]];then
            mv ${file} ${newfilepath}
	fi
	echo `ls ${newfilepath}`
	
	file=${newfilepath}
        extraction=`/root/Documents/firmware-mod-kit/src/binwalk-2.1.1/src/scripts/binwalk -eM ${file} -C ${dir}
	cd ${dir}*.extracted

	file . | while read -d $'\0' elf
        do
            filetype=`file ${elf}`
            if [[ ${filetype} =~ "ELF" ]]; then
                echo ${file} >> ${elf_output}
	    fi
        done
   done
}

elf_output="import_elf_firmware_ghidra.list"

if [[ -f ${elf_output} ]];then
    rm ${elf_output}
fi

#binwalkで分解したbinのファイルシステムからELFファイルを取り出す
#unzip_file
extract_elf
today=`date +%F`
if [[ ! -F /mnt/windows/analysis/${today} ]];then
     mkdir /mnt/windows/analysis/${today}
     cp import*.list /mnt/windows/analysis/${today}
fi
cp import*.list /mnt/windows/analysis/
