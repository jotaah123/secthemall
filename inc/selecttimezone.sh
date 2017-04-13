#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

function selectTimeZone {
	echo -en "\n+ Please, select one of the following continents:\n"
	TZLIST=$(cat ${CDIR}/inc/tzlist.txt | awk 'BEGIN{FS="/"}{print $1}' | sort | uniq)
	PS3="Continent (insert the number of your continent): "
	select term in ${TZLIST}; do
		if [ "${term}" != "UTC" ]; then
			TZCONTINENT=${term}
			break
		else
			TZUTC=${term}
			break
		fi
	done

	if [ ! -z $TZCONTINENT ]; then
		if [ -z $TZUTC ]; then
			echo -en "\n+ Please, select one of the following cities:\n"
			TZCITYLIST=$(cat ${CDIR}/inc/tzlist.txt | grep ${TZCONTINENT} | awk 'BEGIN{FS="/"}{print $2}')
			PS3='City (insert the number of your city): '
			select city in ${TZCITYLIST}; do
				TZCITY=${city}
				break
			done
		fi
	fi

	if [ ! -z $TZCITY ]; then
		echo -en "${TZCONTINENT}/${TZCITY}" > ${CDIR}/inc/timezone
	fi

	if [ ! -z $TZUTC ]; then
		echo -en "UTC" > ${CDIR}/inc/timezone
	fi
}
