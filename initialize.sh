#!/bin/bash
# Filename initialize.sh
# auto Initialize system
# by authors linling 20210325

## 变量赋值
### 主机名
read -p "Please enter a host name: " -t 30 hostname
echo $hostname
### IP地址
read -p "Please enter IP address: " -t 30 IP
echo $IP

## 配置主机名
hostname $hostname
hostnamectl set-hostname $hostname

## 配置静态IP
### 备份
cp /etc/sysconfig/network-scripts/ifcfg-ens192 /etc/sysconfig/network-scripts/ifcfg-ens192.`date +%Y-%m-%d`

### 配置
cat<<-EOF > /etc/sysconfig/network-scripts/ifcfg-ens192
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=$IP
NETMASK=255.255.255.0
GATEWAY=192.168.3.1
DEFROUTE="yes"
NAME="ens192"
DEVICE="ens192"
ONBOOT="yes"
DNS1=192.168.3.1
EOF

### 重启
systemctl restart network

## host文件
echo "192.168.3.149 ora0.ermu.com" >> /etc/hosts
echo "192.168.3.150 ora1.ermu.com" >> /etc/hosts
echo "192.168.3.151 ora2.ermu.com" >> /etc/hosts
echo "192.168.3.152 ora3.ermu.com" >> /etc/hosts

## 关闭selinux
### 备份配置文件
cp /etc/selinux/config /etc/selinux/config.`date +%Y-%m-%d`
### 关闭
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

## 配置yum源
### 光盘挂载
mount /dev/sr0 /media/
echo "/dev/sr0 /media iso9660 defaults 0 0" >> /etc/fstab
### 备份
cp -r /etc/yum.repos.d/ /etc/yum.repos.d.`date +%Y-%m-%d`
### 配置
rm -rf /etc/yum.repos.d/*
cat<<\EOF > /etc/yum.repos.d/dvd.repo
[dvd]
name=dvd
baseurl=file:///media
enabled=1
gpgcheck=0
EOF
### 清理并显示所有仓库
sleep 10
yum clean all
yum repolist

## 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
