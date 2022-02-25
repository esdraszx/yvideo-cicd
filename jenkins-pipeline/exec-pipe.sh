#!/bin/bash

while true;
do
	command=$(cat /srv/y-video-back-end/yvideo-cicd/jenkins-pipeline/pipe)
	if [ $command == "/srv/y-video-back-end/y-video-back-end/build-front-end.sh" ]; then
		eval "$command"
	fi
	if [ $command == "/srv/y-video-back-end/server-deploy.sh" ]; then
		eval "$command"
	fi
done

#add to cron using 

#@reboot /path/exec-pipe.sh
