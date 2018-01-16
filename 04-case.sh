#!/bin/bash

#s! = first argun=ment in script

#*) TELLS ELSE STATEMENT

# exit = to come out from script
# exit 1 = it is exit status 



case $1 in
     web)
	 echo "installing web server"
	 ;;
     APP)
	 echo "installing web server"
	  ;;
      DB)
	 echo "installing maria  db"
	 ;;
	 *)
		echo "invalid option"
		echo "$0 web|APP|DB"
		exit 1
esac