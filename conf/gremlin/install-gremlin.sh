#!/bin/bash

cd /opt

SOURCEDIR=$(pwd)
GREMLINVER=3.4.6

#wget http://mirror.linux-ia64.org/apache/tinkerpop/${GREMLINVER}/apache-tinkerpop-gremlin-server-${GREMLINVER}-bin.zip
wget https://archive.apache.org/dist/tinkerpop/${GREMLINVER}/apache-tinkerpop-gremlin-server-${GREMLINVER}-bin.zip
unzip apache-tinkerpop-gremlin-server-${GREMLINVER}-bin.zip
rm -f apache-tinkerpop-gremlin-server-${GREMLINVER}-bin.zip

#wget http://mirror.linux-ia64.org/apache/tinkerpop/${GREMLINVER}/apache-tinkerpop-gremlin-console-${GREMLINVER}-bin.zip
wget https://archive.apache.org/dist/tinkerpop/${GREMLINVER}/apache-tinkerpop-gremlin-console-${GREMLINVER}-bin.zip
unzip apache-tinkerpop-gremlin-console-${GREMLINVER}-bin.zip
rm -f apache-tinkerpop-gremlin-console-${GREMLINVER}-bin.zip

ln -s /opt/apache-atlas-2.1.0/server/webapp/atlas/WEB-INF/lib/*.jar /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib 2>/dev/null
rm -f /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib/atlas-webapp-2.1.0.jar
rm -f /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib/netty-3.10.5.Final.jar
rm -f /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib/netty-all-4.0.52.Final.jar

ln -s ${SOURCEDIR}/gremlin/gremlin-server-atlas.yaml /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/conf
ln -s ${SOURCEDIR}/gremlin/janusgraph-hbase-solr.properties /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/conf

rm -f /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib/groovy-*.jar
ln -s /opt/apache-atlas-2.1.0/server/webapp/atlas/WEB-INF/lib/groovy-*.jar /opt/apache-tinkerpop-gremlin-server-${GREMLINVER}/lib

sed -i 's/assistive_technologies=org.GNOME.Accessibility.AtkWrapper/#assistive_technologies=org.GNOME.Accessibility.AtkWrapper/g' /etc/java-8-openjdk/accessibility.properties

echo "Gremlin Server and Console installed!"