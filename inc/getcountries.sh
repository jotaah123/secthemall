#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
USERNAME=$(cat ${CDIR}/username)
APIKEY=$(cat ${CDIR}/apikey)
SALIAS=$(cat ${CDIR}/alias)

source $CDIR/functions.sh
source $CDIR/bash_colors.sh

# inc/countrylu

function get_countries_blocks {
	CHECKSECTHEMALLCHAINBL=$(iptables -L -n | grep -i 'Chain' | grep 'secthemall-countries' | wc -l)
	if [[ "${CHECKSECTHEMALLCHAINBL}" == "0" ]]; then
		labelwa; echo " secthemall iptables country blacklist does not exists, creating it..."
		iptables -N secthemall-countries
		iptables -I INPUT -j secthemall-countries
		iptables -I FORWARD -j secthemall-countries
	fi

	iptables -F secthemall-countries
	UPDATESOUT=$(curl -s -A "${STAVERSION}" -d "a=getcountries&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}" 'https://secthemall.com/api/v1/')
	for ip in $UPDATESOUT; do
		iptables -I secthemall-countries -s ${ip} -j DROP
	done;
	labelok; echo " Countries Blacklist v4 synced."
}

COUNTRYLASTUPDATE=$(curl -s -A "${STAVERSION}" -d "a=getcountries_lastupdate&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}" 'https://secthemall.com/api/v1/')
if [ ! -f ${CDIR}/countrylu ]; then
	echo -en "${COUNTRYLASTUPDATE}" > ${CDIR}/countrylu
	get_countries_blocks
else
	CLASTUPDATEMS=$(cat ${CDIR}/countrylu)
	if [ $COUNTRYLASTUPDATE -ne $CLASTUPDATEMS ]; then
		echo -en "${COUNTRYLASTUPDATE}" > ${CDIR}/countrylu
		get_countries_blocks
	fi
fi
