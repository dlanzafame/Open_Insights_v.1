#!/bin/bash

GRAYLOG_CONTAINER=$1
ELASTIC_CONTAINER=$2
ASSESMENT_SCRIPT=$3

usage() {
	echo "USAGE: $0 <graylog container name or id> <elasticsearch container name or id> <assessment script>"
	exit 1
}

if [ -z "${GRAYLOG_CONTAINER}" -o -z "${ELASTIC_CONTAINER}" ] ; then echo "ERROR: Graylog or Elasticsearch container name/id not provided" ; usage ; fi
if [ -z "${ASSESMENT_SCRIPT}" -o ! -f "${ASSESMENT_SCRIPT}" ] ; then echo "ERROR: Assessment script not provided or file does not exist" ; usage ; fi

export GRAYLOG_VERSION=$(docker inspect ${GRAYLOG_CONTAINER} -f '{{index .Config.Labels "org.label-schema.name"}} {{index .Config.Labels "org.label-schema.version"}}' | grep "^Graylog Docker Image" | grep -c -E -o -e"\W[4]" | tr -d "\n")
export NCPU=$(docker exec -ti ${GRAYLOG_CONTAINER} /bin/bash -c 'lscpu | grep -e"^CPU(s)" | grep -Eo -e"[0-9]+" | tr -d "\n"')
export SYS_MEM_TOT_GRAYLOG=$(docker exec -ti ${GRAYLOG_CONTAINER} /bin/bash -c "cat /sys/fs/cgroup/memory/memory.limit_in_bytes" | awk '{$1/=1024000000;printf int($1)}' | tr -d "\n")
export SYS_MEM_TOT_ELASTIC=$(docker exec -ti ${ELASTIC_CONTAINER} /bin/bash -c "cat /sys/fs/cgroup/memory/memory.limit_in_bytes" | awk '{$1/=1024000000;printf int($1)}' | tr -d "\n")
export ES_XMS=$(docker inspect ${ELASTIC_CONTAINER} -f '{{range .Config.Env}}{{println .}}{{end}}' | grep ES_JAVA_OPTS | grep -oP "(?<=Xms)[0-9]+" | tr -d "\n")
export ES_XMX=$(docker inspect ${ELASTIC_CONTAINER} -f '{{range .Config.Env}}{{println .}}{{end}}' | grep ES_JAVA_OPTS | grep -oP "(?<=Xmx)[0-9]+" | tr -d "\n")
export GL_XMS=$(docker inspect ${GRAYLOG_CONTAINER} -f '{{range .Config.Env}}{{println .}}{{end}}' | grep GRAYLOG_SERVER_JAVA_OPTS | grep -oP "(?<=Xms)[0-9]+" | tr -d "\n")
export GL_XMX=$(docker inspect ${GRAYLOG_CONTAINER} -f '{{range .Config.Env}}{{println .}}{{end}}' | grep GRAYLOG_SERVER_JAVA_OPTS | grep -oP "(?<=Xmx)[0-9]+" | tr -d "\n")
export GLJOURNAL_ENABLED=$(docker exec -ti ${GRAYLOG_CONTAINER} /bin/bash -c 'grep /usr/share/graylog/data/config/graylog.conf -e"^message_journal_enabled" | grep -o -i -e"true" -e"false" | grep -Eo -e"\w+" | tr -d "\n"')
export ES_LOGGING=$(docker exec -ti ${ELASTIC_CONTAINER} /bin/bash -c 'grep /usr/share/elasticsearch/config/log4j2.properties -e"rootLogger.level" | grep -Eo -e"=\W?\w+" | grep -c -e"info" | tr -d "\n"')

echo "Results:"

echo GRAYLOG_VERSION $GRAYLOG_VERSION 
echo NCPU $NCPU
echo SYS_MEM_TOT_GRAYLOG $SYS_MEM_TOT_GRAYLOG
echo SYS_MEM_TOT_ELASTIC $SYS_MEM_TOT_ELASTIC
echo ES_XMS $ES_XMS 
echo ES_XMX $ES_XMX
echo GL_XMS $GL_XMS
echo GL_XMX $GL_XMX
echo GLJOURNAL_ENABLED $GLJOURNAL_ENABLED
echo ES_LOGGING $ES_LOGGING

echo "...running assessment script"
echo
echo "#########################"
echo
echo

./"${ASSESMENT_SCRIPT}"
