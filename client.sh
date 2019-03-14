#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
echo $$ > ${CDIR}/conf/client.pid

source ${CDIR}/inc/bash_colors.sh

echo "+"
echo "+ (::) SECTHEMALL"
echo "+"

labelin; echo -n " Initializing SECTHEMALL client on "; clr_blue ${CDIR}
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

if [[ "${1}" != "auth" ]]; then
	if [ ! -f "${CDIR}/inc/passphrase" ] && [ ! -f "${CDIR}/passphrase" ]; then
		labelwa; echo " Passphrase not found, please visit https://secthemall.com/signup/"
		labelwa; echo -n " If you already have a Username and a Password, run: "; clr_green "${0} auth"
		echo "+"
		exit 1;
	fi
fi

if [[ "${1}" == "auth" ]]; then
	echo -e "\nAuthentication:"
	echo -e "Insert your secthemall.com Username and Password\n"
	echo -en "Username: "
	read USERNAME
	echo -en "Password: "
	read -s PASSWORD
	ENCODEDPASSWD=$(echo ${PASSWORD} | sed -e 's/"/\"/g' |sed -e 's/&/%26/g')
	echo -en "\n\nInsert Server Alias.\nAllowed chars [a-z0-9] and \"-\" (ex: web-server-1)\nAlias: "
	read SERVERALIAS

	ALIASISOK=$(echo "${SERVERALIAS}" | egrep "^[a-z0-9\-]+$" | wc -l)
	if [ $ALIASISOK -lt 1 ]; then
		echo -en "\n\n"
		labelwa; echo " Wrong alias format, please use only the following chars: [a-z0-9\\-]"
		exit 1;
	fi

	USERID=$(curl -s -d "a=auth&username=${USERNAME}&password=${ENCODEDPASSWD}&alias=${SERVERALIAS}" 'https://secthemall.com/auth/')
	if [[ "${USERID:0:2}" == "ok" ]]; then
		echo -n ${USERID:3:64} > ${CDIR}/inc/passphrase
		echo -n ${USERID:74} > ${CDIR}/inc/apikey
		echo -n ${USERNAME} > ${CDIR}/inc/username
		echo -n ${SERVERALIAS} > ${CDIR}/inc/alias
		echo -e "\n\n"

		if [ ! -f ${CDIR}/conf/secthemall.conf ]; then
			labelin; echo " Configuration file not found in ${CDIR}/conf/secthemall.conf"
			labelin; echo " Trying to run autoconf..."
			# ${CDIR}/inc/autoconf.sh > ${CDIR}/conf/secthemall.conf
			${CDIR}/inc/autoconf.sh
			labelin; echo " Autoconf completed. Please edit ${CDIR}/conf/secthemall.conf"
		fi

		labelok; echo " passphrase saved in ${CDIR}/inc/passphrase"
		labelok; echo " Now you can run ./secthemall.sh --start"
		exit 0;
	else
		echo -e "\n"
		labeler; echo " Username or Password wrong. Please check your credentials and try again."
		exit 1;
	fi
fi

if [ ! -f ${CDIR}/inc/timezone ]; then
	selectTimeZone
	if [ -f ${CDIR}/inc/timezone ]; then
		TIMEZONE=$(cat ${CDIR}/inc/timezone)
		labelok; echo -en " Configured TimeZone: "; clr_blueb clr_white " ${TIMEZONE} ";
	else
		labeler; echo " No TimeZone selected."
		exit 1
	fi
else
	TIMEZONE=$(cat ${CDIR}/inc/timezone)
	labelok; echo -en " Configured TimeZone: "; clr_blueb clr_white " ${TIMEZONE} ";
fi

CHECKSECTHEMALLCHAINLOGDROP=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-logdrop' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINLOGDROP}" == "0" ]]; then
	labelwa; echo " secthemall iptables logdrop does not exists, creating it..."
	iptables -N secthemall-logdrop
	iptables -A secthemall-logdrop -j LOG --log-level info --log-prefix "SECTHEMALL logdrop: "
	iptables -A secthemall-logdrop -j DROP
fi

CHECKSECTHEMALLCHAINBL=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINBL}" == "0" ]]; then
	labelwa; echo " secthemall iptables blacklist does not exists, creating it..."
	iptables -N secthemall-blacklist
	iptables -I INPUT -j secthemall-blacklist
	iptables -I FORWARD -j secthemall-blacklist
fi

CHECKSECTHEMALLCHAINBL=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINBL}" == "1" ]]; then
	labelok; echo " iptables chain secthemall-blacklist exists."
else
	labeler; echo " unable to create secthemall-blacklist chain."
	exit 1
fi

CHECKSECTHEMALLCHAINTOR=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-tor' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINTOR}" == "0" ]]; then
	labelwa; echo " secthemall Tor blacklist does not exists, creating it..."
	iptables -N secthemall-tor
	iptables -I INPUT -j secthemall-tor
	iptables -I FORWARD -j secthemall-tor
fi

CHECKSECTHEMALLCHAINTOR=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-tor' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINTOR}" == "1" ]]; then
	labelok; echo " iptables chain secthemall-tor exists."
else
	labeler; echo " unable to create secthemall-tor chain."
	exit 1
fi

CHECKSECTHEMALLCHAINWL=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-whitelist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINWL}" == "0" ]]; then
	labelwa; echo " secthemall iptables whitelist does not exists, creating it..."
	iptables -N secthemall-whitelist
	iptables -I INPUT -j secthemall-whitelist
	iptables -I FORWARD -j secthemall-whitelist
fi

CHECKSECTHEMALLCHAINWL=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-whitelist' | wc -l)
if [[ "${CHECKSECTHEMALLCHAINWL}" == "1" ]]; then
	labelok; echo " iptables chain secthemall-whitelist exists."
else
	labeler; echo " unable to create secthemall-whitelist chain."
	exit 1
fi

if type "ip6tables" > /dev/null; then
	CHECKSECTHEMALLCHAINLOGDROP6=$(ip6tables -L -n | grep -i 'Chain' | grep 'secthemall-logdrop' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINLOGDROP6}" == "0" ]]; then
		labelwa; echo " secthemall ip6tables logdrop does not exists, creating it..."
		ip6tables -N secthemall-logdrop
		ip6tables -A secthemall-logdrop -j LOG --log-level info --log-prefix "SECTHEMALL logdrop: "
		ip6tables -A secthemall-logdrop -j DROP
	fi

	CHECKSECTHEMALLCHAINBL6=$(ip6tables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINBL6}" == "0" ]]; then
		labelwa; echo " secthemall ip6tables blacklist does not exists, creating it..."
		ip6tables -N secthemall-blacklist > /dev/null 2>&1
		ip6tables -I INPUT -j secthemall-blacklist > /dev/null 2>&1
		ip6tables -I FORWARD -j secthemall-blacklist > /dev/null 2>&1
	fi

	CHECKSECTHEMALLCHAINBL6=$(ip6tables -L -n | grep -i 'Chain' | grep 'secthemall-blacklist' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINBL6}" == "1" ]]; then
		labelok; echo " ip6tables chain secthemall-blacklist exists."
	else
		labeler; echo " unable to create secthemall-blacklist chain v6."
		labelwa; echo " secthemall will continue without ip6tables..."
		# exit 1
	fi

	CHECKSECTHEMALLCHAINWL6=$(ip6tables -L -n | grep -i 'Chain' | grep 'secthemall-whitelist' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINWL6}" == "0" ]]; then
		labelwa; echo " secthemall ip6tables whitelist does not exists, creating it..."
		ip6tables -N secthemall-whitelist > /dev/null 2>&1
		ip6tables -I INPUT -j secthemall-whitelist > /dev/null 2>&1
		ip6tables -I FORWARD -j secthemall-whitelist > /dev/null 2>&1
	fi

	CHECKSECTHEMALLCHAINWL6=$(ip6tables -L -n | grep -i 'Chain' | grep 'secthemall-whitelist' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINWL6}" == "1" ]]; then
		labelok; echo " ip6tables chain secthemall-whitelist exists."
	else
		labeler; echo " unable to create secthemall-whitelist chain. v6"
		labelwa; echo " secthemall will continue without ip6tables..."
		#exit 1
	fi
fi


${CDIR}/inc/getblacklist.sh

labelin; echo " checking for firewall rules updates..."
${CDIR}/inc/getupdates.sh
${CDIR}/inc/getcountries.sh
GETUPDATESN=0

TORSN=0
TORSTAT=$(cat ${CDIR}/conf/tor.stat 2>/dev/null)
if [[ "${TORSTAT}" == "1" ]]; then
	${CDIR}/inc/gettorexitnodes.sh
fi

while true; do
	if [ $GETUPDATESN -eq 5 ]; then
		labelin; echo " checking for firewall rules updates..."
		${CDIR}/inc/getupdates.sh
		${CDIR}/inc/getcountries.sh
		GETUPDATESN=0
	fi

	if [ $TORSN -eq 1440 ]; then
		labelin; echo " get Tor exit nodes list..."
		${CDIR}/inc/gettorexitnodes.sh
		TORSN=0
	fi

	while read line; do
		REGEXPFILE='^(/[^[:space:]]+) \"(.+)\" (.+)'
		if [[ ${line} =~ $REGEXPFILE ]]; then
			${CDIR}/inc/parser.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
		fi

		#REGEXPCMD='^(\*[^[:space:]]+.*) \"(.+)\" \"(.+)\" \"(.+)\"$'
		#if [[ ${line} =~ $REGEXPCMD ]]; then
			# ${CDIR}/inc/cmdout.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
		#fi

		REGEXPCMD='^cmd \"(.+)\" \"(.+)\" \"(.+)\"$'
		if [[ ${line} =~ $REGEXPCMD ]]; then
			# ${CDIR}/inc/cmdout.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
			#echo "--> Execute cmd with type ${BASH_REMATCH[1]}"
			#echo "--> with stat ${BASH_REMATCH[2]}"
			#echo "--> exec: ${BASH_REMATCH[3]}"
			${CDIR}/inc/cmdout.sh "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
		fi
	done <${CDIR}/conf/secthemall.conf

	((++GETUPDATESN))

	if [[ "${TORSTAT}" == "1" ]]; then
		((++TORSN))
	fi


	sleep 5
done
