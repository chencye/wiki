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

#--定义需要启动的程序及日志文件---------------------------------------------

processName="gollum --port 4567 --allow-uploads --css --live-preview"
logFile="$dir/gollum.log"

#--查找进程------------------------------------------------------------------

pid=(`ps -ef | grep "$processName" | grep -v grep |  awk '{print $2}'`)

pidCount=${#pid[@]}

echo -e "  --->  查找到$pidCount个进程\n"

#--如果查找到多个进程，则输出所有PID，不结束进程；否则，如果只有一个进程，则将其结束-------

isStartable=0

if [ $pidCount -eq 1 ]; then

    echo -e "  --->  准备杀死进程："
    echo -e "  --->  `ps -ef | grep "$processName" | grep -v grep`\n"

    kill -9 $pid

    if [ $? -eq 0 ]; then
        echo -e "  --->  进程$pid已结束\n"
		isStartable=1
    else
        echo -e "  --->  结束进程$[pid]进行失败！\n"
    fi

elif [ $pidCount -eq 0 ]; then

    echo -e "  --->  未查找到与【$processName】相关的进程。\n"
	isStartable=1

else

    echo -e "  --->  查找到多个与【$processName】相关的进程，PID如下：\n"
    for id in ${pid[*]}
    {
        echo -e "  --->  ${id}"
    }
    echo -e "\n"

fi

#--如果旧进程已杀死或未查找到旧进程，则启动--------------------------------------

if [ $isStartable -eq 1 ]; then
    #--清理旧日志文件-----------------------------------------------------------

    rm -rf $logFile
    echo -e "  --->  删除旧日志文件：$logFile\n"
    touch $logFile
    echo -e "  --->  创建日志文件：$logFile\n"

    #--启动---------------------------------------------------------------------

    nohup $processName > $logFile 2>&1 &
    echo -e "  --->  启动完毕!\n"

    echo -e "\n"

    #--显示日志------------------------------------------------------------------

    if [ $# -gt 0 ]; then

        sleepTime=$1
        echo -e "  --->  $sleepTime秒后，显示日志文件：$logFile\n"
        sleep $sleepTime
        cat $logFile

    fi

else

    echo -e "旧进程关闭失败，不执行启动！\n"    

fi

echo -e "\n"
