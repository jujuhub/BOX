#!/bin/bash
# Based on https://cloud.app.box.com/curltutorialscript

if [ "$#" -ne 2 ]; then
  echo "Usage: ./upload_to_box.sh BOX_PATH FILE"
  exit 1
fi

# Make sure that our current access token is up-to-date
./get_new_access_token.sh
ACCESS_TOKEN=$( cat box_access_token.txt | sed 's/\"//g')
BOX_PATH="$1"
FILE="$2"
FOLDER_ID=0
LIMIT=100
OFFSET=0
NEXT_FOLDER_ID=$FOLDER_ID
HEADER="Authorization: Bearer $ACCESS_TOKEN"

echo upload file: $FILE
echo box path: $BOX_PATH

IFS='/' read -a ARRAY <<< "$BOX_PATH"
#echo "Here come da IFS"
#echo "$IFS"

for ELEMENT in "${ARRAY[@]}"
do
#	echo "$ELEMENT"
	OFFSET=0
	while :
	do
		RESPONSE=`curl "https://api.box.com/2.0/folders/${FOLDER_ID}/items?limit=${LIMIT}&offset=${OFFSET}" -H "$HEADER" -s`
                #echo "$RESPONSE"
		
		ENTRIES=`echo $RESPONSE | ./JSON.sh | egrep '\[\"entries\"\]' | cut -f2`
			
		if [ "$ENTRIES" = "[]" ]
		then
			ERROR="true"
			echo "	$ELEMENT folder not found"
			break
		else
			NEXT_FOLDER_ID=`echo $RESPONSE | ./JSON.sh  | egrep -A 4 "\[\"entries\",[0-9]*,\"type\"\][[:space:]]*\"folder\"" | egrep -B 3 "\[\"entries\",[0-9]*,\"name\"\][[:space:]]*\"${ELEMENT}\"" | head -1 | cut -d"\"" -f6`
			
			echo "$NEXT_FOLDER_ID" | grep '[a-zA-Z]' > /dev/null 
			VALID_FOLDER_ID=$?
				
			if [ "$NEXT_FOLDER_ID" != "" ] && [ $VALID_FOLDER_ID = 1 ]
			then
				FOLDER_ID=$NEXT_FOLDER_ID
				echo "	$ELEMENT folder id: $FOLDER_ID"
				break
			else
				OFFSET=$((OFFSET+$LIMIT))
			fi
		fi
	done
done


if [ "$ERROR" !=  "true" ]
then
	STATUS=`curl "https://upload.box.com/api/2.0/files/content" -H "$HEADER" -F parent_id=${FOLDER_ID} -F filename=@${FILE} -i -s | grep HTTP/1.1 | tail -1 | awk {'print $2'}` > /dev/null
	if [ $STATUS != 201 ]
	then
		ERROR="true"
	else
		echo "upload succcessful"
	fi
fi

if [ "$ERROR" =  "true" ]
then
	echo "upload failed"
	exit 1
fi
