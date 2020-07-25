[![Atlas version](https://img.shields.io/badge/Atlas-1.1.0-brightgreen.svg)](https://github.com/sburn/docker-apache-atlas)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
![Docker Pulls](https://img.shields.io/docker/pulls/sburn/apache-atlas.svg)

Apache Atlas Docker image
=======================================

This `Apache Atlas` is built from the 1.1.0-release source tarball and patched to be run in a Docker container.

Atlas is built `with embedded Cassandra + Solr` and it is pre-initialized (atlas_start.py -setup), so you can run Atlas after image download without additional steps.

If you want to use external Atlas backends, set them up according to [the documentation](https://atlas.apache.org/#/Configuration).

Basic usage
-----------
1. Pull the image:

```bash
docker pull sburn/apache-atlas:1.1.0
```

2. Start Apache Atlas in a container exposing Web-UI port 21000:

```bash
docker run --detach \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas:1.1.0 \
    /opt/apache-atlas-1.1.0/bin/atlas_start.py
```

Please, take into account that at fist run Atlas initialize internal schemas and `first startup may take up to 10 mins` depending on host machine performance.

Usage options
-------------

Stop Atlas gracefully:

```bash
docker exec -ti atlas /opt/apache-atlas-1.1.0/bin/atlas_stop.py
```

Check Atlas startup script output:

```bash
docker logs -f atlas
```

Check interactively Atlas application.log:

```bash
docker exec -it atlas tail -f /opt/apache-atlas-1.1.0/logs/application.log
```

Start Atlas overriding settings by environment variables 
(to support large number of metadata objects for example):

```bash
docker run --detach \
    -e "ATLAS_SERVER_OPTS=-server -XX:SoftRefLRUPolicyMSPerMB=0 \
    -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC \
    -XX:+CMSParallelRemarkEnabled -XX:+PrintTenuringDistribution \
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dumps/atlas_server.hprof \
    -Xloggc:logs/gc-worker.log -verbose:gc -XX:+UseGCLogFileRotation \
    -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=1m -XX:+PrintGCDetails \
    -XX:+PrintHeapAtGC -XX:+PrintGCTimeStamps" \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-1.1.0/bin/atlas_start.py
```

Expose logs directory on the host to view them directly:

```bash
docker run --detach \
    -v ${PWD}/atlas-logs:/opt/apache-atlas-1.1.0/logs \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-1.1.0/bin/atlas_start.py
```

Expose conf directory on the host to edit configuration files directly:

```bash
docker run --detach \
    -v ${PWD}/pre-conf:/opt/apache-atlas-1.1.0/conf \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-1.1.0/bin/atlas_start.py
```

Environment Variables
---------------------

The following environment variables are available for configuration:

| Name | Default | Description |
|------|---------|-------------|
| JAVA_HOME | /usr/lib/jvm/java-8-openjdk-amd64 | The java implementation to use. If JAVA_HOME is not found we expect java and jar to be in path
| ATLAS_OPTS | <none> | any additional java opts you want to set. This will apply to both client and server operations
| ATLAS_CLIENT_OPTS | <none> | any additional java opts that you want to set for client only
| ATLAS_CLIENT_HEAP | <none> | java heap size we want to set for the client. Default is 1024MB
| ATLAS_SERVER_OPTS | <none> |  any additional opts you want to set for atlas service.
| ATLAS_SERVER_HEAP | <none> | java heap size we want to set for the atlas server. Default is 1024MB
| ATLAS_HOME_DIR | <none> | What is is considered as atlas home dir. Default is the base location of the installed software
| ATLAS_LOG_DIR | <none> | Where log files are stored. Defatult is logs directory under the base install location
| ATLAS_PID_DIR | <none> | Where pid files are stored. Defatult is logs directory under the base install location
| ATLAS_EXPANDED_WEBAPP_DIR | <none> | Where do you want to expand the war file. By Default it is in /server/webapp dir under the base install dir.


Bug Tracker
-----------

Bugs are tracked on [GitHub Issues](https://github.com/sburn/docker-apache-atlas/issues).
In case of trouble, please check there to see if your issue has already been reported.
If you spotted it first, help us smash it by providing detailed and welcomed feedback.

Maintainer
----------

This image is maintained by [Vadim Korchagin](mailto:vadim@clusterside.com)

* https://github.com/sburn/docker-apache-atlas
