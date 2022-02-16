FROM jenkinsci/blueocean
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
RUN rm /etc/apk/keys/sgerrand.rsa.pub
RUN wget -P /etc/apk/keys/ https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN apk add --no-cache --repository=https://apkproxy.herokuapp.com/sgerrand/alpine-pkg-leiningen leiningen=2.7.1-r0
RUN apk add --update nodejs npm
