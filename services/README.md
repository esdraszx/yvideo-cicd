# Services

Services are used to deploy changes and run certain scripts that are needed by the CI/CD pipeline and the application itself. 

## yvideo user

The first step is to have the necessary permissions to run the scripts with sudo priviledge, but without the need of a password. This user will be using by the services. Create a file in the ```/etc/sudoers.d/020_sudo_yvideo``` with the contents of the **sudo_yvideo** file in this directory.
This file contains the necessary overrides and the commands the yvideo user can use.

Make sure that this file is owned by root and has permissions of 440
```
chmod 440 /etc/sudoers.d/020_sudo_yvideo
chown root:root /etc/sudoers.d/020_sudo_yvideo
```

## y-video-deploy

This service is used to deploy a new server build. This service executes the script found at /srv/y-video-back-end/deploy.sh in this repository it is found at [deploy.sh](https://github.com/esdraszx/yvideo-cicd/blob/main/scripts/deploy.sh). 

To configure this service follow these steps:

1. Create file at /etc/systemd/system/y-video-deploy.path
2. **Copy** the contents from the y-video-deploy.path file in this repository to the file you created
3. Create file at /etc/systemd/system/y-video-deploy.service
4. **Copy** the contents from the y-video-deploy.service file in this repository to the file you created

Make sure that the service is enabled, and that it can start.

## y-video-back-end

This services takes care of the web startup for the YVideo application. This service executes the ```JAR``` file containing the entire application. 

To configure this service follow these steps:

1. Create file at /etc/systemd/system/y-video-back-end.service
2. **Copy** the contents from the y-video-back-end.service file in this repository to the file you created

