#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"

SSHLOGS=$(egrep -sH 'sshd.*password.*' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $SSHLOGS -ge 1 ]; then
	for lfile in `egrep -sH 'sshd.*password.*' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found SSH logs in ${lfile}"
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[1]=$(echo ${lfile} '"sshd.*password.*"' '"SSH"')
		fi
	done
fi

IPTABLESLOGS=$(egrep -sH 'MAC.+SRC.+DST.+PROTO.+DPT' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $IPTABLESLOGS -ge 1 ]; then
	for lfile in `egrep -sH 'MAC.+SRC.+DST.+PROTO.+DPT' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found iptables logs in ${lfile}"
		echo "+ WARNING: This could generate a lot of logs."
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[2]=$(echo ${lfile} '"MAC.+SRC.+DST.+PROTO.+DPT"' '"iptables"')
		fi
	done
fi

NGINXLOGS1=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /var/log/nginx/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS1 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /var/log/nginx/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found HTTP logs in ${lfile}"
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[3]=$(echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"')
		fi
		#echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"'
	done
fi

NGINXLOGS2=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/openresty/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS2 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/openresty/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found HTTP logs in ${lfile}"
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[4]=$(echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"')
		fi
		#echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"'
	done
fi

NGINXLOGS3=$(egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $NGINXLOGS3 -ge 1 ]; then
	for lfile in `egrep -sH '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-fA-F0-9]+\:[a-fA-F0-9\:]+).*HTTP\/[0-9\.]+. (2|3|4|5)[0-9]{2,2} ' /usr/local/nginx/logs/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found HTTP logs in ${lfile}"
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[5]=$(echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"')
		fi
		#echo ${lfile} '"HTTP\/[0-9\.]+. (4|5)[0-9]{2,2} "' '"HTTP"'
	done
fi

NETSTATLOG=$(which netstat | wc -l)
if [ $NETSTATLOG -ge 1 ]; then
	NETSTATPATH=$(which netstat)
	echo -e "\n+ Found netstat command in ${NETSTATPATH}"
	echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
	read LOGRES
	LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
	if [ $LOGRESOUT -ge 1 ]; then
		CONFOUT[6]=$(echo cmd '"netstat"' '"netstat_listen"' '"'${NETSTATPATH}' -ltunp"')
	fi

	#echo cmd '"netstat"' '"netstat_listen"' '"'${NETSTATPATH}' -ltunp"'
fi

FAIL2BANLOGS=$(egrep -isH '.*fail2ban\..*\:' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq | wc -l)
if [ $FAIL2BANLOGS -ge 1 ]; then
	for lfile in `egrep -isH '.*fail2ban\..*\:' /var/log/*.log | awk 'BEGIN{FS=":"}{print $1}' | sort | uniq`; do
		echo -e "\n+ Found Fail2ban logs in ${lfile}"
		echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
		read LOGRES
		LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
		if [ $LOGRESOUT -ge 1 ]; then
			CONFOUT[7]=$(echo ${lfile} '".*fail2ban.*Ban.*"' '"fail2ban"')
		fi
	done
fi

echo -e "\n+ SECTHEMALL can logs dropped connections from blacklisted IPs"
echo -e "+ by reading iptables logs stored in /var/log/"
echo -n "+ Do you want to add it on secthemall.conf? [Y/n] "
read LOGRES
LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
if [ $LOGRESOUT -ge 1 ]; then
	CONFOUT[8]=$(echo cmd '"logdrop"' '"secthemall_logdrop"' '"egrep -s SECTHEMALL.logdrop /var/log/*"')
fi



if [ ${#CONFOUT[*]} -ge 1 ]; then
	echo -en "\n+ I'm going to write ${#CONFOUT[*]} line(s) on secthemall.conf file. Do you want to continue? [Y/n] "
	read LOGRES
	LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
	if [ $LOGRESOUT -ge 1 ]; then
		echo -en "" > ${CDIR}/../conf/secthemall.conf
		for i in "${CONFOUT[@]}"; do
			echo ${i} >> ${CDIR}/../conf/secthemall.conf
		done
	fi
	echo -en "\n"
else
	echo -e "\n+ No log sources found. Sorry, you will need to configure it manually."
fi

echo -e "+ SECTHEMALL can help you on blocking Tor exit nodes IP addresses"
echo -e "+ More info at: https://secthemall.com/reputation-api/tor"
echo -n "+ Do you want to block Tor traffic? [Y/n] "
read LOGRES
LOGRESOUT=$(echo "${LOGRES}" | egrep -i "^(y|yes|)$" | wc -l);
if [ $LOGRESOUT -ge 1 ]; then
	echo -en 1 > ${CDIR}/../conf/tor.stat
fi

