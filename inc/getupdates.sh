#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
USERNAME=$(cat ${CDIR}/username)
APIKEY=$(cat ${CDIR}/apikey)
SALIAS=$(cat ${CDIR}/alias)

source $CDIR/functions.sh
source $CDIR/bash_colors.sh

# echo $MYHOSTNAME
# echo $MYIPADDR
# echo "${USERNAME} ${APIKEY} ${SALIAS}"

SYSUPTIME=$(uptime | base64 -w0)
SYSISSUE=$(cat /etc/issue | grep '\w' | base64 -w0)
SYSUNAME=$(uname -a | base64 -w0)

UPDATESOUT=$(curl -s -A "${STAVERSION}" -d "a=updates&tz=${TIMEZONE}&username=${USERNAME}&apikey=${APIKEY}&alias=${SALIAS}&myhostname=${MYHOSTNAME}&myipaddr=${MYIPADDR}&uptime=${SYSUPTIME}&issue=${SYSISSUE}&uname=${SYSUNAME}" 'https://secthemall.com/api/v1/')

UCOUNT=1
for uout in $UPDATESOUT; do
	#echo "--> ${uout}"

	if [ $UCOUNT -eq 1 ]; then
		if [[ "${uout}" == "-begin-" ]]; then
			labelin; echo " apply received updates:"
		else
			labelin; echo " no updates recevied."
			exit 0
		fi
	fi


	# v4
	# ---
	if [[ "${uout:0:8}" == "+blipv4:" ]]; then
		labelin; echo " Add following IPv4 in blacklist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV4=$(echo "${ip}" | egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV4 -ge 1 ]; then
				CHECKIFIPEXISTS=$(iptables -L secthemall-blacklist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -eq 0 ]; then
					iptables -I secthemall-blacklist -s ${ip} -j DROP
				else
					labelwa; echo " IPv4 ${ip} already in blacklist."
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "+wlipv4:" ]]; then
		labelin; echo " Add following IPv4 in whitelist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV4=$(echo "${ip}" | egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV4 -ge 1 ]; then
				CHECKIFIPEXISTS=$(iptables -L secthemall-whitelist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -eq 0 ]; then
					iptables -I secthemall-whitelist -s ${ip} -j ACCEPT
				else
					labelwa; echo " IPv4 ${ip} already in whitelist."
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "-blipv4:" ]]; then
		labelin; echo " Remove following IPv4 from blacklist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV4=$(echo "${ip}" | egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV4 -ge 1 ]; then
				CHECKIFIPEXISTS=$(iptables -L secthemall-blacklist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -ge 1 ]; then
					iptables -D secthemall-blacklist -s ${ip} -j DROP > /dev/null 2>&1
				else
					labelwa; echo " IPv4 ${ip} does not seem to be blacklisted, trying to remove it anyway."
					iptables -D secthemall-blacklist -s ${ip} -j DROP > /dev/null 2>&1
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "-wlipv4:" ]]; then
		labelin; echo " Remove following IPv4 from whitelist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV4=$(echo "${ip}" | egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV4 -ge 1 ]; then
				CHECKIFIPEXISTS=$(iptables -L secthemall-whitelist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -ge 1 ]; then
					iptables -D secthemall-whitelist -s ${ip} -j ACCEPT > /dev/null 2>&1
				else
					labelwa; echo " IPv4 ${ip} not in whitelist."
				fi
			fi
		done
	fi








	# v6
	# ---
	if [[ "${uout:0:8}" == "+blipv6:" ]]; then
		labelin; echo " Add following IPv6 in blacklist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV6=$(echo "${ip}" | egrep "^[a-fA-F0-9]+\:[a-fA-F0-9\:]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV6 -ge 1 ]; then
				CHECKIFIPEXISTS=$(ip6tables -L secthemall-blacklist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -eq 0 ]; then
					ip6tables -I secthemall-blacklist -s ${ip} -j DROP
				else
					labelwa; echo " IPv6 ${ip} already in blacklist."
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "+wlipv6:" ]]; then
		labelin; echo " Add following IPv6 in whitelist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV6=$(echo "${ip}" | egrep "^[a-fA-F0-9]+\:[a-fA-F0-9\:]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV6 -ge 1 ]; then
				CHECKIFIPEXISTS=$(ip6tables -L secthemall-whitelist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -eq 0 ]; then
					ip6tables -I secthemall-whitelist -s ${ip} -j ACCEPT
				else
					labelwa; echo " IPv6 ${ip} already in whitelist."
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "-blipv6:" ]]; then
		labelin; echo " Remove following IPv6 from blacklist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV6=$(echo "${ip}" | egrep "^[a-fA-F0-9]+\:[a-fA-F0-9\:]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV6 -ge 1 ]; then
				CHECKIFIPEXISTS=$(ip6tables -L secthemall-blacklist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -ge 1 ]; then
					ip6tables -D secthemall-blacklist -s ${ip} -j DROP > /dev/null 2>&1
				else
					labelwa; echo " IPv6 ${ip} does not seem to be blacklisted, trying to remove it anyway."
					ip6tables -D secthemall-blacklist -s ${ip} -j DROP > /dev/null 2>&1
				fi
			fi
		done
	fi

	if [[ "${uout:0:8}" == "-wlipv6:" ]]; then
		labelin; echo " Remove following IPv6 from whitelist: ${uout:8}"

		ADDIPLIST=$(echo "${uout:8}" | tr "|" "\n")

		for ip in $ADDIPLIST; do
			ISIPV6=$(echo "${ip}" | egrep "^[a-fA-F0-9]+\:[a-fA-F0-9\:]+(\/[0-9]+|)$" | wc -l)

			if [ $ISIPV6 -ge 1 ]; then
				CHECKIFIPEXISTS=$(ip6tables -L secthemall-whitelist -n | grep "${ip}" | wc -l)
				if [ $CHECKIFIPEXISTS -ge 1 ]; then
					ip6tables -D secthemall-whitelist -s ${ip} -j ACCEPT > /dev/null 2>&1
				else
					labelwa; echo " IPv6 ${ip} not in whitelist."
				fi
			fi
		done
	fi








	((++UCOUNT))
done
