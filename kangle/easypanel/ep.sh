#/bin/sh
KANGLE_VERSION="3.5.19.1"
PHP_VERSION="5.2.17"
EASYPANEL_VERSION="2.6.26"
PUREFTP_VERSION="1.0.36"
PREFIX="/vhs/kangle"
CONFIG_FILES="/ext/tpl_php52/php-templete.ini"
DOWNLOAD_BASE_URL="https://github.kangle.icu";
restore_config()
{
        for p in $CONFIG_FILES; do
        if test -f $PREFIX$p.bak; then
                mv $PREFIX$p.bak $PREFIX$p
                if test $? != 0; then
                        echo "cann't restore config file $PREFIX$p"
                        exit 1
                fi

        fi
        done

}
#backup config file
for p in $CONFIG_FILES; do
        if test -f $PREFIX$p; then
                cp $PREFIX$p $PREFIX$p.bak
                if test $? != 0; then
                        echo "cann't create config file $PREFIX$p.bak to backup"
                        exit 1
                fi
        fi
done
SYS="x86"
if test `arch` = "x86_64"; then
	SYS="x86_64"
fi

LIBDIR="lib"
if test `arch` = "x86_64"; then
	LIBDIR="lib64"
fi

SYSVERSION="6"
if test `ldd --version|head -1|awk '{print $NF;}'` = "2.5" ; then
        SYSVERSION="5"
fi

#PHP_PACKAGE_NAME='php'
#if test `lsb_release -sr|cut -b 1` = '5' ; then
#        PHP_PACKAGE_NAME='php53'
#fi
#$2 local_ver $1 kangle_ver
rrr=''
function get_version
{
	a=`echo $1|grep -E "[0-9]+\.[0-9]+(\.[0-9]+)?" -o`
	x=`echo $a|grep -E "^[0-9]+" -o`
	y_temp=`echo $a|grep -E "\.[0-9]+(\.)?" -o`
	y=`echo $y_temp|grep -E "[0-9]+" -o`
	z=`echo $a|grep -E "[0-9]+$" -o`
	#r=$(( $(( x * 1000)) + $(( y * 100 )) + z ))
	r1=`expr $x \* 1000`
	r2=`expr $y \* 100`
	r=`expr $r1 \+ $r2 \+ $z`
	rrr=$r;
	return $r;
}
function check_ver
{
	get_version $1
	new=$rrr
	get_version $2
	old=$rrr
	if [ $new \> $old ] ; then
		return 1;
	fi
	return 2;
}
#setup kangle
function setup_kangle
{
	if [ -f /vhs/kangle/bin/kangle ] ; then
		K_LOCAL_VER=`/vhs/kangle/bin/kangle -v|grep -E "[0-9][.][0-9][.][0-9]" -o`
		if [ "$K_LOCAL_VER" == "" ] ; then 
			K_LOCAL_VER_TEMP=`/vhs/kangle/bin/kangle -v|grep -E "[/][0-9][.][0-9]" -o`
			K_LOCAL_VER=`echo $K_LOCAL_VER_TEMP|grep -E "[0-9][.][0-9]" -o`
		fi
		echo "k_local_ver="$K_LOCAL_VER
		echo "kangle_version="$KANGLE_VERSION
       		if [ "$K_LOCAL_VER" != "" ] ; then
               		check_ver $KANGLE_VERSION $K_LOCAL_VER
			check=$?
			if [ "$check" == 2 ] ; then
               		       echo "kangle check="$check
				 return;
            		fi
    		fi
	fi
	KANGLE_URL="$DOWNLOAD_BASE_URL/kangle/src/kangle-$KANGLE_VERSION.tar.gz"
	if [  -f kangle-$KANGLE_VERSION.tar.gz ] ; then
		rm -f kangle-$KANGLE_VERSION.tar.gz
	fi	
	wget --no-check-certificate $KANGLE_URL 
	if [ $? != 0 ] ; then
		exit $?
	fi
	tar xzf kangle-$KANGLE_VERSION.tar.gz
	cd kangle-$KANGLE_VERSION
	find|xargs touch
	./configure --prefix=/vhs/kangle --enable-vh-limit --enable-disk-cache --enable-ipv6 --enable-ssl --enable-http2
	if [ $? != 0 ] ; then
                 exit $?
        fi
	make
	if [ $? != 0 ] ; then
	         exit $?
	fi
	make install
	if [ $? != 0 ] ; then
		exit $?
	else
		echo "kangle-$KANGLE_VERSION is install success........................................................................................"
	fi
	cd -
}

#prepare for system
function setup_system
{
	yum -y install wget make gcc gcc-c++
	yum -y install pcre-devel zlib-devel
	yum -y install openssl-devel sqlite-devel
	yum -y install quota unzip bzip2 libaio-devel
}
function stat_iptables
{
	if [ !  -f /etc/init.d/iptables ] ; then
		return;
	fi
	service iptables stop 2&> /dev/null
	chkconfig iptables off 2&> /dev/null
	/etc/init.d/iptables stop 2&> /dev/null
	/etc/init.d/iptables save
	return;
	/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
	/sbin/iptables -I INPUT -p tcp --dport 3311 -j ACCEPT
	/sbin/iptables -I INPUT -p tcp --dport 3312 -j ACCEPT
	/sbin/iptables -I INPUT -p tcp --dport 3313 -j ACCEPT
	/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
	/etc/rc.d/init.d/iptables save
}
#setup mysql
function setup_mysql
{
	if [ -d /var/lib/mysql/ ] ; then
		return;
	fi
        yum -y install MariaDB-client MariaDB-server MariaDB-devel
        if [ $? != 0 ] ; then
                exit $?
        fi
        /etc/init.d/mysql start
#	cat <<mayday
#       =========================================
#       please enter you  mysql root passwd:
#        =========================================
#mayday

#        echo -n "mysql root passwd:"
#        read mysql_passwd
#        /usr/bin/mysqladmin -u root password $mysql_passwd
#        if [ $? != 0 ] ; then
#                exit $?
#        else
#                echo "mysql-server is install success"
#        fi
	chkconfig mysql on
}
#setup php
function setup_php
{
	if [ -f /usr/bin/php-cgi ] ; then 
		return;
	fi
	PHP_PACKAGE_NAME="php53"
	if [ $1 != "" ] ; then
	        PHP_PACKAGE_NAME=$1
	fi
	yum -y remove php*
        yum -y install $PHP_PACKAGE_NAME-cli $PHP_PACKAGE_NAME-mysql  $PHP_PACKAGE_NAME-gd $PHP_PACKAGE_NAME-xml $PHP_PACKAGE_NAME-ldap $PHP_PACKAGE_NAME-mbstring $PHP_PACKAGE_NAME-bcmath $PHP_PACKAGE_NAME-pdo
	#\cp /etc/php.ini /etc/php.ini.bak
}

#setup easypanel
function setup_easypanel
{	
	#close selinux make  zend optimizer Effect
	setenforce 0
	sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
	if [ -f /vhs/kangle/nodewww/webftp/framework/runtime.php ] ; then
		E_LOCAL_VER=`cat /vhs/kangle/nodewww/webftp/framework/install.lock |grep -E "[.0-9]+" -o`
		if [ $E_LOCAL_VER != "" ] ; then
			echo "easypanel install version=$E_LOCAL_VER";
			echo "easypanel new version=$EASYPANEL_VERSION"
			check_ver $EASYPANEL_VERSION $E_LOCAL_VER
			easypanel_check=$?
       			if [ "$easypanel_check" == 2 ] ; then
               			echo "easypanel check=$easypanel_check"
				return;
     	 		fi
		fi
	fi
	if [ ! -f /var/lib/php/session ] ; then
                mkdir /var/lib/php/session
                chmod 777 /var/lib/php/session
                chmod a+t /var/lib/php/session
        fi
	chmod 700 $PREFIX/etc $PREFIX/var $PREFIX/nodewww/data	
	rm -rf easypanel-$EASYPANEL_VERSION-$SYS
	rm -rf easypanel-$EASYPANEL_VERSION-$SYS-$SYSVERSION.tar.gz
	EASYPANEL_URL="$DOWNLOAD_BASE_URL/kangle/easypanel/easypanel-$EASYPANEL_VERSION-$SYS-$SYSVERSION.tar.gz"
	EA_FILE_NAME="easypanel-$EASYPANEL_VERSION-$SYS-$SYSVERSION.tar.gz"
	wget --no-check-certificate $EASYPANEL_URL -O $EA_FILE_NAME -c
	if [ $? != 0 ] ; then
        	exit $?
	fi
	
	tar xzf $EA_FILE_NAME
	if [ $? != 0 ] ; then
        	exit $?
	fi
	/vhs/kangle/bin/kangle -q
	killall php-cgi
	\cp -a easypanel-$EASYPANEL_VERSION-$SYS/* /vhs/kangle/
	/vhs/kangle/bin/kangle
	if [ $? != 0 ] ; then
       		 exit $?
	fi
	#install ioncube.ini
	rm -f /etc/php.d/ioncube.ini

	if [ -f /vhs/kangle/etc/kanglestat ] ; then
		if [ ! -f /etc/init.d/kangle ] ; then
			\cp /vhs/kangle/etc/kanglestat /etc/init.d/kangle
		fi
		if [ ! -f /etc/rc.d/rc3.d/S66kangle ] ; then
			ln -s /etc/init.d/kangle /etc/rc.d/rc3.d/S66kangle
		        ln -s /etc/init.d/kangle /etc/rc.d/rc5.d/S66kangle
		fi
	fi
	#install mysql bin 
	yum -y install MariaDB-client MariaDB-server MariaDB-devel MariaDB
	# 1.6.3 add mysql && mysqldump to /vhs/kangle/bin
	if [ ! -f /vhs/kangle/bin/mysql ] ; then
                ln -s /usr/bin/mysql /vhs/kangle/bin/mysql
        fi
        if [ ! -f /vhs/kangle/bin/mysqldump ] ; then
                ln -s /usr/bin/mysqldump /vhs/kangle/bin/mysqldump
        fi
        if [ ! -f /vhs/kangle/bin/wget ] ; then
                ln -s /usr/bin/wget /vhs/kangle/bin/wget
        fi

	echo "easypanel-$EASYPANEL_VERSION-$SYS-$SYSVERSION setup success.............................................................................."
}
#setup pure-ftpd
function setup_pureftpd
{
	if [ -f /vhs/pureftpd/sbin/pure-ftpd ] ; then
		return;
	fi
	if [ ! -f /vhs/kangle/bin/pureftp_auth ] ; then
		echo "/vhs/kangle/pureftp_auth not found"
		exit;
	fi	
	del_proftpd
	DOWN_URL="$DOWNLOAD_BASE_URL/kangle/easypanel/source/pure-ftpd-$PUREFTP_VERSION.tar.gz"
	WGET_NEW_NAME="pure-ftpd-$PUREFTP_VERSION.tar.gz"
	wget --no-check-certificate $DOWN_URL -O $WGET_NEW_NAME -c
	if [ $? != 0 ] ; then 
		wget --no-check-certificate $K_DOWN_URL -o $WGET_NEW_NAME
		if [ $? != 0 ] ; then
			echo $? "wget pureftp failed,please manuanl setup pureftp"
			exit
		fi
	fi
	tar xzf $WGET_NEW_NAME
	cd pure-ftpd-$PUREFTP_VERSION
	./configure --prefix=/vhs/pure-ftpd with --with-extauth --with-throttling --with-peruserlimits
	make
	if [ $? != 0 ] ; then 
		exit $?
	fi
	make install
	cd -
	\cp /vhs/kangle/bin/pureftpd /etc/init.d/pureftpd
	if [ ! -f /etc/rc.d/rc3.d/S96pureftpd ] ; then
                ln -s /etc/init.d/pureftpd /etc/rc.d/rc3.d/S96pureftpd
                ln -s /etc/init.d/pureftpd /etc/rc.d/rc5.d/S96pureftpd
        fi
	/etc/init.d/pureftpd start
}

function del_proftpd
{
	#rm -f /etc/init.d/proftpd
	#rm -f /etc/rc.d/rc3.d/S96proftpd
	#rm -f /etc/rc.d/rc5.d/S96proftpd
	chkconfig proftpd off 2&> /dev/null
	killall proftpd
	
}

function setup_webalizer
{
	if [ ! -f /usr/bin/webalizer ] ; then
		yum -y install webalizer
	fi
	chkconfig httpd off 2&> /dev/null
	chkconfig nginx off 2&> /dev/null
	return;
}
function write_partner
{
	partner=`echo $0|grep -o "ep_[^.]*"|cut -b 4-`
	echo $partner > $PREFIX/nodewww/webftp/partner.txt
}
if test $SYSVERSION = '5' ; then
	#remove php 5.1
	yum -y remove php-*
	PHPNAME='php53'
else
	PHPNAME='php'
fi
ent=`/vhs/kangle/bin/kangle -v |grep "enterprise" -o`
echo "ent="$ent;
echo $PHPNAME
service httpd stop 2&> /dev/null
service nginx stop 2&> /dev/null
mkdir tmp
cd tmp
setup_system
#if [ -f /etc/init.d/httpd ] ;then
#	yum -y remove httpd*
#fi

setup_php $PHPNAME
if [ "$ent" == "" ] ; then
	setup_kangle
fi
#setup_easypanel $1 is php53.ini
setup_easypanel php53
#setup_proftpd
setup_pureftpd
setup_webalizer
stat_iptables
setup_mysql
restore_config
write_partner
if [ ! -f /etc/php.d/ioncube.ini ] ; then
	\cp /vhs/kangle/bin/ioncube.ini /etc/php.d/ioncube.ini
fi
wget --no-check-certificate  http://localhost:3312/upgrade.php -O /dev/null -q
rm -rf /vhs/kangle/www/index.html
wget --no-check-certificate https://github.kangle.icu/easypanel/index.html -O /vhs/kangle/www/index.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/kfinfo.html
wget --no-check-certificate https://github.kangle.icu/easypanel/kfinfo.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/kfinfo.html
rm -rf /vhs/kangle/nodewww/dbadmin/mysql/main.php
wget --no-check-certificate https://github.kangle.icu/easypanel/main.php -O /vhs/kangle/nodewww/dbadmin/mysql/main.php
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/common/product.html
wget --no-check-certificate https://github.kangle.icu/easypanel/product.html -O /vhs/kangle/nodewww/webftp/admin/view/default/common/product.html
rm -rf /vhs/kangle/ext/webalizer.xml
wget --no-check-certificate https://github.kangle.icu/easypanel/log_gz.xml -O /vhs/kangle/ext/log_gz.xml
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/top.html
wget --no-check-certificate https://github.kangle.icu/easypanel/top.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/top.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/cacheclean/cachecleanfrom.html
wget --no-check-certificate https://github.kangle.icu/easypanel/cachecleanfrom.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/cacheclean/cachecleanfrom.html
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/nodes/addnode.html
wget --no-check-certificate https://github.kangle.icu/easypanel/addnode.html -O /vhs/kangle/nodewww/webftp/admin/view/default/nodes/addnode.html
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/scripts/func.js
wget --no-check-certificate https://github.kangle.icu/easypanel/func.js -O /vhs/kangle/nodewww/webftp/admin/view/default/scripts/func.js
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/virtualhost/virtualhost.html
wget --no-check-certificate https://github.kangle.icu/easypanel/virtualhost.html -O /vhs/kangle/nodewww/webftp/admin/view/default/virtualhost/virtualhost.html
rm -rf /vhs/kangle/nodewww/webftp/admin/cnzz.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/cnzz.html
wget --no-check-certificate https://github.kangle.icu/easypanel/cnzz.html -O /vhs/kangle/nodewww/webftp/admin/cnzz.html
\cp -f /vhs/kangle/nodewww/webftp/admin/cnzz.html /vhs/kangle/nodewww/webftp/vhost/cnzz.html
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/common/foot.html
wget --no-check-certificate https://github.kangle.icu/easypanel/admin/foot.html -O /vhs/kangle/nodewww/webftp/admin/view/default/common/foot.html
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/main.html
wget --no-check-certificate https://github.kangle.icu/easypanel/admin/main.html -O /vhs/kangle/nodewww/webftp/admin/view/default/main.html
rm -rf /vhs/kangle/nodewww/webftp/admin/view/default/login_error.html
wget --no-check-certificate https://github.kangle.icu/easypanel/admin/login_error.html -O /vhs/kangle/nodewww/webftp/admin/view/default/login_error.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/common/foot.html
wget --no-check-certificate https://github.kangle.icu/easypanel/vhost/foot.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/common/foot.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/common/head.html
wget --no-check-certificate https://github.kangle.icu/easypanel/vhost/head.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/common/head.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/login.html
wget --no-check-certificate https://github.kangle.icu/easypanel/vhost/login.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/login.html
rm -rf /vhs/kangle/nodewww/webftp/vhost/view/default/loginerror.html
wget --no-check-certificate https://github.kangle.icu/easypanel/vhost/loginerror.html -O /vhs/kangle/nodewww/webftp/vhost/view/default/loginerror.html
rm -rf /vhs/kangle/ext/tpl_php52/php-templete.ini
wget --no-check-certificate https://github.kangle.icu/easypanel/php-templete.ini -O /vhs/kangle/ext/tpl_php52/php-templete.ini
rm -rf /vhs/kangle/ext/tpl_php52/etc/php-node.ini
wget --no-check-certificate https://github.kangle.icu/easypanel/php-node.ini -O /vhs/kangle/ext/tpl_php52/etc/php-node.ini
$PREFIX/bin/kangle -q
killall -9 kangle
sleep 3
$PREFIX/bin/kangle
echo "Please visit http://ip:3312/admin/ to continue."
