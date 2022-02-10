GET BLUEOCEAN IMAGE

docker pull jenkinsci/blueocean

EDIT BLUEOCEAN IMAGE

this is done through the docker file which contains all links to the plugins and casc

any changes to the image would require a new build

docker build -t jenkins:jcasc .  <- see the period at the end meaning this is the current directory to get the Dockerfile

**LOCAL JENKINS API TOKEN FOR USER yvideoadmin** 119c7af4b909c16a5486b20fb550ab9841

RUN NEW IMAGE

docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc <- this is to run it locally. See command to run jenkins in the server

docker run -u jenkins --rm -d --name jenkins -p 3001:8080 -p 50000:50000 -v /srv/y-video-back-end:/srv/y-video-back-end -v /srv/jenkins-data:/var/jenkins_home -v /var/lib/jenkins/.ssh:/var/lib/jenkins/.ssh jenkinsci/blueocean

API CALL TO CREATE A NEW JOB FROM EXISTING XML FILE

curl -s -XPOST 'http://localhost:8080/createItem?name=yvideo-frontend' -u yvideoadmin:119c7af4b909c16a5486b20fb550ab9841 --data-binary @yvideo-front-config.xml -H "Content-Type:text/xml"

curl -s -XPOST 'http://localhost:8080/createItem?name=yvideo-backend' -u yvideoadmin:119c7af4b909c16a5486b20fb550ab9841 --data-binary @yvideo-back-config.xml -H "Content-Type:text/xml"

