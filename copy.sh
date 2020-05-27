#! /bin/bash

#Assume s3.lst and ec2.lst is available already

cp ec2.lst ec2.after.lst
processor_list=$(cat s3.lst | cut -d'.' -f1 | uniq)
for lst in $processor_list;do
	latest_version=$(cat s3.lst | grep $lst | sort -t '.' -k 1,1 -k 2,2  -k 3,3 -g | tail -1)
	echo "latest version for processor $lst is: $latest_version"

	# copy_logic
	if grep $latest_version ec2.lst > /dev/null;then
		echo "Version is already latest in EC2"
	else
		echo "Copying $latest_version to EC2"
		echo $latest_version >> ec2.after.lst
	fi

	# Delete logic
	# repopulate the ec2.lst . assume it is ec2.after.lst
	delete_list=$(cat ec2.after.lst | sort -t '.' -k 1,1 -k 2,2  -k 3,3 -r | grep $lst | tail -n +3)
	if [ -z $delete_list ];then
		echo "Nothing to delete"
	else
	   for file in $delete_list;do
		echo "Deleting $file"
	   done
	fi
done
