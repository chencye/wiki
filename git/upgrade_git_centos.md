<!-- --- title: Centos 6.5升级到Git2.8.2的步骤 -->
<!-- --- tags: git linux -->

[[_TOC_]]

**参考： [Centos 6.5升级到Git2.1.2的步骤](http://www.111cn.net/sys/CentOS/82593.htm)**  

# 安装需求
`yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel`  
`yum install  gcc perl-ExtUtils-MakeMaker`  

# 卸载Centos自带的git
`yum remove git`  

# 下载git最新版本
`cd /usr/src`  
`wget https://www.kernel.org/pub/software/scm/git/git-2.8.2.tar.gz`  
`tar xzf git-2.1.2.tar.gz`  

# 安装git
`cd git-2.1.2`  
`make prefix=/usr/local/git all`  
`make prefix=/usr/local/git install`  

# 添加到环境变量中
`echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc`  
`source /etc/bashrc`  

# 查看版本号
`git --version`  