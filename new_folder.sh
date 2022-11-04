#!/bin/bash
# This script creates new folders. Based on Steven's upload_to_box.sh

# Make sure that current access token is up-to-date; always needed?
./get_new_access_token.sh

# reads access token in txt file and globally (g) removes quotes
ACCESS_TOKEN=$( cat box_access_token.txt | sed 's/\"//g' )

PARENT_FOLDER="material_compatibility/before_soln_replacement"
INPUT_FILE="../BOX/folder_list.txt" #"../ANNIE/Gd_testing/file_ext.txt"
#FOLDER_ID=0
#NEXT_FOLDER_ID=$FOLDER_ID
LIMIT=100
OFFSET=0
HEADER="Authorization: Bearer $ACCESS_TOKEN"

echo "parent folder: $PARENT_FOLDER"
echo "input file path: $INPUT_FILE"

while read FILE_EXT; do
#	echo "$FILE_EXT"

	FOLDER_ID=0
	NEXT_FOLDER_ID=$FOLDER_ID

	IFS='/' read -a ARRAY <<< "$PARENT_FOLDER" #/$FILE_EXT" # adjust parent

	for ELEMENT in "${ARRAY[@]}"; do
		OFFSET=0
		while :
		do
			RESPONSE=`curl "https://api.box.com/2.0/folders/${FOLDER_ID}/items?limit=${LIMIT}&offset=${OFFSET}" -H "$HEADER" -s`

			ENTRIES=`echo $RESPONSE | ./JSON.sh | egrep '\[\"entries"\"\]' | cut -f2`

			if [ "$ENTRIES" = "[]" ]; then
				ERROR="true"
				echo "  $ELEMENT folder not found"
				break
			else
				NEXT_FOLDER_ID=`echo $RESPONSE | ./JSON.sh | egrep -A 4 "\[\"entries\",[0-9]*,\"type\"\][[:space:]]*\"folder\"" | egrep -B 3 "\[\"entries\",[0-9]*,\"name\"][[:space:]]*\"${ELEMENT}\"" | head -1 | cut -d "\"" -f6`

				echo "$NEXT_FOLDER_ID" | grep '[a-zA-Z]' > /dev/null
				VALID_FOLDER_ID=$?

				if [ "$NEXT_FOLDER_ID" != "" ] && [ $VALID_FOLDER_ID = 1 ]; then
					FOLDER_ID=$NEXT_FOLDER_ID
					echo "  $ELEMENT folder id: $FOLDER_ID"
					break
				else
					OFFSET=$((OFFSET+$LIMIT))
				fi
			fi
		done
	done

	# make new folders
	if [ "$ERROR" != "true" ]; then
		# had issues with -d option, var expansion and quotes
#		echo "$FOLDER_ID"
#		echo "$FILE_EXT"

		FOL={\"name\":\"$FILE_EXT\",\"parent\":{\"id\":\""$FOLDER_ID"\"}}
		curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$FOL" -X POST 

#		MAT={\"name\":\"$FILE_EXT\",\"parent\":{\"id\":\""$FOLDER_ID"\"}}
#		curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$MAT" -X POST 

#		IMG={\"name\":\"img\",\"parent\":{\"id\":\""$FOLDER_ID"\"}}
#		curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$IMG" -X POST 

		# script still runs even if folder already exists
#		STATUS1=`curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$IMG" -X POST -i -s | grep HTTP/1.1 | tail -1 | awk {'print $2'}` > /dev/null
#		if [ $STATUS1 != 409 ]; then
#			ERROR="true"
#		else
#			echo "created img folder"
#		fi

#		SPC={\"name\":\"spc\",\"parent\":{\"id\":\""$FOLDER_ID"\"}}
#		curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$SPC" -X POST

#		TXT={\"name\":\"txt\",\"parent\":{\"id\":\""$FOLDER_ID"\"}}
#		curl "https://api.box.com/2.0/folders" -H "$HEADER" -d "$TXT" -X POST

	fi

	if [ "$ERROR" = "true" ]
	then
		echo "failed to create folders"
		exit 1
	fi

done < "$INPUT_FILE"
