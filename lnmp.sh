#!/bin/bash
touch /opt/install.log 					
rm -rf /etc/yum.repos.d/*.repo 			#清空无效的YUM配置文件
echo "[yum1]
name=yum1
baseurl=ftp://201.1.2.254/rhel7/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/yum1.repo    	#新建YUM仓库

N=$(yum repolist | awk '/repolist/{print $2}' | sed 's/,//')
if [ $N -le 0 ];then
    echo "yum 不可用"
    exit
fi
echo "安装中请稍后。。。"
tar -xf /root/lnmp_soft.tar.gz
yum -y install gcc pcre-devel openssl-devel  &>> /opt/install.log 	#安装Nginx依赖包
useradd -s /sbin/nologin nginx
tar -xf /root/lnmp_soft/nginx-1.12.2.tar.gz     #先把lump_soft压缩包解压到/root下
						#解压缩Nginx安装包
cd nginx-1.12.2
./configure --prefix=/usr/local/nginx  --user=nginx --group=nginx      \
--with-http_ssl_module --with-stream	 \
--with-http_stub_status_module 	 &> /dev/null		#配置Nginx源码包
make && make install   &> /dev/null 		#编译Nginx源码包
ln -s /usr/local/nginx/sbin/nginx /sbin/  &>> /opt/install.log
nginx   &>> /opt/install.log
[ $? -eq 0 ] && echo "Nginx服务开启成功!" || exit
yum -y install mariadb mariadb-server mariadb-devel  &>> /opt/install.log    #安装数据库文件
yum -y install php php-mysql	&>> /opt/install.log			     #安装Php
yum -y install /root/lnmp_soft/php-fpm-5.4.16-42.el7.x86_64.rpm  &>> /opt/install.log  #安装php-fpm
systemctl start php-fpm     &>> /opt/install.log 	#开启php-fpm服务
systemctl enable php-fpm
systemctl start mariadb	    &>> /opt/install.log	#开启数据库服务
systemctl enable mariadb
echo "安装完成！"
