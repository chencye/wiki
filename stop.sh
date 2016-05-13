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

#--查找进程------------------------------------------------------------------

processName="gollum --port 4567 --allow-uploads --css --live-preview"

if [ $# -gt 0 ] && [ -n "$1" ]; then
    processName="$1"
fi

pid=(`ps -ef | grep "$processName" | grep -v grep |  awk '{print $2}'`)

pidCount=${#pid[@]}

echo -e "  --->  查找到$pidCount个进程\n"

#--如果查找到多个进程，则输出所有PID，不结束进程；否则，如果只有一个进程，则将其结束---------------

if [ $pidCount -eq 1 ]; then

    echo -e "  --->  准备杀死进程："
    echo -e "  --->  `ps -ef | grep "$processName" | grep -v grep`\n"

    kill -9 $pid

    if [ $? -eq 0 ]; then
        echo -e "  --->  进程$pid已结束\n"
    else
        echo -e "  --->  结束进程$[pid]进行失败！\n"
    fi

elif [ $pidCount -eq 0 ]; then

    echo -e "  --->  未查找到与【$processName】相关的进程。\n"

else

    echo -e "  --->  查找到多个与【$processName】相关的进程，PID如下：\n"
    for id in ${pid[*]}
    {
        echo -e "  --->  ${id}"
    }
    echo -e "\n"

fi

echo -e "\n"

