<!-- --- title: centos6.5下安装gollum -->
<!-- --- tags: git gollum linux centos -->

[[_TOC_]]

参考：[centos6.4下安装gollum(使用markdown的wiki)](http://www.phperz.com/article/14/1223/42719.html)

# 1. gollum介绍
A simple, Git-powered wiki with a sweet API and local frontend.  
gollum是基于git的wiki系统的构造工具，简单实用。允许使用多种格式，有多种编辑的方式。  

* lightweight  
* use Markdown  
* web-based  
* Can be easily stored in Git  

[https://github.com/gollum/gollum](https://github.com/gollum/gollum)


# 2. gollum安装

## 2.1 安装最新版本git
[Centos 6.5升级到Git2.8.2的步骤](/git/upgrade_git_centos)  

## 2.2 安装依赖
`yum -y install ruby ruby-devel rubygems make gcc libxml2-devel libxslt-devel`  

## 2.3 安装高版本ruby
由于默认使用的ruby版本太低，我们需要安装高版本的ruby，使用rvm来安装。  

### 2.3.1 安装rvm  
`curl -sSL https://get.rvm.io | bash`  
待rvm安装成功之后，安装高版本的ruby，安装的是2.3.0
`rvm install 2.3.0 --verify-downloads 2 --create`  

### 2.3.2 设置默认ruby版本
安装高版本的ruby之后，需要把高版本ruby设为默认的ruby版本
`rvm use 2.3.0 --default`  

## 2.4 安装gollum  
`gem install`  

# 3. 安装markdown语法解析
`gem install redcarpet github-markdown`  

# 4. 开放端口

参数：[CentOS: 开放80、22、3306端口操作](http://blog.sina.com.cn/s/blog_3eba8f1c0100tsox.html)  

1. 开放端口4567   
`/sbin/iptables -I INPUT -p tcp --dport 4567 -j ACCEPT`  
2. 将更改进行保存  
`/etc/rc.d/init.d/iptables save`  
3. 重启防火墙以便改动生效:(或者直接重启系统)  
`/etc/init.d/iptables restart`  
4. 查看防火墙信息
`/etc/init.d/iptables status`  

# 5. 初始化

## 5.1 初始化目录
[Linux 文件夹给与用户权限例子](http://www.111cn.net/sys/linux/67670.htm)  
`mkdir /work/wiki/content/`  
`mkdir /work/wiki/logs/`  
`mkdir /work/wiki/scan/`  
`touch restart.sh`  
`touch stop.sh`  

## 5.2 git初始化
`cd /work/wiki/content/`  
`git init`  

## 5.3 设置gollum的定义样式  
custom.css  
```css
#wiki-wrapper {
  max-width: 70%;
}

.has-sidebar #wiki-body {
  width: 80%;
}

#wiki-sidebar {
  width: 15%;
}

.markdown-body {
  padding: 0px;
}

#head h1 {
  font-size: 1.5em;
  float: left;
  line-height: normal;
  margin: 0;
  margin-bottom: 20px;
  padding: 0 0 0 0.667em;
}

li > ul {
  margin: 0 !important;
}

.center90 {
	margin: 0 auto !important;
	width: 90%;
	display: table !important;
}

.center80 {
	margin: 0 auto !important;
	width: 80%;
	display: table !important;
}
```

git提交  
`git add *`  
`git commit`  

## 5.4 编写启停脚本
`vi /work/wiki/restart.sh`
```shell
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

processName="gollum --port 4567 --allow-uploads --css --no-live-preview"
logFile="$dir/gollum.log"

#--执行停止操作-------------------------------------------------------------

stopShell="stop.sh"
echo -e "\n\n"
echo -e "  --->  --->  --->  --->  --->  执行$stopShell..."
source $stopShell "$processName"
echo -e "  --->  --->  --->  --->  --->  执行$stopShell完毕！"
echo -e "\n\n"

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

```

`vi /work/wiki/stop.sh`  
```shell
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

processName="gollum --port 4567 --allow-uploads --css --no-live-preview"

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

```