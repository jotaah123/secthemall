#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source ${CDIR}/inc/bash_colors.sh
STAVERSION="secthemall/1.0.6"

ARGREXHELP=$(echo "$@" | egrep "(\-\-help|\-h)" | wc -l)
if [ $ARGREXHELP -ge 1 ]; then
	echo "+"
	echo "+ (::) SECTHEMALL"
	echo "+"

	labelcmd "--help or -h"; echo "       Show this help"
	labelcmd "--auth"; echo "             Authenticate with your username and pasword"
	labelcmd "--start"; echo "            Run client in foreground"
	labelcmd "--background or -b"; echo " Run client in background"
	labelcmd "--stop"; echo "             Stop client"
	labelcmd "--restart"; echo "          Restart client in background"
	labelcmd "--autoconf"; echo "         Try to suggest a conf/paeser.conf"
	echo "+"
	labelcmd "--gbladd <ip>"; echo "      Add <ip> to Global Blacklist"
	labelcmd "--gbldel <ip>"; echo "      Delete <ip> to Global Blacklist"
	labelcmd "--gblshow"; echo "          Show Global Blacklist (json)"
	labelcmd "--gwladd <ip>"; echo "      Add <ip> to Global Whitelist"
	labelcmd "--gwldel <ip>"; echo "      Delete <ip> to Global Whitelist"
	labelcmd "--gwlshow"; echo "          Show Global Whitelist (json)"
	echo "+"
	labelcmd "--lblshow"; echo "          Show Local Blacklist (iptables)"
	labelcmd "--lwlshow"; echo "          Show Local Whitelist (iptables)"
	echo "+"

	labelcmd "--getlogs [-q ...]"; echo " Get collected logs from all nodes (json)"
	echo "+"
	echo -en "\n\n Example usage:\n"
	echo " ${0} --start -b         # start the client in background"
	echo " ${0} --restart          # restart the client in background"
	echo " ${0} --stop             # stop the client"
	echo " ${0} --gbladd 1.2.3.4   # add 1.2.3.4 to Global Blacklist"
	echo -en "\n\n"
	exit 0
fi

AUTHME=$(echo "$@" | egrep -o "\-\-auth" | wc -l)
if [ $AUTHME -ge 1 ]; then
	${CDIR}/client.sh auth
	exit 0;
fi

if [ ! -f ${CDIR}/inc/username ]; then
	labeler; echo " No username found."
	labelin; echo -n " You can get a free account here: "; clr_blueb "https://secthemall.com/signup/"
	${CDIR}/client.sh auth
	exit 0;
fi

USERNAME=$(cat ${CDIR}/inc/username)
APIKEY=$(cat ${CDIR}/inc/apikey)
SALIAS=$(cat ${CDIR}/inc/alias)
LASTPID=$(cat ${CDIR}/conf/client.pid)
RUNME=0

if [ -f /etc/timezone ]; then
	TIMEZONE=$(cat /etc/timezone)
else
	labeler; echo " No Time Zone found in /etc/timezone."
	echo "+"
	exit 1
fi

AUTOCONF=$(echo "$@" | egrep -o "\-\-autoconf" | wc -l)
if [ $AUTOCONF -ge 1 ]; then
	labelin; echo " Trying to find intresting log files..."
	echo ""
	echo "# copy under this line and paste in conf/secthemall.conf"
	echo "# ------------------------------------------------------"
	${CDIR}/inc/autoconf.sh
	echo "# ------------------------------------------------------"
	echo ""
	exit 0
fi

GETLOG=$(echo "$@" | egrep -o "\-\-getlogs \-q (.+)" | wc -l)
if [ $GETLOG -ge 1 ]; then
	QUERY=$(echo "$@" | egrep -o "(f\[.+)")
	curl -A "${STAVERSION}" -s -d "a=getlogs&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&${QUERY}" "https://secthemall.com/api/v1/"
	echo ""
	exit 0
fi

GBLADD=$(echo "$@" | egrep -o "\-\-gbladd ([0-9\.]+|[0-9a-fA-F]+\:[0-9a-fA-F\:]+)(\/[0-9]+|)" | wc -l)
if [ $GBLADD -ge 1 ]; then
	IP=$(echo "$@" | egrep -o "([0-9\.]+|[0-9a-fA-F]+\:[0-9a-fA-F\:]+)(\/[0-9]+|)")
	labelin; echo -n " Sending "; clr_blueb "${IP}" -n; echo " to Global Blacklist..."
	curl -A "${STAVERSION}" -d "a=gbl&action=add&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&ip=${IP}" "https://secthemall.com/api/v1/"
	exit 0
fi

GBLDEL=$(echo "$@" | egrep -o "\-\-gbldel ([0-9\.]+|[0-9a-fA-F]+\:[0-9a-fA-F\:]+)(\/[0-9]+|)" | wc -l)
if [ $GBLDEL -ge 1 ]; then
	IP=$(echo "$@" | egrep -o "([0-9\.]+|[0-9a-fA-F]+\:[0-9a-fA-F\:]+)(\/[0-9]+|)")
	labelin; echo -n " Removing "; clr_blueb "${IP}" -n; echo " from Global Blacklist..."
	curl -A "${STAVERSION}" -d "a=gbl&action=del&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&ip=${IP}" "https://secthemall.com/api/v1/"
	exit 0
fi

GBLSHOW=$(echo "$@" | egrep -o "\-\-gblshow" | wc -l)
if [ $GBLSHOW -ge 1 ]; then
	curl -s -A "${STAVERSION}" -d "a=gblshow&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}" "https://secthemall.com/api/v1/"
	exit 0
fi

LBLSHOW=$(echo "$@" | egrep -o "\-\-lblshow" | wc -l)
if [ $LBLSHOW -ge 1 ]; then
	iptables -L secthemall-blacklist -n
	exit 0
fi

LWLSHOW=$(echo "$@" | egrep -o "\-\-lwlshow" | wc -l)
if [ $LWLSHOW -ge 1 ]; then
	iptables -L secthemall-whitelist -n
	exit 0
fi

CLIENTISRUNNING=$(ps aux | grep "${LASTPID}" | grep -v grep | wc -l)

if [ -d "/proc/${LASTPID}" ]; then
	labelin; echo " SECTHEMALL client is running with PID ${LASTPID}"
	ARGREXSTOP=$(echo "$@" | egrep "(\-\-stop)" | wc -l)
	if [ $ARGREXSTOP -ge 1 ]; then
		labelin; echo " Kill client PID ${LASTPID}..."
		kill -s 9 ${LASTPID}
		labelok; echo " client stopped."
	fi

	ARGREXRESTART=$(echo "$@" | egrep "(\-\-restart)" | wc -l)
	if [ $ARGREXRESTART -ge 1 ]; then
		${0} --stop
		${0} --start -b
	fi
	exit 0
else
	labelwa; echo " SECTHEMALL client is not running."
	ARGREXSTART=$(echo "$@" | egrep "(\-\-background|\-b|\-\-start)" | wc -l)
	if [ $ARGREXSTART -ge 1 ]; then
		RUNME=1
	else
		labelin; echo -n " Type "; clr_blueb "${0} --h" -n; echo " for help."
		exit;
	fi
fi

if [ $RUNME -eq 1 ]; then
	ARGREXBG=$(echo "$@" | egrep "(\-\-background|\-b)" | wc -l)
	if [ $ARGREXBG -ge 1 ]; then
		labelin; echo " Running client in background..."
		${CDIR}/client.sh > /dev/null 2>&1 &
	else
		${CDIR}/client.sh
	fi
fi
