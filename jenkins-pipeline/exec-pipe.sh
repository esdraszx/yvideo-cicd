#!/bin/bash

while true; do eval "$(cat /srv/y-video-back-end/yvideo-cicd/jenkins-pipeline/pipe)"; done

#add to cron using 

#@reboot /path/exec-pipe.sh
