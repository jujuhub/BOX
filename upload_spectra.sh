#!/bin/bash
# Uploads all the .spc and .txt files to box for each material

ANNIE_PATH="$HOME/ANNIE/Gd_testing"
INPUT_FILE="file_ext.txt"
PARENT_FOLDER="material_compatibility"

while read FILE_EXT; do
	# txt files
	for txt in `find "$ANNIE_PATH"/*_test -type f -name "*[0-9]_$FILE_EXT.txt" -newermt '14 sep 2017'`; do
#		echo "$PARENT_FOLDER/$FILE_EXT/txt"
		./upload_to_box.sh "$PARENT_FOLDER/$FILE_EXT/txt" $txt
	done

	# spc files
	for spc in `find "$ANNIE_PATH"/*_test -type f -name "*[0-9]_$FILE_EXT.spc" -newermt '14 sep 2017'`; do
#		echo "$PARENT_FOLDER/$FILE_EXT/spc"
		./upload_to_box.sh "$PARENT_FOLDER/$FILE_EXT/spc" $spc
	done

done < "$ANNIE_PATH/$INPUT_FILE"
