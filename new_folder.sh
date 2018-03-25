#!/bin/bash
# Based on Steven's upload_to_box.sh script
# This script will create new folders

if [ "$#" -ne 2 ]; then
  echo "Usage: ./new_folder.sh BLAH BLAH"
  exit 1
fi

# Make sure that current access token is up-to-date
./get_new_access_token.sh

ACCESS_TOKEN=$( cat box_access_token.txt | sed 's/\"//g' )
BOX_PATH="$1"
FILE="$2"
FOLDER_ID=0
LIMIT=100
OFFSET=0
NEXT_FOLDER_ID=$FOLDER_ID
HEADER="Authorization: Bearer $ACCESS_TOKEN"

# pseudo code
for $MATERIAL_FOLDER in $MATERIAL_COMPATIBILITY
  check if imgs, spc, txt folders exist
  if not then: 
    create imgs folder
    create spc folder
    create txt folder
