#!/bin/bash



## Check and run the script as root user

ID=$(id -u)

if [ $ID -ne 0 ]; then
    echo "you should be a root user to be executed this script"
    exit 1
fi

### Installing Tree Package
yum install tree -y  &>/dev/null

#Below step is to check exit status then prompt message on screen
if [ $? -eq 0 ]; then 
	echo "installation of TREE is completed"
else
	echo "installation of TREE is failed"
fi

