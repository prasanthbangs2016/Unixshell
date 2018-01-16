#!/bin/bash

# how do you check you are a root user or not
# sol# id ,command tells


#validating user is non root or root user

ID=$(id-u)

case $ID in
     0)

     case $1 in
          WEB)
		echo "installing web server"
		yum install httpd -y
		;;
	   APP)
		echo "installing app server"
		;;
	   DB)
		echo "installing maria db"
		;;
	  *)
		echo "invalid option"
		echo "$1 WEB|APP|DB"
		exit 1
		;;
esac
;;

 *)
   echo "you should be a root to be executed this script"
   exit 2

esac