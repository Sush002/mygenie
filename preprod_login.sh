#! /bin/bash
set -x

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMP_DIR=$CURRENT_DIR/temp
cat /dev/null > $TEMP_DIR/LbAppPubIps

echo "Enter the FQDN URL of preprod/prod"
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
scp -i "E:\Sush\Scripts\OpenPutty\Keys\/$key.ppk" pegauser@$public_ip:/etc/httpd/conf/workers.properties $TEMP_DIR/
mv $TEMP_DIR/workers.properties $TEMP_DIR/LbConfFile

# find the hostname and match the customer name  in excel sheet and from their get the respective public IP for the private/vpn Ips mentioned in Lb
# Finding LB hostname from excel
lb_hostname=`cat inventory.csv | grep  -i $name | awk  -F, {'print $17'}`
# finding respective customer name from excel
cust_name=`cat inventory.csv | grep -w $lb_hostname | awk  -F, {'print $2'}`
#Getting the inventory for the customer
cat inventory.csv |  grep -w $cust_name > $TEMP_DIR/$cust_name.csv

# Getting Ips from LB server
for i in `cat "$TEMP_DIR"/LbConfFile | grep -v  "#" | grep "worker.loadbalancer.balance_workers" | awk -F= {'print $2'} | awk -F, '{for (i = 1; i <= NF; i++) print $i}'`; do cat "$TEMP_DIR"/LbConfFile | grep -w worker."$i".host | awk -F= {'print $2'} ; done > $TEMP_DIR/LbAppIPs

LbAppIPs_uniq=`cat $TEMP_DIR/LbAppIPs | sort | uniq`

# Get public Ips of app servers
for i in $LbAppIPs_uniq; do read pub <<< $(awk -F',' -v j="$i" 'BEGIN{IGNORECASE = 1}{if ($5 == j || $16 == j) print $4}' "$TEMP_DIR"/$cust_name.csv);echo $pub  >> $TEMP_DIR/LbAppPubIps; done

# get the key file name for the  app server login
key=`cat "$TEMP_DIR"/$cust_name.csv | grep  -w \`head -1  "$TEMP_DIR"/LbAppPubIps\` | awk -F, {'print $7'}`

#logging in to each app servers

for i in `cat $TEMP_DIR/LbAppPubIps`
do
/drives/e/Sush/Scripts/OpenPutty/putty.exe pegauser@$i -i "E:\Sush\Scripts\OpenPutty\Keys\/$key.ppk" 22 &
done

