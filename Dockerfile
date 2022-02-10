FROM jenkinsci/blueocean
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml


#RUN mkdir /var/jenkins_home/jobs/yvideo-backend
#RUN mkdir /var/jenkins_home/jobs/yvideo-frontend
#COPY yvideo-back-config.xml /var/jenkins_home/jobs/yvideo-backend/config.xml
#COPY yvideo-front-config.xml /var/jenkins_home/jobs/yvideo-frontend/config.xml
#COPY credentials.xml /var/jenkins_home/credentials.xml

#USER <UID>[:<GID>]


