#! /bin/bash

# Set the current directory
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $CURRENT_DIR
cd $CURRENT_DIR

#set temp directory
if [ ! -d temp ];then
	if [ ! -L temp ];then
	mkdir temp
	fi
fi
TEMP_DIR=$CURRENT_DIR/temp

if  [ ! -f mygenie.sh ]
	then
	echo "Booo...Please check the path of  mygenie.sh... Exiting..."
	exit
fi

function banner {
	echo "  
		#######################################################################
		This script provides following features for allin1/preprod instances
		1) Login
		2) Restart
		3) log

		[./mygenie.sh configure] needs to be run once to set up paths and variables
		or you can run again to overwrite exiting values

		You can set defaults by providing the type of instance and type of
		operation you mean to perform very frequently.Select 'Y' when
		prompted to configure default 

		example: default:Y Instance Type:allin1 Operation: login
		This will allow  you to  login to indivisual server/public IP

		Please  leave your feedbacks @ susri002@gmail.com
		####################################################################"

		echo "Please run configure to set the values"
}

# Fucntion set the path  for the  script execution , can be dynamic
function configure {

	function path {
		echo "Path to putty( format: /drives/e/Sush/Scripts/OpenPutty/):"
		read PATH_PUTTY
			count=0
			while [ ! -f $PATH_PUTTY/putty.exe ]
			do
				if [ $count == 3 ];then
				echo "You have attempted 3 times already. Exiting.."
				exit 1
					else
					echo "Putty is not found in the path $PATH_PUTTY"
					echo "Attempt:"$count":Path to putty:"
					read PATH_PUTTY
					count=$((count + 1))
				fi
			done


		echo "path to inventory (format: /drive/c/users/mishs4/Documents/):"
		read PATH_INVENTORY
			count=0
			while [ ! -f $PATH_INVENTORY/inventory.csv ]
			do
				if [ $count == 3 ];then
				echo "You have attempted 3 times already. Exiting.."
				exit 1
					else
					echo "File inventory.csv[case sensitive] is not found in path $PATH_INVENTORY"
					echo "Attempt:"$count":path to inventory:"
					read PATH_INVENTORY
					count=$((count + 1))
				fi
			done
		echo "Path to Keys( format: /drives/e/Sush/Scripts/OpenPutty/):"
		read PATH_KEYS
			count=0
			while [ ! -f $PATH_PUTTY/putty.exe ]
			do
				if [ $count == 3 ];then
				echo "You have attempted 3 times already. Exiting.."
				exit 1
					else
					echo "Putty is not found in the path $PATH_PUTTY"
					echo "Attempt:"$count":Path to Keys:"
					read PATH_KEYS
					count=$((count + 1))
				fi
			done
	
	
	echo "PATH_PUTTY=$PATH_PUTTY" >> .config
	echo "PATH_INVENTORY=$PATH_INVENTORY" >> .config
	echo "PATH_KEYS=$PATH_KEYS" >> .config
	}
	if [ -f .config ];then
	echo "There is exisitng setting for PATHS, you are going to overwrite. Press 'Y' to confirm"
	read confirm
		if [ "$confirm" == "Y" ];then
		cat /dev/null > .config
		path
			else
			echo "You have choosen not to update PATHs.exiting..."
		fi
		else
		path
	fi
	function default_path {
		echo "Instance Typpe"
		read ENV_TYPE
		echo "Opration"
		read OP
		
	echo "ENV_TYPE=$ENV_TYPE" >> .default
	echo "OP=$OP" >> .default

	}
	

	if [ -f .default ];then
	echo "There is exisitng setting for defaults, you are going to overwrite. Press 'Y' to confirm"
	read confirm
		if [ "$confirm" == "Y" ];then
		cat /dev/null > .default
		default_path
			else
			echo "You have choosen not to update defaults.exiting..."
			exit 1
		fi
		else
		echo "Press 'Y' to set defaults"
		read response
			if [ "$response" == "Y" ];then
			default_path
				else
				echo "You have choosen not to set any defaults. Pleas follow usage of the script"
				exit 1
			fi
	fi
	
	
echo "************ YOU ARE ALL SET TO RUN THE SCRIPT NOW *************"
	
}

# fucntion to get key/vanity URL/public IP from excel sheet
function login_data {
		PATH_INVENTORY=`cat .config | grep PATH_INVENTORY | awk -F= {'print $2'}`
		read name
		read key public_ip vanity_URL <<< $(awk -F',' -v nameA="$name" 'BEGIN{IGNORECASE = 1}{
						if ($14 == nameA || $4 == nameA || $16 == nameA || $5 == nameA || $17 == nameA || $14 == nameA".")
							print $7,$4,$14
							}' $PATH_INVENTORY/inventory.csv)
key=`echo $key | sed 's/ //g'`
public_ip=`echo $public_ip | sed 's/ //g'`

echo "$public_ip"
echo "$key"
echo "$vanity_URL"
}

function allin1_login {
	echo "Please enter Vanity URL/Public IP/VPN IP" 
	login_data=`login_data`
	for i in $login_data
		do
		echo $i
		done
}


# Function for  Allin1 instances 

function allin1 {
	
	if [ ! -z $1 ];then
		if [ "$1" == "login" ];then
		allin1_login
		exit
			elif [ "$1" == "restart" ];then
			echo "restart function goes here"
			exit
				elif [ "$1" == "log" ];then
				echo "log collection process goes here"
				exit
		fi
		else
		OPTIONS="login restart log"
		select opt in $OPTIONS
		do
			if [ "$opt" = "login" ];then
			allin1_login
			exit
				elif [ "$opt" = "restart" ];then
				echo done
				exit
					elif [ "$opt" = "log" ];then
					echo done
					exit
						else
						echo "bad option"
						exit 1
			fi
		done
	fi
}


# To call the default settings
function default {
	echo  " Test Default function"
	ENV_TYPE=`cat .default | grep -w ENV_TYPE |awk -F= {'print $2'}`
	OP=`cat .default | grep -w OP |awk -F= {'print $2'}`
		if [ "$ENV_TYPE" == "allin1" ];then
		allin1 $OP
			elif [ "$ENV_TYPE" == "preprod" ];then
			preprod $OP
				else
				echo "Invalid options in Default config. Please perform the configure to fix this"
		fi
}

# Calling the functions
case "$1" in 
	configure)
		configure
		;;
	allin1)
		allin1
		;;
	preprod)
		preprod
		;;
	*)
		if [ ! -f .default ];then
			banner
			echo $"Usage: $0 {configure|allin1|preprod}"
				else
				default
		fi
		exit 1
esac


