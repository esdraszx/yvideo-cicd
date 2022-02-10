#!/bin/bash

port=8080
username=esdraszx
id=$(id -u $username)
group_id=$(id -g $username)
jenkins_url='http://localhost:8080'


#backend_key=$(cat /var/lib/jenkins/.ssh/backend_id_ed25519)
#frontend_key=$(cat /var/lib/jenkins/.ssh/frontend_id_ed25519)


backend_key=test
frontend_key=test

#pull image from docker if needed
#docker pull jenkinsci/blueocean

#building an image would case the image to start from zero
docker build -t jenkins:jcasc . #-> note the period indicating the current directory


echo "Starting Docker"
echo "username $username"
#echo "id: $id   group:  $group_id"

docker run --name jenkins --rm -d -p $port:$port --env BACKEND_KEY=$backend_key --env FRONTEND_KEY=$frontend_key jenkins:jcasc

#wait for the jenkins server to initialize
echo "Waiting for Docker & Jenkins to initialize"
sleep 30s

#CREATE CRUMB FOR API REQUESTS
crumb_json=$(curl -s --cookie-jar /tmp/cookies -u yvideoadmin:yvideoadminpassword $jenkins_url/crumbIssuer/api/json)

#echo "RECEIVED RESPONSE $crumb_json"

crumb_token=$(echo $crumb_json | jq -r '.crumb')

#echo "CRUMB Token $crumb_token"

#CREATE API PERSONAL TOKEN
user_json=$(curl -XPOST --cookie /tmp/cookies $jenkins_url/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=api_token -u yvideoadmin:yvideoadminpassword  -H "Jenkins-Crumb: $crumb_token")

#echo "RECEIVED RESPONSE $user_json"

user_token=$(echo $user_json | jq -r '.data.tokenValue')

echo $user_token > latest_user_token.txt

#echo "User Token $user_token"

echo "Creating Jobs"

curl -s -XPOST "$jenkins_url/createItem?name=yvideo-frontend" -u yvideoadmin:$user_token --data-binary @yvideo-front-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

curl -s -XPOST "$jenkins_url/createItem?name=yvideo-backend" -u yvideoadmin:$user_token --data-binary @yvideo-back-config.xml -H "Content-Type:text/xml" #the xml file should be in the current directory

echo "Finished"
