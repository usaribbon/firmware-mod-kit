#!/bin/bash

function get_load_address(){
   /root/Documents/firmware-mod-kit/extract-firmware.sh $1 | while read line;
    do
	if [[ ${line} =~ "filesystem" ]]; then
	    echo ${line} | grep -o 0x\\S*
	    return 0
	fi
    done

}

function get_endian(){
    if [[ $@ =~ "little" ]]; then
        echo "LE"
    elif [[ $@ =~ "big" ]]; then
        echo "BE"
    else
        echo "LE"
    fi
}

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

function get_loading_information(){
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
        rm -rf /root/Documents/firmware-mod-kit/fmk
        arch=$(file ${file})
        if [[ $arch =~ "ELF" ]]; then
            echo ${file} >> ${elf_output}
        elif [[ $arch =~ "ARM"  ]]; then
            endian=`get_endian ${arch}`
	    load_address=`get_load_address ${file}`
	    echo "${file} ARM:${endian}:32:v8 ${load_address}" >> ${rawbinary_output}
        elif [[ $arch =~ "MIPS"  ]]; then
            endian=`get_endian ${arch}`
	    load_address=`get_load_address ${file}`
	    echo "${file} MIPS:${endian}:32:default ${load_address}" >> ${rawbinary_output}
        else
            echo "${arch}" >> ${abort_output}
	   
        fi
   done

    find /mnt/windows/output -name "*.exe" -print0 | while read -d $'\0' file
    do
	echo "${file}" >> ${exe_output}
    done	
}

elf_output="import_elf_firmware_ghidra.list"
rawbinary_output="import_rawbinary_firmware_ghidra.list"
abort_output="import_firmware_ghidra_abort.list"
exe_output="import_exefirmware_ghidra_.list"

if [[ -f ${elf_output} ]];then
    rm ${elf_output}
fi
if [[ -f ${rawbinary_output} ]];then
    rm ${rawbinary_output}
fi

if [[ -f ${abort_output} ]];then
    rm ${abort_output}
fi
if [[ -f ${exe_output} ]];then
    rm ${exe_output}
fi


#Raw Binaryのロード情報を取得する
#ELF, MIPS, ARMならロード情報を取得し，それ以外は無視する
unzip_file
get_loading_information
today=`date +%F`
if [[ ! -F /mnt/windows/analysis/${today} ]];then
     mkdir /mnt/windows/analysis/${today}
     cp import*.list /mnt/windows/analysis/${today}
fi
cp import*.list /mnt/windows/analysis/
