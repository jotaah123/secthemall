#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source $CDIR/functions.sh
source $CDIR/bash_colors.sh

if [ -f ${CDIR}/../stat/s${4//\//_} ]; then
	LINEDIFF=$(${1:1} | egrep "${2}" | diff ${CDIR}/../stat/s${4//\//_} - | egrep "${2}" | wc -l)

	if [ $LINEDIFF -eq 0 ]; then
		labelok; echo " No changes for ${1:1}"
	else
		labelin; echo " Stat file ${4} changed, parsing events..."
		parsecmd "${1:1}" "${2}" "${3}" "${4}"
	fi
else
	labelin; echo " Parsing the stdout of command ${1:1} for the first time..."
	parsecmd "${1:1}" "${2}" "${3}" "${4}" "firstime"
fi
