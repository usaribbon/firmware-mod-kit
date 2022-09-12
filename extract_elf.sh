#!/bin/bash

function unzip_file(){
    find /mnt/raw_firmwares/raw -name "*.zip" -print0 | while read -d $'\0' zipfile
    do
	unzipped_filename=$(echo ${zipfile} | tr -d .zip)
	unzipped_dir=$(dirname ${zipfile})
        if [[ ! -f ${unzipped_filename} ]];then
            echo "unzipping... ${zipfile}"
            unzip -n ${zipfile} -d ${unzipped_dir}
	    mv ${zipfile} ${zipfile}opened
	fi
    done
}

function extract_elf(){
    find /mnt/raw_firmwares/raw -name "*.bin" -print0 | while read -d $'\0' file
    do
        dir=$(dirname ${file})
        #newfilename=$(dirname ${file} | sed "s/\/mnt\/raw_firmwares\/output\//_/g" | tr / _)
	#newfilepath=${dir}/${newfilename}.bin
	#if [[ ! -f ${dir}/${newfilename}.bin ]];then
        #    mv ${file} ${newfilepath}
	#fi
	#echo $(ls ${newfilepath})
	
	#file=${newfilepath}
        filename=$(basename ${file})
        extraction=$(/root/firmware-mod-kit/src/binwalk-2.1.1/src/scripts/binwalk -eM ${file} -C /mnt/raw_firmwares/extracted)
	cd /mnt/raw_firmwares/extracted/_${filename}.extracted

    elf_output=/mnt/raw_firmwares/elf/elf_${filename}.list
	file . | while read -d $'\0' elf
        do
            filetype=$(file ${elf})
            if [[ ${filetype} =~ "ELF" ]]; then
                echo ${file} >> ${elf_output}
	    fi
        done
   done
}


#binwalkで分解したbinのファイルシステムからELFファイルを取り出す
#unzip_file
extract_elf
