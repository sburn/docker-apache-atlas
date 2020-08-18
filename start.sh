#!/bin/sh

docker run -d \
    -p 21000:21000 \
    -v ${PWD}/pre-conf:/opt/apache-atlas-2.1.0/conf \
    --name atlas \
    sburn/apache-atlas:2.1.0 \
    /opt/apache-atlas-2.1.0/bin/atlas_start.py
