#!/bin/sh

docker run --detach \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /apache-atlas/bin/atlas_start.py