#!/bin/bash

export USER="docker"

# Kill/delete already run vnc
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

# start vnc server
# vncserver :1 -geometry 1280x700 -depth 24 && tail -F ~/.vnc/*.log
vncserver :${VNCDISPLAY} -geometry ${VNCGEOMETRY} -depth ${VNCDEPTH} && websockify --web /noVNC 8080 localhost:5901 && tail -F ~/.vnc/*.log
