#!/bin/bash
IMAGENAME=vscode
WORKSPACE=`pwd`

ABSOLUTE_SCRIPT_FILENAME=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$ABSOLUTE_SCRIPT_FILENAME"`

echo "script dir is: " $SCRIPT_DIR

xhost +local: && docker build -t $IMAGENAME $SCRIPT_DIR && docker run --name $IMAGENAME \
-it \
--rm \
--privileged \
-v $WORKSPACE:/workspace \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
-v /dev/shm:/dev/shm \
-e DISPLAY=unix${DISPLAY} \
-v $SCRIPT_DIR/userdata:/userdata:Z \
-u vscode \
 $IMAGENAME
 
