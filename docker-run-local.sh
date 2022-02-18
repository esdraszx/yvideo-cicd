#!/bin/bash

port=8080
username=esdraszx
id=$(id -u $username)
group_id=$(id -g $username)
jenkins_url='http://localhost:8080' #MAKE SURE THIS MATCHES THE CASC.YML URL
#backend_key=$(cat /var/lib/jenkins/.ssh/backend_id_ed25519)
#frontend_key=$(cat /var/lib/jenkins/.ssh/frontend_id_ed25519)
backend_key=test
frontend_key=test
crumb_json=""
container_succes=false
RED='\e[1;31m'
GREEN='\e[0;32m'
DEFAULT_COLOR='\e[0m'

#pull image from docker if needed
#docker pull jenkinsci/blueocean

#building an image would case the image to start from zero
#docker build -t jenkins:jcasc . #-> note the period indicating the current directory

echo "Starting Script"
echo "Running docker as $username"
#echo "id: $id   group:  $group_id"

#GET CONTAINER ID FROM DOCKER RUN COMMAND
container_id=$(docker run --name jenkins --rm -d -p $port:$port --env BACKEND_KEY=$backend_key --env FRONTEND_KEY=$frontend_key jenkins:jcasc)

#CHECK TO SEE IF THE CONTAINER WAS CREATED
if [ -n $container_id ]
then
	container_success=$(docker inspect -f {{.State.Running}} $container_id)
else
	echo -e "${RED}ERROR: failed to create container"
	exit 1
fi

#CHECK TO SEE IF THE CONTAINER IS RUNNING

if [ $container_success ]
then
	echo -e "${GREEN}Container is up and running with id ${DEFAULT_COLOR} $container_id \n"
else
	echo -e "${RED}ERROR: docker run failed to start the container \n"
	exit 1
fi

#WHEN JENKINS IS READY GET CRUMB COOKIE AND CREATE JOBS

while [ -z $crumb_json ]
do
	echo "Waiting for Jenkins to be Ready"
	sleep 5s
	response=$(curl -s --cookie-jar /tmp/cookies -u yvideoadmin:yvideoadminpassword $jenkins_url/crumbIssuer/api/json)
	if [ -n $response ]
	then
		crumb_json=$(echo $response)
	fi
done

echo "Jenkins is ready. Creating Jobs"

#GET CRUMB TOKEN FROM CRUMB RESPONSE
crumb_token=$(echo $crumb_json | jq -r '.crumb')

#CREATE API PERSONAL TOKEN
user_json=$(curl -XPOST --cookie /tmp/cookies $jenkins_url/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=api_token -u yvideoadmin:yvideoadminpassword  -H "Jenkins-Crumb: $crumb_token")

#SAVE PERSONAL TOKEN
user_token=$(echo $user_json | jq -r '.data.tokenValue')

#SAVE PERSONAL TOKEN TO A FILE IN CASE IT IS NEEDED IN GITHUB WEBHOOK
echo $user_token > latest_user_token.txt

#CREATE JOB THROUGH JENKINS API
echo "Creating Jobs"

#CREATES A JOB FROM AN EXISTING XML FILE
curl -s -XPOST "$jenkins_url/createItem?name=yvideo-frontend" -u yvideoadmin:$user_token --data-binary @yvideo-front-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

#CREATES A JOB FROM AN EXISTING XML FILE
curl -s -XPOST "$jenkins_url/createItem?name=yvideo-backend" -u yvideoadmin:$user_token --data-binary @yvideo-back-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

echo "Finished"


#INSTALL NPM AND LEININGEN IN THE CONTAINER
#docker exec -d --user=root jenkins-jcasc wget -P /etc/apk/keys/ https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub

#RUN apk add --no-cache --repository=https://apkproxy.herokuapp.com/sgerrand/alpine-pkg-leiningen leiningen=2.7.1-r0
#docker exec -d --user=root jenkins-jcasc apk add --no-cache --repository=https://apkproxy.herokuapp.com/sgerrand/alpine-pkg-leiningen leiningen=2.9.7-r0

#RUN apk add --update nodejs npm
#docker exec -d --user=root jenkins-jcasc apk add --update nodejs npm
