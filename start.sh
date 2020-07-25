#!/bin/sh

sudo docker run -d \
    -p 21000:21000 \
    -v ${PWD}/pre-conf:/opt/apache-atlas-1.1.0/conf \
    --name atlas \
    apache-atlas:1.1.0 \
    /opt/apache-atlas-1.1.0/bin/atlas_start.py
