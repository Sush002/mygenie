#! /bin/bash

echo "Enter  the unique Public IP/Hostname/VPN IP"
read name
read key public_ip vanity_URL <<< $(awk -F',' -v nameA="$name" 'BEGIN{IGNORECASE = 1}{
						if ($14 == nameA || $4 == nameA || $16 == nameA || $5 == nameA || $17 == nameA || $14 == nameA".")
							print $7,$4,$14
							}' inventory.csv)
echo $key
echo $public_ip
echo $vanity_URL
if  [ -z "$key" ]
	then
		echo $'NOT IN current Inventory..Checking in old inventory\n'
		key=`cat Old_Instance_Sheet.csv | grep  -iw $name | awk  -F, {'print $12'}`
		public_ip=`cat Old_Instance_Sheet.csv | grep  -iw $name | awk  -F, {'print $7'}`
		vanity_URL=`cat Old_Instance_Sheet.csv | grep  -iw $name | awk  -F, {'print $5'}`
        		if  [ -z $key ]
	        		then
		        		echo $'opppsss..NOT in Old Inventory as well.\n Please check manually'
			        	exit
			fi
fi
key=`echo $key | sed 's/ //g'`
public_ip=`echo $public_ip | sed 's/ //g'`
echo "Vanity URL: $vanity_URL"
echo "Public IP: $public_ip"
echo "Key : $key "
/drives/e/Sush/Scripts/OpenPutty/putty.exe pegauser@$public_ip -i "E:\Sush\Scripts\OpenPutty\Keys\/$key.ppk" 22 &

