# Jenkins & Docker Instructions
For the CI/CD pipeline that connects the github repositories to our server, we decided to use Jenkins. However, instead of running Jenkins in the host, we opted to use a container to add one layer between Jenkins and the host for security purposes and migration benefits. 
There is a docker image that already has jenkins installed, so we are using that image instead of creating our own. The first step is to get docker ready. 

## Docker

### GET BLUEOCEAN IMAGE 
``` docker pull jenkinsci/blueocean ``` 
### EDIT BLUEOCEAN IMAGE
Create a Dockerfile with the following content:
```
FROM jenkinsci/blueocean
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false #do not run setup wizard with security token
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml #pull configuration from file
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt #pass plugin list to container
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt #run plugins
COPY casc.yaml /var/jenkins_home/casc.yaml #pass configuration to container
```
**Plugins are stored in a text file that can be read by the container**
**Configuration as code is in the casc.yaml in a key value pair format**
Build the image through the dockerfile which contains all links to the plugins and casc any changes to the image would require a new build.
```
docker build -t jenkins:jcasc .  <- see the period at the end meaning this is the current directory to get the Dockerfile
```
### RUN NEW IMAGE
**See script for more information about variables**
```
docker run -u $id:$group_id --rm -d --name jenkins-jcasc -p $port:8080 -p 50000:50000 \ 
-v /srv/y-video-back-end:/srv/y-video-back-end \
-v /srv/jenkins-data:/var/jenkins_home \
--env BACKEND_KEY="$backend_key" --env FRONTEND_KEY="$frontend_key" jenkins:jcasc
```
This docker command runs the image with the parameters necessary to run the container in the back-end server. This command runs detached from the terminal and the container is marked to be removed if it were to stop, so if there is an issue remove the ```--rm``` flag to keep the container logs after the container stops running. 

## Jenkins
### Configuration
After the docker container is running. The image already has jenkins so there is no need to install it again. However, it is necessary to pass configuration as code from the ```casc.yaml``` file. This file contains all the basic configuration for jenkins including credentials, security, authentication, location, and github plugin configuration.

### Jobs
Jenkins jobs can be created from an existing ```job.yaml``` file. In our project we use ```yvideo-back-config.yaml``` and ```yvideo-front-config.yaml```. We can use the jenkins API in the container to create jobs with the following endpoint

**API CALL TO CREATE A NEW JOB FROM EXISTING XML FILE**
```
curl -s -XPOST 'http://serverAddress.com/createItem?name=yvideo-frontend' -u yvideoadmin:119c7af4b909c16a5486b20fb550ab9841 --data-binary @yvideo-front-config.xml -H "Content-Type:text/xml"
```
**The @config.yaml requires the config to be in the same directory as the running script or command**

# Server Script
Everything described above has been automated using a shell script. The purpose of the script is to minimize the manual work by the developer when creating a new Jenkins instance. The development and the production server should both use the same ```docker-run-server.sh```. There is a ```docker-run-local.sh``` which contains commands for creating a local instance for testing. 
The docker script can be broken down into steps
1. Variables


**port** -> the port running the jenkins server in the host

**username** -> the user running the docker command

**id** -> username id. This is required to match permissions between the user in the container and the host

**group_id** -> username group id.

**jenkins_url** -> url to reach jenkins server from outside the host

**backend_key** -> backend ssh private key for deployment

**frontend_key** -> frontend ssh private key for deployment

**container_id** -> the container id after ```docker run```

**container_succes** -> will store information to check if the container is running

**crumb_json** -> response from jenkins containing a crumb token for authentication

**crumb_token** -> retrieve token from json

**user_json** -> response after authentication

**user_token** -> user api token

2. Remove all data from the previous Jenkins instance in the container **OPTIONAL**


```rm -rf /srv/jenkins-data/*```

3. Pass configuration as code to the jenkins home directory **OPTIONAL**

```cp casc.yaml /srv/jenkins-data/casc.yaml```

4. Build docker image from dockerfile

```docker build -t jenkins:jcasc . #-> note the period indicating the current directory```

5. Run docker container

```docker run -u $id:$group_id --rm -d --name jenkins-jcasc -p $port:8080 -p 50000:50000 -v /srv/y-video-back-end:/srv/y-video-back-end -v /srv/jenkins-data:/var/jenkins_home --env BACKEND_KEY="$backend_key" --env FRONTEND_KEY="$frontend_key" jenkins:jcasc```

6. Check if the container is running or not. **See script for more details**
7. Wait for Jenkins to be ready **See script for more details**
8. After Jenkins is ready, get crumb token for authentication
9. Generate a user API token and save the token in a file for later use in github

**The user token generated needs to be added to the github webhook as the secret using ```x-www-url-encode```**

10. Create jobs using Jenkins API
11. Access Jenkins instance and apply job configuration to make sure changes are saved **See script for more details** 

