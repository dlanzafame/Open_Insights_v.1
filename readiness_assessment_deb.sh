#!/bin/bash

apt-get install sysstat


PASS="0"
WARN="0"
FAIL="0"

# Test if Graylog is Version 4
GRAYLOG_VERSION=$(apt list --installed 2>/dev/null | grep "^graylog-[1-9]\." | grep -c -E -o -e"graylog-[4]")
if [ "$GRAYLOG_VERSION" -eq "1" ]; then
        echo "Pass: Graylog is version 4"
        let "PASS++"
else
        echo "Fail: Graylog is not installed or is an old version"
        let "FAIL++"
fi

# Test if this system is running on the dmeo OVA instance
if test -f "/etc/rc.local"; then
        Is_ova=$(grep -r /etc/rc.local -e"http\:\/\/docs.graylog" -c)
else
        Is_ova=0
fi
if [ "$Is_ova" -eq "0" ]; then
        echo "Pass: Machine is not demo OVA"
        let "PASS++"
else
        echo "Fail: This system is a provided OVA instance and is intended only for use in evaluation and testing purposes"
        let "FAIL++"
fi

# Check the number of CPU cores
NCPU=$(lscpu | grep -e"^CPU(s)" | grep -Eo -e"[0-9]+")
if [ "$NCPU" -lt "4" ]; then
        echo "Fail: CPU Count is too low, 4 or more cores are recommended for Enterprise Systems"
        let "FAIL++"
else
        echo "Pass: CPU count is greater than 4"
        let "PASS++"
fi

SYS_MEM_TOT=$(free --gibi | grep -e"^Mem:" | cut -c 18-19)
SYS_MEM_HALF=$(awk 'BEGIN{print '"$SYS_MEM_TOT"'/2}' | grep -Eo -e"[0-9]+\." | grep -Eo -e"[0-9]+")
SYS_MEM_QUAR=$(awk 'BEGIN{print '"$SYS_MEM_TOT"'/4}' | grep -Eo -e"[0-9]+\." | grep -Eo -e"[0-9]+")
ES_XMS=$(grep /etc/elasticsearch/jvm.options -e"^-Xms" | grep -Eo -e"[0-9]+")
ES_XMX=$(grep /etc/elasticsearch/jvm.options -e"^-Xmx" | grep -Eo -e"[0-9]+")
if [ "$ES_XMS" -eq "$ES_XMX" ]; then
        if [ "$ES_XMS" -gt "$SYS_MEM_QUAR" ]; then
                echo "Pass: Elasticseach's minimum and maximum values are equal and greater than the recommended minimum"
                let "PASS++"
        else
                echo "Warn: Elasticseach's minimum and maximum values are equal, but not greater than the recommended minimum"
                let "PASS++"
                let "WARN++"
        fi
else
        if [ "$ES_XMX" -gt "$SYS_MEM_QUAR" ]; then
                echo "Fail: Elasticsearch's max and minimum heap sizes are not equal, performance issues may result, but the maximum is greater than the recommended minimum"
                let "WARN++"
        else
                echo "Fail: Elasticsearch's max and minimum heap sizes are not equal, performance issues may result, and the maximum is below the recommended minimum"
                let "FAIL++"
                let "WARN++"
        fi
fi
if [ "$ES_XMS" -eq "$SYS_MEM_HALF" ]; then
	echo "Elasticsearch's heap size is alrger than half the System's total RAM, this can result in degraded performance"
	let "WARN++"
fi


GL_XMS=$(grep /etc/default/graylog-server -e"^-Xms" | grep -Eo -e"[0-9]+")
GL_XMX=$(grep /etc/default/graylog-server -e"^-Xmx" | grep -Eo -e"[0-9]+")
if [ "$GL_XMS" -eq "$GL_XMX" ]; then
        if [ "$GL_XMS" -gt "$SYS_MEM_QUAR" ]; then
                echo "Pass: Graylog's minimum and maximum values are equal and greater than the recommended minimum"
                let "PASS++"
        else
                echo "Warn: Graylog's minimum and maximum values are equal, but not greater than the recommended minimum"
                let "PASS++"
                let "WARN++"
        fi
else
        if [ "$GL_XMX" -gt "$SYS_MEM_QUAR" ]; then
                echo "Fail: Graylog's max and minimum heap sizes are not equal, performance issues may result, but the maximum is greater than the recommended minimum"
                let "WARN++"
        else
                echo "Fail: Graylog's max and minimum heap sizes are not equal, performance issues may result, and the maximum is below the recommended minimum"
                let "FAIL++"
                let "WARN++"
        fi
fi

DISK_WAIT=$(iostat | grep -E -e"^avg-cpu" -A1 | grep -E -e"^\W+" | cut -c 34-39 | grep -Eo -e"[0-9.]+" | grep -Eo -e"[0-9]+" | head -1)
if [ "$DISK_WAIT" -lt "10" ]; then
        echo "Pass: Less than 10% of disk operations are in a waiting state, disk bandwidth is acceptable"
        let "PASS++"
else
        echo "Fail: More than 10% of disk operation are in a waiting state, disk bandwidth is too low"
        let "FAILL++"
fi

SELINUX_STATE=$(sestatus | grep -o -e"enabled" -e"disabled")
if [ "$SELINUX_STATE" == "enabled" ]; then
        echo "Warn: SELinux is currently turned on, please check SELinux policy"
        let "WARN++"
else
        echo "Pass: SELinux is turned off"
        let "PASS++"
fi


IPTABLES_RULES=$(iptables -S | grep -c -o -v -e"^-P")
if [ "$IPTABLES_RULES" -eq "0" ]; then
        echo "Warn: iptables has no rules, it is recommended to run with a firewall enabled"
        let "WARN++"
else
        echo "Pass: iptables is configured with rules"
        let "PASS++"
fi

GLJOURNAL_ENABLED=$(grep /etc/graylog/server/server.conf -e"^message_journal_enabled" | grep -o -i -e"true" -e"false" | grep -Eo -e"\w+")
if [ "$GLJOURNAL_ENABLED" == "true" ]; then
        echo "Pass: Graylog's Journal is enabled"
        let "PASS++"
else
        echo "Fail: Graylog's Journal is disabled"
        let "FAIL++"
fi

echo "------------------------"
echo "Test Results:"
echo "------------------------"
echo " Tests Passed:        $PASS"
echo " Tests with Warnings: $WARN"
echo " Tests with Failures: $FAIL"



grep /etc/elasticsearch/log4j2.properties -e"rootLogger.level" | grep -Eo -e"=\W?\w+" | grep -c -e"info"

