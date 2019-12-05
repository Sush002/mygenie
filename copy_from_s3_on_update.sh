#! /bin/bash
BUCKET_PATH=""
echo "[INPUT]Bucket Name: $BUCKET_PATH"
LOCAL_PATH=""
echo "[INPUT]Local path: $LOCAL_PATH"
#provide multiple files by a space
FILE_NAMES=""

for file in $FILE_NAMES;do
	echo "[WORKING] Processing file $file"
	s3_find_result=$(aws s3 ls $BUCKET_PATH | grep $file)
	s3_date_time=$(echo $s3_find_result | awk {'print $1,$2'}| awk -F':' 'BEGIN{OFS=":";} { print $1,$2}')
	echo "Timestamp on s3 $s3_date_time"
	s3_date_time_epoch=$(date -d "$s3_date_time" +"%s")

	local_file_date_time=$(ls -ltr $LOCAL_PATH | grep $file | awk {'print $6,$7,$8'})
	echo "Timestamp on localfile $local_file_date_time" 
	local_file_date_time_epoch=$(date -d "$local_file_date_time" +"%s")

	if [ "$s3_date_time_epoch" -gt "$local_file_date_time_epoch" ];then
		
		echo "[WORKING] The file in s3 bucket is newer. So copying it to localpath $LOCAL_PATH"
		aws s3 cp $BUCKET_PATH/$file $LOCAL_PATH/
		if [ $? == 0 ];then
			echo "[SUCCESS] - copy done -"
		else
			echo "[FAIL] - copy failed -"
			exit 1
		fi	
	else
		echo "[NO ACTION] The file is not updated in S3"
	fi
done

	


