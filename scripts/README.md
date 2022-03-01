# Scripts

There are three main scripts required for build and deployment of the application. Two of the scripts are found in this directory and they need to be placed the server. The third script can be found in the [back-end repo](https://github.com/BYU-ODH/y-video-back-end/blob/development/build-front-end.sh)

## deploy.sh

This script takes care of watching a certain directory for new files, archiving the file, and restarting the main application service. 
This script can be located at ```/srv/y-video-back-end/deploy.sh```

## server-build.sh

This script is used to build a new version of the application. This script grabs the back-end (including the front-end latest build) and puts it in a ```JAR``` file that the main application [service](https://github.com/esdraszx/yvideo-cicd/blob/main/services/y-video-back-end.service) can execute.
This script can be located at ```/srv/y-video-back-end/server-build.sh```

## build-front-end.sh

This script builds the front-end part of the application. This way the back-end code can serve that build for development and deployment. This script is part of the 
[back-end repository](https://github.com/BYU-ODH/y-video-back-end)

