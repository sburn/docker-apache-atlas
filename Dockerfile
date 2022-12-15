FROM ubuntu:20.04
LABEL maintainer="vadim@clusterside.com"

ARG VERSION=2.3.0
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV MAVEN_OPTS="-Xms2g -Xmx2g"
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

RUN mkdir -p /tmp/atlas-src \
    && mkdir -p /apache-atlas \
    && mkdir -p /gremlin

COPY pom.xml.patch /tmp/atlas-src/

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-utils \
    && apt-get -y install \
        maven \
        wget \
        python \
        openjdk-8-jdk-headless \
        patch \
        unzip \
    && cd /tmp \
    && wget https://dlcdn.apache.org/atlas/${VERSION}/apache-atlas-${VERSION}-sources.tar.gz \
    && tar --strip 1 -xzvf apache-atlas-${VERSION}-sources.tar.gz -C /tmp/atlas-src \
    && rm apache-atlas-${VERSION}-sources.tar.gz \
    && cd /tmp/atlas-src \
    && sed -i 's/http:\/\/repo1.maven.org\/maven2/https:\/\/repo1.maven.org\/maven2/g' pom.xml \
    && patch -b -f < pom.xml.patch \
    && mvn clean \
        -Dmaven.repo.local=/tmp/atlas-src/.mvn-repo \
        -Dhttps.protocols=TLSv1.2 \
        -DskipTests \
        -Drat.skip=true \
        package -Pdist,embedded-hbase-solr \
    && tar --strip 1 -xzvf /tmp/atlas-src/distro/target/apache-atlas-${VERSION}-server.tar.gz -C /apache-atlas \
    && rm -Rf /tmp/atlas-src \
    && rm -Rf /root/.npm \
    && apt-get -y --purge remove \
        maven \
        unzip \
    && apt-get -y autoremove \
    && apt-get -y clean

COPY conf/hbase/hbase-site.xml.template /apache-atlas/conf/hbase/hbase-site.xml.template
COPY atlas_start.py.patch atlas_config.py.patch /apache-atlas/bin/
COPY conf/atlas-env.sh /apache-atlas/conf/atlas-env.sh
COPY conf/gremlin /gremlin/

WORKDIR /apache-atlas/bin
RUN patch -b -f < atlas_start.py.patch \
    && patch -b -f < atlas_config.py.patch

WORKDIR /apache-atlas/conf
RUN sed -i 's/\${atlas.log.dir}/\/apache-atlas\/logs/g' atlas-log4j.xml \
    && sed -i 's/\${atlas.log.file}/application.log/g' atlas-log4j.xml

WORKDIR /apache-atlas/bin
RUN ./atlas_start.py -setup || true
RUN ./atlas_start.py & \
    touch /apache-atlas/logs/application.log \
    && tail -f /apache-atlas/logs/application.log | sed '/Defaulting to local host name/ q' \
    && sleep 10 \
    && ./atlas_stop.py \
    && truncate -s0 /apache-atlas/logs/application.log

CMD ["/bin/bash", "-c", "/apache-atlas/bin/atlas_start.py; tail -fF /apache-atlas/logs/application.log"]
