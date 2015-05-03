#!/bin/bash

# CWP Apache 2.4 and suPHP 0.72 Upgrade Script

# Simple Bash script by Bullten Web Hosting Solutions [http://www.bullten.com]

CDIR='/tmp/apache-upgrade'
apache='/usr/local/apache/conf/httpd.conf'
vhost='/usr/local/apache/conf.d/vhosts.conf'
SOURCE_URL='http://dl-package.bullten.in/cwp/files'
packageHTTPD='httpd-2.4.12.tar.gz'
packageAPR='apr-1.5.1.tar.gz'
packageAPRUTIL='apr-util-1.5.4.tar.gz'
packageSUPHP='suphp-0.7.2.tar.gz'
RED='\033[01;31m'
RESET='\033[0m'
GREEN='\033[01;32m'


clear

echo -e "$GREEN******************************************************************************$RESET"
echo -e "          Apache 2.4 and suPHP 0.7.2 Installation in CWP $RESET"
echo -e "       Bullten Web Hosting Solutions http://www.bullten.com/"
echo -e "   Web Hosting Company Specialized in Providing Managed VPS and Dedicated Server   "
echo -e "$GREEN******************************************************************************$RESET"
echo " "
echo " "
echo -e $RED"This script will Install Apache 2.4 and suPHP 0.7.2"$RESET
echo -e $RED""
echo -n  "Press ENTER to start the installation  ...."
read option

rm -rf $CDIR; mkdir -p $CDIR

clear

echo -e $RED"Installing Apr 1.5.1"$RESET
echo -e $RED""$RESET
sleep 2

cd $CDIR
wget -c $SOURCE_URL/$packageAPR
tar zxvf $packageAPR
cd apr-1.5.1
./configure
make && make install

echo -e $RED"Apr 1.5.1 installation Completed."$RESET
echo -e $RED""$RESET
echo -e $RED"Apr-Util 1.5.4 installation will begin in 5 seconds.."$RESET
sleep 5

clear

echo -e $RED"Installing Apr-Util 1.5.4"$RESET
echo -e $RED""$RESET
sleep 2

cd $CDIR
wget -c $SOURCE_URL/$packageAPRUTIL
tar zxvf $packageAPRUTIL
cd apr-util-1.5.4
./configure --with-apr=/usr/local/apr/
make && make install


echo -e $RED"Apr-Util 1.5.4 installation Completed."$RESET
echo -e $RED""$RESET
echo -e $RED"Apache 2.4.12 installation will begin in 5 seconds.."$RESET
sleep 5

clear

echo -e $RED"Installing Apache 2.4.12 "$RESET
echo -e $RED""$RESET
sleep 2

cd $CDIR
wget -c $SOURCE_URL/$packageHTTPD
tar zxvf $packageHTTPD
cd httpd-2.4.12
rm -rf $apache
./configure --enable-so --prefix=/usr/local/apache --enable-ssl --enable-unique-id --enable-ssl=/usr/include/openssl --enable-rewrite  --enable-deflate --enable-suexec --with-suexec-docroot="/home" --with-suexec-caller="nobody" --with-suexec-logfile="/usr/local/apache/logs/suexec_log" --enable-asis --enable-filter --with-pcre --with-apr=/usr/local/apr --with-mpm=prefork  --with-apr-util=/usr/local/apr --enable-headers --enable-expires --enable-proxy
make && make install

if [ -e "/usr/local/apache/conf/httpd.conf" ];then
echo "Include /usr/local/apache/conf/sharedip.conf" >> $apache
echo "Include /usr/local/apache/conf.d/*.conf" >> $apache
echo "ExtendedStatus On" >> $apache
sed -i "s|DirectoryIndex index.html|DirectoryIndex index.php index.html|g" $apache

cat >> $apache <<EOF
<Directory "/usr/local/apache/htdocs">
        suPHP_UserGroup nobody nobody
</Directory>
EOF

else

echo -e $RED"Apache installation failed. Cannot determine httpd.conf in /usr/local/apache/conf/ "$RESET
echo ""
echo -e $RED"Terminating installation / Installation Failed"$RESET
exit

fi

echo -e $RED"Apache 2.4.12 installation Completed."$RESET
echo -e $RED""$RESET
echo -e $RED"suPHP 0.7.2 installation will begin in 5 seconds.."$RESET
sleep 5

clear

echo -e $RED"Installing suPHP 0.7.2"$RESET
echo -e $RED""$RESET
sleep 2

cd $CDIR
wget -c $SOURCE_URL/$packageSUPHP
tar zxvf $packageSUPHP
cd suphp-0.7.2
yum install autoconf automake libtool -y
perl -pi -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/' configure.ac
aclocal
libtoolize --force
automake --add-missing
autoreconf
perl -pi -e 's#"\$major_version" = "2.2"#"\$major_version" = "2.4"#' ./configure
./configure --with-apr=/usr/local/apr/ --with-apxs=/usr/local/apache/bin/apxs --with-setid-mode=paranoid --with-apache-user=nobody --with-gnu-ld --disable-checkpath
make && make install


sed -i "s|User daemon|User nobody|g" $apache
sed -i "s|Group daemon|Group nobody|g" $apache
sed -i "s|.*modules/libphp5.so.*||g" $apache
sed -i "s|.*httpd-userdir.conf.*|Include conf/extra/httpd-userdir.conf|" $apache

sed -i '/mod_userdir.so/s/^#//g' $apache
sed -i '/mod_rewrite.so/s/^#//g' $apache
sed -i '/mod_slotmem_shm.so/s/^#//g' $apache
sed -i '/mod_lbmethod_heartbeat.so/s/^/#/g' $apache

echo -e $RED"suPHP 0.7.2 installation Completed."$RESET
echo -e $RED""$RESET
echo -e $RED"Waiting for 5 Seconds..."$RESET
sleep 5

clear

if [ -e "/usr/local/apache/conf.d/vhosts.conf" ];then

echo -e $RED"Setting Vhost /usr/local/apache/conf.d/vhosts.conf "$RESET
sleep 2

sed -i '/Require all granted/d' $vhost
sed -i '/AllowOverride All/a  \ \ \ \ \ \ \ \ Require all granted ' $vhost

echo -e $RED"Vhost Setup Completed"$RESET

else

echo -e $RED"Virtual Host Setup Failed. Please verify if vhosts.conf exist in /usr/local/apache/conf.d/ "$RESET
echo ""
echo -e $RED"Terminating installation / Installation Failed"$RESET
exit

fi

sleep 2


echo -e $RED"Restarting Apache"$RESET

service httpd restart
chkconfig httpd on

sleep 2

echo -e $RED"Installation Completed"$RESET