#!/bin/bash

## Check and run the script as root user

#VARIABLES
TOMCAT_CONN_URL="http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
#GETTING ONLY tomcat-connectors-1.2.42-src.tar.gz FILE NAME WITH Below command( awk -F : field seperator,printing Nth field which is last field)
CONN_TAR_FILE=$(echo $TOMCAT_CONN_URL | awk -F / '{print $NF}')

#SEARCH file name AND REPLACE WITH SED 
CONN_TAR_DIR=$(echo $CONN_TAR_FILE | sed -e 's/.tar.gz//')

#Tomcat
TOMCAT_INST_URL="http://redrockdigimark.com/apachemirror/tomcat/tomcat-9/v9.0.2/bin/apache-tomcat-9.0.2.tar.gz"
TOMCAT_TAR_FILE=$(echo $TOMCAT_INST_URL | awk -F / '{print $NF}')
TOMCAT_TAR_DIR=$(echo $TOMCAT_TAR_FILE| sed -e 's/.tar.gz//')

MYSQL_IP_ADDR=localhost




#creating tomcat ip
TOMCAT_IP_ADD=localhost

#awk -F / '{print $1}'
#awk -F / '{print $2}'
#awk -F / '{print $3}'
#awk -F / '{print $4}'
#awk -F / '{print $5}'
#awk -F / '{print $NF}'

ID=$(id -u)

if [ $ID -ne 0 ]; then
    echo "you should be a root user to be executed this script"
    exit 1
fi

#### functions along with ansi characters "tick" marks
SUCC() {
	echo -e "\e[32m✓ $1\e[0m"
}
	
ERR() {
	echo -e "\e[31m✗ $1\e[0m"
}


### Installing Tree Package
yum install httpd httpd-devel	 -y  &>/dev/null

#Below step is to check exit status then prompt message on screen
if [ $? -eq 0 ]; then 
#calling functions
	SUCC "installation of httpd is completed"
else
#calling functions
	ERR "installation of httpd is failed"
fi


### configure mod-jk
wget $TOMCAT_CONN_URL -O /opt/$CONN_TAR_FILE &>/dev/null
if [ $? -eq 0 ]; then
   SUCC "Downloading MOD-JK --- Successful"
 else
   ERR "modjk download failed"
   exit 1
fi

##Extract mod_jk
cd /opt
tar xf $CONN_TAR_FILE
cd $CONN_TAR_DIR/native
./configure --with-apxs=/bin/apxs &>/dev/null && make clean &>/dev/null && make &>/dev/null && make install &>/dev/null

if [ $? -eq 0 ]; then
	SUCC "Installing MOD-JK ... Sucessful"
else
	ERR " Mod Jk installation ... Failed"
	exit 1
fi
	
echo 'LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf.d/workers.properties
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
JkRequestLogFormat "%w %V %T"
JkMount /student tomcatA
JkMount /student/* tomcatA' >/etc/httpd/conf.d/mod_jk.conf

echo '### Define workers
worker.list=tomcatA
### Set properties
worker.tomcatA.type=ajp13
worker.tomcatA.host=TOMCAT_IP_ADD
worker.tomcatA.port=8009' >/etc/httpd/conf.d/workers.properties

#Replacing tomcat_ip_add varaiable
sed -i -e "s/TOMCAT_IP_ADD/$TOMCAT_IP_ADD/" /etc/httpd/conf.d/workers.properties


## Start web server
systemctl enable httpd &>/dev/null
systemctl start httpd &>/dev/null
if [ $? -eq 0 ]; then 
	echo "Apache web server is started"
else
  ERR "failed to start apache web server"
  exit 1
fi

## Install Java For tomcat
# first install java
yum install java -y &>/dev/null
java -version &>/dev/null
if [ $? -eq 0 ]; then
	SUCC " Java installation is success"
else
	FAIL "Java installation failed"
	exit 1
fi

## Installing Tomcat
cd /opt
wget $TOMCAT_INST_URL -O  $TOMCAT_TAR_FILE &>/dev/null
if [ $? -eq 0 ]; then
	SUCC "tomcat download is done"
else
	FAIL "TOMCAT DOWNLOAD FAILED"
	exit 1
fi

tar xf $TOMCAT_TAR_FILE
cd $TOMCAT_TAR_DIR
rm -rf webapps/*
wget https://github.com/prasanthbangs2016/laborare/raw/master/APPSTACK/student.war -O webapps/student.war &>/dev/null
STAT1=$?
wget  https://github.com/prasanthbangs2016/cogito/raw/master/appstack/mysql-connector-java-5.1.40.jar -O lib/mysql-connector-java-5.1.40.jar &>/dev/null
STAT2=$?
##if [ $STAT1 -eq 0 ] && [ $STAT2-eq 0 ]; then ### logical operator
if [ $STAT1 -eq 0 -a $STAT2 -eq -0 ]; then
	SUCC " Completed downloading student war file and mysql connector"
else
	ERR " downloading student war and mysql connector failed "
	exit 1
fi

sed -i -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="student" password="student@1" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://MYSQL_IP_ADDR:3306/studentapp"/>' conf/context.xml

sed -i -e "s/MYSQL_IP_ADDR/$MYSQL_IP_ADDR/" conf/context.xml

sh bin/startup.sh &>/dev/null
if [ $? -eq 0 ]; then
 SUCC "TOMCAT STARTED SUCCESSFULLY"
else
	ERR "TOMCAT FAILED TO START"
	exit 1
fi

## Install Maria DB

yum install mariadb mariadb-server -y &>/dev/null
java -version &>/dev/null
if [ $? -eq 0 ]; then
	SUCC " MariaDB installation is success"
else
	ERR "MariaDB installation failed"
	exit 1
fi

systemctl enable mariadb &>/dev/null
systemctl start mariadb &>/dev/null
if [ $? -eq 0 ]; then
	SUCC " MariaDB Started successfully"
else
	ERR "MariaDB start up failed"
	exit 1
fi

echo "create database IF NOT EXISTS studentapp;
use studentapp;
CREATE TABLE IF NOT EXISTS Students(student_id INT NOT NULL AUTO_INCREMENT,
	student_name VARCHAR(100) NOT NULL,
    student_addr VARCHAR(100) NOT NULL,
	student_age VARCHAR(3) NOT NULL,
	student_qual VARCHAR(20) NOT NULL,
	student_percent VARCHAR(10) NOT NULL,
	student_year_passed VARCHAR(10) NOT NULL,
	PRIMARY KEY (student_id)
);
grant all privileges on studentapp.* to 'student'@'localhost' identified by 'student@1';" >/tmp/student.sql

### Run the following command to create DB
 mysql </tmp/student.sql &>/dev/null
 
 if [ $? -eq 0 ]; then
	SUCC " MariaDB Configured successfully"
else
	ERR "MariaDB configure failed"
	exit 1
fi





