#!/bin/bash

# This script checks ./docket/ for a new jar and performs proper archiving
# It then replaces the active jar in the current directory, triggering y-video-back-end.path  and .service to re-deploy. 

deployment_path="/srv/y-video-back-end" # Dir where we're going to start our other paths and deploy
date=$(date +%Y.0%m.%d.%T)
filename="y-video-back-end.jar"
src_path="$deployment_path/y-video-back-end"
archive_filename="$filename.$date"
deployment_file="$deployment_path/$filename"
docket_path="$deployment_path/docket"

cd $deployment_path
# Archive existing thing
if test -f "$deployment_file"
then
    cp "$deployment_file" "$deployment_path/archives/$archive_filename" &&
	echo "File archived: $archive_filename" &&
# place new thing  for systemd deployment
	mv -f "$docket_path/$filename" "$deployment_file" &&
	sudo systemctl	restart y-video-back-end &&
	echo "deployment archived and repositioned. Verify reload at https://yvideodev.byu.edu"    
else
    echo "No file to archive."
    exit 1
fi

exit 0
