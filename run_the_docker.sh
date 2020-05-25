#!/bin/bash

DOCKER_NAME="$1"

if test -z "$1" 
then
      echo "You have to specify the docker image to use"
else
      echo "Using image $DOCKER_NAME ..."
fi
# TODO ADD file saving for docker number https://stackoverflow.com/questions/5965737/how-can-one-store-a-variable-in-a-file-using-bash

xhost +local:docker
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
sudo touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | sudo xauth -f $XAUTH nmerge -

sudo nvidia-docker run -it --volume=$XSOCK:$XSOCK:rw --volume=$XAUTH:$XAUTH:rw --env="XAUTHORITY=${XAUTH}" --env="DISPLAY" $DOCKER_NAME
