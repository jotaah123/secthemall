#!/bin/bash

SSHLOGS=$(egrep -sH 'sshd.*password.*' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $SSHLOGS -ge 1 ]; then
	for lfile in `egrep -sH 'sshd.*password.*' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo ${lfile} '"sshd.*password.*"' '"SSH"'
	done
fi

IPTABLESLOGS=$(egrep -sH 'MAC.+SRC.+DST.+PROTO.+DPT' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $IPTABLESLOGS -ge 1 ]; then
	for lfile in `egrep -sH 'MAC.+SRC.+DST.+PROTO.+DPT' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo ${lfile} '"MAC.+SRC.+DST.+PROTO.+DPT"' '"iptables"'
	done
fi

NGINXLOGS1=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /var/log/nginx/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS1 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /var/log/nginx/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"nginx_access"'
	done
fi

NGINXLOGS2=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/openresty/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS2 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/openresty/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"nginx_access"'
	done
fi

NGINXLOGS3=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS3 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"nginx_access"'
	done
fi

NETSTATLOG=$(which netstat | wc -l)
if [ $NETSTATLOG -ge 1 ]; then
	NETSTATPATH=$(which netstat)
	echo cmd '"netstat"' '"netstat_listen"' '"'${NETSTATPATH}' -ltunp"'
fi
