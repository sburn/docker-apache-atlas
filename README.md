[![License: Apache 2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)

Apache Atlas Docker image
=======================================

This Apache Atlas is build from release 2.0.0 source tarball and patched to be run in a container.

Configuration
=============
1. Pull the image:

```bash
sudo docker pull sburn/apache-atlas
```

2. Start Apache Atlas container exposing default port 21000:

```bash
sudo docker run --detach \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-2.0.0/bin/atlas_start.py
```

Usage
=====

Apache Atlas is build with embeded HBase + Solr and pre-setuped (atlas_start.py -setup).
If you want to use external Atlas backends, set them up in the config files according to [the documentation](https://atlas.apache.org/Configuration.html).

Gracefully stop Atlas:

```bash
sudo docker exec -ti atlas /opt/apache-atlas-2.0.0/bin/atlas_stop.py
```

Start Atlas overriding settings by environment variables 
(to support large number of metadata objects for example):

```bash
sudo docker run --detach \
    -e "ATLAS_SERVER_OPTS=-server -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+PrintTenuringDistribution -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dumps/atlas_server.hprof -Xloggc:logs/gc-worker.log -verbose:gc -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=1m -XX:+PrintGCDetails -XX:+PrintHeapAtGC -XX:+PrintGCTimeStamps"
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-2.0.0/bin/atlas_start.py
```

Expose logs directory on the host to view them directly:

```bash
sudo docker run --detach \
    -v ${PWD}/atlas-logs:/opt/apache-atlas-2.0.0/logs \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-2.0.0/bin/atlas_start.py
```

Expose conf directory on the host to edit configuration files directly:

```bash
sudo docker run --detach \
    -v ${PWD}/pre-conf:/opt/apache-atlas-2.0.0/conf \
    -p 21000:21000 \
    --name atlas \
    sburn/apache-atlas \
    /opt/apache-atlas-2.0.0/bin/atlas_start.py
```

Environment Variables
=====================

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
===========

Bugs are tracked on [GitHub Issues](https://github.com/sburn/docker-apache-atlas/issues).
In case of trouble, please check there to see if your issue has already been reported.
If you spotted it first, help us smash it by providing detailed and welcomed feedback.

Credits
=======

Contributors
------------

* Vadim Korchagin <vadim@clusterside.com>

Maintainer
----------

This images is maintained by [Vadim Korchagin](mailto:vadim@clusterside.com)

* https://github.com/sburn/docker-apache-atlas
