#!/bin/bash

echo -e "\n\n"

#--获取并进行目录-----------------------------------------------------------

shell="$0"
dir=${shell%/*}

echo -e "  --->  脚本所在路径：$dir\n"

if [ "${dir:0:1}" != "/" ]; then

    dir=${PWD}
    echo -e "  --->  非绝对路径，获取PWD路径：$dir\n"

fi

cd "$dir"
echo -e "  --->  进入目录：$dir\n"

#--启动---------------------------------------------
java -jar wikiscan.jar

