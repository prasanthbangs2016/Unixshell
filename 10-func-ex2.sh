#!/bin/bash

## Check and run the script as root user

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
yum install tree -y  &>/dev/null

#Below step is to check exit status then prompt message on screen
if [ $? -eq 0 ]; then 
#calling functions
	SUCC "installation of TREE is completed"
else
#calling functions
	ERR "installation of TREE is failed"
fi

