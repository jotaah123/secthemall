#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source $CDIR/functions.sh
source $CDIR/bash_colors.sh

if [ -f ${CDIR}/../stat/s${2//\//_} ]; then
	LINEDIFF=$(${3} | diff ${CDIR}/../stat/s${2//\//_} - | wc -l)

	if [ $LINEDIFF -eq 0 ]; then
		labelok; echo " No changes for ${2}"
	else
		labelin; echo " Stat file ${2} changed, parsing events..."
		parsecmd "ntime" "${1}" "${2}" "${3}"
	fi
else
	labelin; echo " Parsing the stdout of command ${2} for the first time..."
	parsecmd "firstime" "${1}" "${2}" "${3}"
fi
