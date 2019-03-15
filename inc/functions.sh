#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

source ${CDIR}/bash_colors.sh

if [ ! -f "${CDIR}/inc/passphrase" ] && [ ! -f "${CDIR}/passphrase" ]; then
	labelwa; echo " Passphrase not found, please visit https://secthemall.com/signup/"
	echo "+"
	exit 1;
fi

PASSPHRASE=$(cat ${CDIR}/passphrase)
MYHOSTNAME=$(hostname | base64 -w0)
MYIPADDR=$(hostname -I | base64 -w0)
STAVERSION="secthemall/1.0.8"

if [ -f /etc/timezone ]; then
	TIMEZONE=$(cat /etc/timezone)
	# labelin; echo " Time Zone set to ${TIMEZONE}"
else
	echo "+"
	labeler; echo " No Time Zone found in /etc/timezone."
	labeler; echo " Please, configure system Time Zone"
	labeler; echo " and sync system date and time."
	echo "+"
	exit 1
fi

if [ "${TIMEZONE}" == "" ]; then
	echo "+"
	labeler; echo " No Time Zone found in /etc/timezone."
	labeler; echo " Please, configure system Time Zone"
	labeler; echo " and sync system date and time."
	echo "+"
	exit 1
fi

function sdash_encrypt {
	cat $1 | openssl enc -e -aes-128-cbc -base64 -md md5 -A -salt -pass pass:$PASSPHRASE
}

function sdash_decrypt {
	echo $1 | openssl enc -d -aes-128-cbc -base64 -md md5 -A -salt -pass pass:$PASSPHRASE
}

function getmd5fn {
	MD5=$(echo -n "$1" | md5sum)
	echo ${MD5:0:32}
}

function getlinenum {
	HMLINES=$(cat "$1" | wc -l)
	echo ${HMLINES}
}

function parselog {
	logfile=$1

	if [ -f ${CDIR}/../stat/s${1//\//_} ]; then
		cat ${1} | egrep "${2}" | diff -n ${CDIR}/../stat/s${1//\//_} - | egrep "${2}" > ${CDIR}/../tmp/t${logfile//\//_}
	else
		cat ${1} | egrep "${2}" > ${CDIR}/../tmp/t${logfile//\//_}
	fi

	cat ${1} | egrep "${2}" > ${CDIR}/../stat/s${logfile//\//_}

	NUMLINETOSEND=$(cat ${CDIR}/../tmp/t${logfile//\//_} | wc -l)

	labelin; echo " Encrypting new logs before send (${NUMLINETOSEND})..."

	encstring=$(sdash_encrypt ${CDIR}/../tmp/t${logfile//\//_})
	echo -en "logs=${encstring}" > ${CDIR}/../tmp/e${logfile//\//_}

	#echo -en "\n\nFILE TO SEND: "; cat ${CDIR}/../tmp/e${logfile//\//_}

	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	if [[ "${4}" == "firstime" ]]; then
		labelin; echo " Skip sendlog for file ${logfile} (only for first time)."
		exit 0
	fi

	curl -s -d "a=writelogs&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&type=${3}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" -d @${CDIR}/../tmp/e${logfile//\//_} "https://wl.secthemall.com/api/v1/"
	labelok; echo -n " Logs sent for file "; clr_blue "${logfile}"
	rm -rf ${CDIR}/../tmp/t${logfile//\//_}
	rm -rf ${CDIR}/../tmp/e${logfile//\//_}
}

function parsecmd {
	#logfile=$4

	logptye="${2}"
	logfile="${3}"
	cmdstring="${4}"

	#echo "`$cmdstring`" | diff ${CDIR}/../stat/s${logfile//\//_} -

	if [ -f ${CDIR}/../stat/s${logfile//\//_} ]; then
		echo "`$cmdstring`" | diff ${CDIR}/../stat/s${logfile//\//_} - > ${CDIR}/../tmp/t${logfile//\//_}
	else
		echo "`$cmdstring`" > ${CDIR}/../tmp/t${logfile//\//_}
	fi

	echo "`$cmdstring`" > ${CDIR}/../stat/s${logfile//\//_}

	encstring=$(sdash_encrypt ${CDIR}/../tmp/t${logfile//\//_})
	echo -en "logs=${encstring}" > ${CDIR}/../tmp/e${logfile//\//_}
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	if [[ "${1}" == "firstime" ]]; then
		labelin; echo " Skip sendlog for command ${logfile} (only for first time)."
		exit 0
	fi

	curl -s -d "a=writelogs&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&type=${logptye}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" -d @${CDIR}/../tmp/e${logfile//\//_} "https://wl.secthemall.com/api/v1/"
	labelok; echo -n " Logs sent for file "; clr_blue "${logfile}"
	rm -rf ${CDIR}/../tmp/t${logfile//\//_}
	rm -rf ${CDIR}/../tmp/e${logfile//\//_}
}

function getblacklist {
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	iptables -F secthemall-blacklist
	GETBLACKLIST4=$(curl -s -d "a=getmyblacklist&ipversion=ipv4&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" "https://secthemall.com/api/v1/")
	for ip in $GETBLACKLIST4; do
		iptables -I secthemall-blacklist -s ${ip} -j secthemall-logdrop
	done;
	labelok; echo " Blacklist v4 synced."

	if type "ip6tables" > /dev/null; then
		ip6tables -F secthemall-blacklist > /dev/null 2>&1
		GETBLACKLIST6=$(curl -s -d "a=getmyblacklist&ipversion=ipv6&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" "https://secthemall.com/api/v1/")
		for ip in $GETBLACKLIST6; do
			ip6tables -I secthemall-blacklist -s ${ip} -j secthemall-logdrop > /dev/null 2>&1
		done;
		labelok; echo " Blacklist v6 synced."
	fi
}

function gettorexitnodes {
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	iptables -F secthemall-tor
	GETBLACKLIST4=$(curl -s -u ${USERNAME}:${APIKEY} "https://secthemall.com/public-list/tor-exit-nodes/iplist?size=3000")
	for ip in $GETBLACKLIST4; do
		iptables -I secthemall-tor -s ${ip} -j secthemall-logdrop
	done;
	labelok; echo " Tor Blacklist synced."
}

function getshodancrawlers {
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	LASTID=$(cat ${CDIR}/../stat/shodan_last_id 2>/dev/null)
	STALASTID=$(curl -s -u ${USERNAME}:${APIKEY} 'https://secthemall.com/public-list/shodan-crawlers/iplist?lastid=true')

	if [[ "${LASTID}" != "${STALASTID}" ]]; then
		iptables -F secthemall-shodan
		GETBLACKLIST4=$(curl -s -u ${USERNAME}:${APIKEY} "https://secthemall.com/public-list/shodan-crawlers/iplist?size=3000" | sort | uniq)

		SHODANSYNC=$(echo $GETBLACKLIST4 | grep "warning" | wc -l)

		if [[ $SHODANSYNC -gt 0 ]]; then
			labelok; echo " Shodan Blacklist sync in progress, try later."
		else
			for ip in $GETBLACKLIST4; do
				iptables -I secthemall-shodan -s ${ip} -j secthemall-logdrop
			done;
			labelok; echo " Shodan Blacklist synced."
			echo -n "${STALASTID}" > ${CDIR}/../stat/shodan_last_id
		fi
	else
		labelok; echo " Shodan Blacklist already up-to-date."
	fi
}

function getwhitelist {
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	iptables -F secthemall-whitelist
	GETBLACKLIST4=$(curl -s -d "a=getmywhitelist&ipversion=ipv4&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" "https://secthemall.com/api/v1/")
	for ip in $GETBLACKLIST4; do
		iptables -I secthemall-whitelist -s ${ip} -j ACCEPT
	done;
	labelok; echo " Whitelist v4 synced."

	if type "ip6tables" > /dev/null; then
		ip6tables -F secthemall-whitelist > /dev/null 2>&1
		GETBLACKLIST6=$(curl -s -d "a=getmywhitelist&ipversion=ipv6&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" "https://secthemall.com/api/v1/")
		for ip in $GETBLACKLIST6; do
			ip6tables -I secthemall-whitelist -s ${ip} -j ACCEPT > /dev/null 2>&1
		done;
		labelok; echo " Whitelist v6 synced."
	fi
}
