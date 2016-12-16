#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source $CDIR/functions.sh
source $CDIR/bash_colors.sh

if [ -f ${1} ]; then
	if [ -f ${CDIR}/../stat/s${1//\//_} ]; then
		LINEDIFF=$(cat ${1} | egrep "${2}" | diff -n ${CDIR}/../stat/s${1//\//_} - | egrep "${2}" | wc -l)

		if [ $LINEDIFF -eq 0 ]; then
			labelok; echo " No changes for ${1}"
		else
			labelin; echo -n " Log"; clr_blue " ${1} " -n; echo "changed, parsing events..."
			parselog "${1}" "${2}" "${3}"
		fi
	else
		labelin; echo " Parsing file ${1} for the first time..."
		parselog "${1}" "${2}" "${3}" "firstime"
	fi
fi
