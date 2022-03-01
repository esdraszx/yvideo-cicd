#!/bin/bash

#WARNING THIS SCRIPT SHOULD ONLY RUN WITH THE REQUIRED PERMISSIONS FOR DOCKER
port=3001
username=jenkins
id=$(id -u $username)
group_id=$(id -g $username)
jenkins_url='https://jenkins.yvideodev.byu.edu'
backend_key=$(cat /var/lib/jenkins/.ssh/backend_id_ed25519)
frontend_key=$(cat /var/lib/jenkins/.ssh/frontend_id_ed25519)
crumb_json=""
container_succes=false
cred_username=$(jq -r '.username' credentials.json)
cred_password=$(jq -r '.password' credentials.json)

#DELETE PREVIOUS IMAGE INFORMATION
#rm -rf /srv/jenkins-data/* #DO THIS ONLY IF YOU WILL BUILD THE IMAGE AGAIN

#SEND THE CONFIGURATION FILE TO JENKINS DATA THIS DIRECTORY SHOULD EXIST BEFORE RUNNING THE COMMAND
#cp casc.yaml /srv/jenkins-data/casc.yaml

#pull image from docker if needed
#docker pull jenkinsci/blueocean

#building an image again will delete everything in the image or tag
#docker build -t jenkins:jcasc . #-> note the period indicating the current directory

echo "Starting Script"
echo "Running docker as $username"
#echo "id: $id   group:  $group_id"

#GET CONTAINER ID FROM DOCKER RUN COMMAND
container_id=$(docker run -u $id:$group_id --rm -d --name jenkins-jcasc -p $port:8080 -p 50000:50000 -v /srv/y-video-back-end:/srv/y-video-back-end -v /srv/jenkins-data:/var/jenkins_home --env BACKEND_KEY="$backend_key" --env FRONTEND_KEY="$frontend_key" jenkins:jcasc)


#CHECK TO SEE IF THE CONTAINER WAS CREATED
if [ -n $container_id ]; then
	container_success=$(docker inspect -f {{.State.Running}} $container_id)
else
	echo "ERROR: failed to create container"
	exit 1
fi

#CHECK TO SEE IF THE CONTAINER IS RUNNING
if [ $container_success ]; then
	echo "Container is up and running with id $container_id \n"
else
	echo "ERROR: the container was created, but it is not running"
	exit 1
fi

#WHEN JENKINS IS READY GET CRUMB COOKIE AND CREATE JOBS
while [ -z $crumb_json ]
do
	echo "Waiting for Jenkins to be ready..."
	sleep 5s
	response=$(curl -s --cookie-jar /tmp/cookies -u $cred_username:$cred_password $jenkins_url/crumbIssuer/api/json)
	response_first_char=${response:0:1}
	if [ "$response_first_char" == "{" ]; then
		crumb_json=$(echo $response)
	fi
done

echo "Jenkins is ready. Creating jobs..."

#GET CRUMB TOKEN FROM CRUMB RESPONSE
crumb_token=$(echo $crumb_json | jq -r '.crumb')

#CREATE API PERSONAL TOKEN
user_json=$(curl -XPOST --cookie /tmp/cookies $jenkins_url/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=api_token -u $cred_username:$cred_password  -H "Jenkins-Crumb: $crumb_token")

#SAVE PERSONAL TOKEN
user_token=$(echo $user_json | jq -r '.data.tokenValue')

#SAVE PERSONAL TOKEN TO A FILE IN CASE IT IS NEEDED IN GITHUB WEBHOOK
echo $user_token > latest_user_token.txt

#CREATE JOB THROUGH JENKINS API
echo "Creating Jobs"

#CREATES A JOB FROM AN EXISTING XML FILE
curl -s -XPOST "$jenkins_url/createItem?name=yvideo-frontend" -u $cred_username:$user_token --data-binary @yvideo-front-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

#CREATES A JOB FROM AN EXISTING XML FILE
curl -s -XPOST "$jenkins_url/createItem?name=yvideo-backend" -u $cred_username:$user_token --data-binary @yvideo-back-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

echo "Next steps"

echo -e "Copy token to github webhook in the github repositories for the front and back end. \n Token: $user_token \n \n"

echo -e "Access Jenkins and apply the config for both frontend and backend jobs.\n If everything is good, the config will show a SAVED message.\n If there is a problem, a log will be created \n \n"

echo "Finished"
