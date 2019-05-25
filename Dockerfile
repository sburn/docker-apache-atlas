FROM scratch
FROM ubuntu:18.04
LABEL maintainer="vadim@clusterside.com"
ARG VERSION=2.0.0

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
        maven \
        wget \
        git \
        python \
        openjdk-8-jdk-headless \
        patch

RUN cd /tmp \
    && wget http://mirror.linux-ia64.org/apache/atlas/${VERSION}/apache-atlas-${VERSION}-sources.tar.gz \
    && mkdir /tmp/atlas-src \
    && tar --strip 1 -xzvf apache-atlas-${VERSION}-sources.tar.gz -C /tmp/atlas-src \
    && rm apache-atlas-${VERSION}-sources.tar.gz \
    && cd /tmp/atlas-src \
    && wget --no-check-certificate https://github.com/apache/atlas/pull/20.patch \
    && git apply ./20.patch \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && mvn clean -DskipTests install \
    && mvn clean -DskipTests package -Pdist \
    && mvn clean -DskipTests package -Pdist,embedded-hbase-solr \
    && tar -xzvf /tmp/atlas-src/distro/target/apache-atlas-${VERSION}-server.tar.gz -C /opt \
    && rm -Rf /tmp/atlas-src

COPY atlas_start.py.patch atlas_config.py.patch /opt/apache-atlas-${VERSION}/bin
COPY pre-conf/atlas-application.properties /opt/apache-atlas-${VERSION}/conf/atlas-application.properties
COPY pre-conf/atlas-env.sh /opt/apache-atlas-${VERSION}/conf/atlas-env.sh

RUN cd /opt/apache-atlas-${VERSION}/bin \
    && patch -b -f < atlas_start.py.patch \
    && patch -b -f < atlas_config.py.patch

RUN cd /opt/apache-atlas-${VERSION}/bin \
    && ./atlas_start.py -setup || true

VOLUME ["/opt/apache-atlas-2.0.0/conf", "/opt/apache-atlas-2.0.0/logs"]
