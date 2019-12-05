#! /bin/bash
Source="/Users/sushrismitam/MyProjects"
Host="$1"
ping -o $Host &> /dev/null
if [ $? -ne 0 ];then
	echo "Invalid Host"
	exit 1
fi
logname=`ssh -o StrictHostKeyChecking=no -v -n $Host &> $Source/tmp && cat $Source/tmp | grep "Authenticating to" | awk -F"'" {'print $2'} && rm -fr $Source/tmp`
if [ "$logname" = "sushrismitam" ];then
	password=$passwdOne
elif [ "$logname" = "DOMAIN+sushrismitam" ];then
	password=$passwdTwo
else
	echo "Unsupported logname"
	exit 1
fi
expect -f $Source/expectsudo.sh $Host $logname $password
