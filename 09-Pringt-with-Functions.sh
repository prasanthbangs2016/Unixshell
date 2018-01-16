#!/bin/bash

# Define a function

SUCCESS() {
	echo -e "\e[32m $1 \e[0m"
}

FAILURE() {
	echo -e "\e[31m $1 \e[0m"
}

# calling function
SUCCESS "installation of TREE is success"
FAILURE "installation of TREE is failure"
