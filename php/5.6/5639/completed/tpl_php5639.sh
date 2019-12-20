#!/bin/sh
yum -y install bzip2-devel libxml2-devel curl-devel db4-devel libjpeg-devel libpng-devel freetype-devel pcre-devel zlib-devel sqlite-devel libmcrypt-devel unzip bzip2
yum -y install mhash-devel openssl-devel
yum -y install libtool-ltdl libtool-ltdl-devel
PREFIX="/vhs/kangle/ext"
wget -c https://github.kangle.icu/php/5.6/5639/completed/tpl_php5639.tar.bz2 -O tpl_php5639.tar.bz2
tar xjf tpl_php5639.tar.bz2
mv tpl_php5639 $PREFIX
rm -rf /tmp/*
/vhs/kangle/bin/kangle -r
