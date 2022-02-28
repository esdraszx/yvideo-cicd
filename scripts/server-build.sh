#!/bin/bash

# This script deploys the back-end

cd /srv/y-video-back-end/y-video-back-end

git pull origin development

lein clean

lein uberjar

cp /srv/y-video-back-end/y-video-back-end/target/y-video-back-end.jar /srv/y-video-back-end/docket/y-video-back-end.jar


