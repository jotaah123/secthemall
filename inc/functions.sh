#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

source ${CDIR}/bash_colors.sh

if [ ! -f "${CDIR}/inc/passphrase" ] && [ ! -f "${CDIR}/passphrase" ]; then
	labelwa; echo " Passphrase not found, please visit https://secthemall.com/user"
	echo "+"
	exit 1;
fi

PASSPHRASE=$(cat ${CDIR}/passphrase)
MYHOSTNAME=$(hostname | base64 -w0)
MYIPADDR=$(hostname -I | base64 -w0)
STAVERSION="secthemall/1.0.6"

if [ -f /etc/timezone ]; then
	TIMEZONE=$(cat /etc/timezone)
else
	labeler; echo " No Time Zone found in /etc/timezone."
	echo "+"
	exit 1
fi

function sdash_encrypt {
	cat $1 | openssl enc -aes-128-cbc -base64 -A -salt -pass pass:$PASSPHRASE
}

function sdash_decrypt {
	echo $1 | openssl enc -d -aes-128-cbc -base64 -A -salt -pass pass:$PASSPHRASE
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

	curl -s -d "a=writelogs&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&type=${3}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" -d @${CDIR}/../tmp/e${logfile//\//_} "http://secthemall.com/api/v1/"
	labelok; echo -n " Logs sent for file "; clr_blue "${logfile}"
	rm -rf ${CDIR}/../tmp/t${logfile//\//_}
	rm -rf ${CDIR}/../tmp/e${logfile//\//_}
}

function parsecmd {
	logfile=$4

	echo "`$1`" | egrep "${2}" | diff ${CDIR}/../stat/s${logfile//\//_} - | egrep "${2}"

	if [ -f ${CDIR}/../stat/s${logfile//\//_} ]; then
		echo "`$1`" | egrep "${2}" | diff ${CDIR}/../stat/s${logfile//\//_} - | egrep "${2}" > ${CDIR}/../tmp/t${logfile//\//_}
	else
		echo "`$1`" | egrep "${2}" > ${CDIR}/../tmp/t${logfile//\//_}
	fi

	echo "`$1`" | egrep "${2}" > ${CDIR}/../stat/s${logfile//\//_}

	encstring=$(sdash_encrypt ${CDIR}/../tmp/t${logfile//\//_})
	echo -en "logs=${encstring}" > ${CDIR}/../tmp/e${logfile//\//_}
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	if [[ "${5}" == "firstime" ]]; then
		labelin; echo " Skip sendlog for command ${logfile} (only for first time)."
		exit 0
	fi

	curl -d "a=writelogs&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&type=${3}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" -d @${CDIR}/../tmp/e${logfile//\//_} "http://localhost/api/v1/"
	labelok; echo -n " Logs sent for file "; clr_blue "${logfile}"
	rm -rf ${CDIR}/../tmp/t${logfile//\//_}
	rm -rf ${CDIR}/../tmp/e${logfile//\//_}
}

function getblacklist {
	USERNAME=$(cat ${CDIR}/username)
	APIKEY=$(cat ${CDIR}/apikey)
	SALIAS=$(cat ${CDIR}/alias)

	iptables -F secthemall-blacklist

	GETBLACKLIST=$(curl -s -d "a=getmyblacklist&ipversion=ipv4&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&hostname=${MYHOSTNAME}&ipaddr=${MYIPADDR}" "http://secthemall.com/api/v1/")

	for ip in $GETBLACKLIST; do
		iptables -I secthemall-blacklist -s ${ip} -j DROP
	done;

	labelok; echo " Blacklist synced."
}
