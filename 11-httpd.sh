#!/bin/bash

## Check and run the script as root user

#VARIABLES
TOMCAT_CONN_URL="http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"

#GETTING ONLY tomcat-connectors-1.2.42-src.tar.gz FILE NAME WITH Below command( awk -F : field seperator,printing Nth field which is last field)
CONN_TAR_FILE=$(echo TOMCAT_CONN_URL | awk -F / '{print $NF}')

#SEARCH file name AND REPLACE WITH SED 
CONN_TAR_DIR=$(echo $CONN_TAR_FILE | sed -e 's/.tar.gz//')

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


## Start web server
systemctl enable httpd &>/dev/null
systemctl start httpd &>/dev/null
if [ $? -eq 0 ]; then 
	echo "Apache web server is started"
else
  ERR "failed to start apache web server"
  exit 1
fi

### configure mod-jk
wget $TOMCAT_CONN_URL -O /opt/$CONN_TAR_FILE &>/dev/null
if [ $? -eq 0 ]; then
   SUCC "Downloading MOD-JK --- Successful"
 else
   ERR "modjk download failed"
   exit 1
fi