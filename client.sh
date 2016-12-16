#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
echo $$ > ${CDIR}/conf/client.pid

source ${CDIR}/inc/bash_colors.sh

echo "+"
echo "+ (::) SECTHEMALL"
echo "+"

labelin; echo -n " Initializing Security Dashboard client on "; clr_blue ${CDIR}
labelin; echo -n " With PID "; clr_green "$$ " -n; echo -n "saved in "; clr_blue "${CDIR}/conf/client.pid"
echo "+"

if ! type "openssl" > /dev/null; then
	labeler; echo " OpenSSL not found."
	echo "+"
	exit 1;
fi

if ! type "iptables" > /dev/null; then
	labeler; echo " iptables not found."
	echo "+"
	exit 1;
fi

if ! type "curl" > /dev/null; then
	labeler; echo " cURL not found."
	echo "+"
	exit 1;
fi

if ! type "base64" > /dev/null; then
	labeler; echo " base64 not found."
	echo "+"
	exit 1;
fi

if ! type "egrep" > /dev/null; then
	labeler; echo " egrep not found."
	echo "+"
	exit 1;
fi

if [ ! -d "${CDIR}/tmp" ]; then
	mkdir ${CDIR}/tmp
fi

if [ ! -d "${CDIR}/stat" ]; then
	mkdir ${CDIR}/stat
fi

rm -rf ${CDIR}/tmp/*

CHECKSECTHEMALLCHAIN=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAIN}" == "0" ]]; then
	labelwa; echo " secthemall iptables chain does not exists, creating it..."
	iptables -N secthemall-blacklist
	iptables -I INPUT -j secthemall-blacklist
fi

CHECKSECTHEMALLCHAIN=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAIN}" == "1" ]]; then
	labelok; echo " iptables chain secthemall-blacklist exists."
else
	labeler; echo " unable to create secthemall-blacklist chain."
	exit 1
fi

if [[ "${1}" == "auth" ]]; then
	echo -e "\nAuthentication:"
	echo -e "Insert your secthemall.com Username and Password\n"
	echo -en "Username: "
	read USERNAME
	echo -en "Password: "
	read -s PASSWORD
	echo -en "\n\nServer alias (example: webserver1): "
	read SERVERALIAS

	USERID=$(curl -s -d "a=auth&username=${USERNAME}&password=${PASSWORD}&alias=${SERVERALIAS}" 'http://secthemall.com/auth.php')
	if [[ "${USERID:0:2}" == "ok" ]]; then
		echo -n ${USERID:3:64} > ${CDIR}/inc/passphrase
		echo -n ${USERID:74} > ${CDIR}/inc/apikey
		echo -n ${USERNAME} > ${CDIR}/inc/username
		echo -n ${SERVERALIAS} > ${CDIR}/inc/alias
		echo -e "\n\n"
		labelok; echo " passphrase saved in ${CDIR}/inc/passphrase"
		labelok; echo " You can change the server alias by editing ${CDIR}/inc/alias"
		labelok; echo " Now you can run ./client.sh"
		exit 0;
	else
		echo -e "\n"
		labeler; echo " Username or Password wrong. Please check your credentials and try again."
		exit 1;
	fi
fi

${CDIR}/inc/getblacklist.sh

GETUPDATESN=0
while true; do
	if [ $GETUPDATESN -eq 5 ]; then
		labelin; echo " checking for firewall rules updates..."
		${CDIR}/inc/getupdates.sh
		GETUPDATESN=0
	fi

	while read line; do
		REGEXPFILE='^(/[^[:space:]]+) \"(.+)\" (.+)'
		if [[ ${line} =~ $REGEXPFILE ]]; then
			${CDIR}/inc/parser.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
		fi

		REGEXPCMD='^(\*[^[:space:]]+.*) \"(.+)\" \"(.+)\" \"(.+)\"$'
		if [[ ${line} =~ $REGEXPCMD ]]; then
			${CDIR}/inc/cmdout.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
		fi
	done <${CDIR}/conf/parser.conf

	((++GETUPDATESN))

	sleep 5
done
