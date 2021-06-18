#!/bin/bash
# Filename oracle_install.sh
# auto Oracle 11g database installation
# by authors linling 20210326

## 前提说明
echo -e '\033[32mInitialize. sh is executed in the initialization environment\033[0m'

## 软件包安装
yum install binutils -y
yum install compat-libcap1 -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc.i686 -y
yum install glibc-devel -y
yum install glibc-devel.i686 -y
yum install ksh -y
yum install libgcc -y
yum install libgcc.i686 -y
yum install libstdc++ -y
yum install libstdc++.i686 -y
yum install libstdc++-devel -y
yum install libstdc++-devel.i686 -y
yum install libaio -y
yum install libaio.i686 -y
yum install libaio-devel -y
yum install libaio-devel.i686 -y
yum install libXext -y
yum install libXext.i686 -y
yum install libXtst -y
yum install libXtst.i686 -y
yum install libX11 -y
yum install libX11.i686 -y
yum install libXau -y
yum install libXau.i686 -y
yum install libxcb -y
yum install libxcb.i686 -y
yum install libXi -y
yum install libXi.i686 -y
yum install make -y
yum install sysstat -y
yum install unixODBC -y
yum install unixODBC-devel -y

## 目录创建
mkdir /oracle
mkdir /oraarchlog

## 用户与组创建
groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
useradd -g oinstall -G dba,oper oracle
mkdir -p /oracle/app/oracle
chown -R oracle:oinstall /oracle/app/oracle
chmod -R 755 /oracle/app/oracle
chown -R oracle:oinstall /oraarchlog
chown -R oracle:oinstall /oracle
chmod -R 755 /oraarchlog
echo "oracle" | passwd --stdin oracle

## 系统参数
cat<<\EOF >> /etc/sysctl.conf
#ORACLE_SETTING
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 687194767360 
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
#vm.nr_hugepages= 1011
EOF
sysctl -p
cat<<\EOF >> /etc/security/limits.conf
oracle              soft    nproc      2047
oracle              hard    nproc      16384
oracle              soft    nofile     1024
oracle              hard    nofile     65536
oracle   			soft    stack      10240
oracle  			hard    stack      32768
*                   soft    memlock    1900000
*                   hard    memlock    1900000
EOF
cat<<\EOF >> /etc/security/limits.d/90-nproc.conf
*     -      nproc      16384
EOF
cat<<\EOF >> /etc/pam.d/login
session    required     pam_limits.so
EOF

## 插件安装
tar -xzvf rlwrap-0.41.tar.gz 
cd rlwrap-0.41
./configure 
make & make install
cd ../
rm -rf rlwrap-0.41.tar.gz

## Oracle用户环境变量
cat<<\EOF >> /home/oracle/.bash_profile
PS1="[`whoami`@`hostname`:"'$PWD]$'
export PS1
alias sqlplus="rlwrap sqlplus"
alias rman="rlwrap rman"
export TMP=/tmp
export LANG=en_US
export TMPDIR=$TMP
export ORACLE_HOSTNAME=
export ORACLE_UNQNAME=ora11g
ORACLE_BASE=/oracle/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1; export ORACLE_HOME
ORACLE_SID=ora11g; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"; export NLS_DATE_FORMAT
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK;export NLS_LANG
PATH=.:$PATH:$HOME/bin:$ORACLE_BASE/product/11.2.0/db_1/bin:$ORACLE_HOME/bin; export PATH
THREADS_FLAG=native; export THREADS_FLAG
if [ $USER = "oracle" ] || [ $USER = "grid" ]; then
        if [ $SHELL = "/bin/ksh" ]; then
            ulimit -p 16384
              ulimit -n 65536
  else
   ulimit -u 16384 -n 65536
      fi
    umask 022
fi
EOF
su - oracle -c source /home/oracle/.bash_profile
