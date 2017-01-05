#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source $CDIR/bash_colors.sh

labelin; echo " Removing lists from INPUT chain (v4)"
iptables -D INPUT -j secthemall-blacklist > /dev/null 2>&1
iptables -D INPUT -j secthemall-whitelist > /dev/null 2>&1

labelin; echo " Removing lists from FORWARD chain (v4)"
iptables -D FORWARD -j secthemall-blacklist > /dev/null 2>&1
iptables -D FORWARD -j secthemall-whitelist > /dev/null 2>&1

labelin; echo " Flushing lists chain (v4)"
iptables -F secthemall-blacklist > /dev/null 2>&1
iptables -F secthemall-whitelist > /dev/null 2>&1

labelin; echo " Removing lists chain (v4)"
iptables -X secthemall-blacklist > /dev/null 2>&1
iptables -X secthemall-whitelist > /dev/null 2>&1

if type "ip6tables" > /dev/null; then
	labelin; echo " Removing lists from INPUT chain (v6)"
	ip6tables -D INPUT -j secthemall-blacklist > /dev/null 2>&1
	ip6tables -D INPUT -j secthemall-whitelist > /dev/null 2>&1

	labelin; echo " Removing lists from FORWARD chain (v6)"
	ip6tables -D FORWARD -j secthemall-blacklist > /dev/null 2>&1
	ip6tables -D FORWARD -j secthemall-whitelist > /dev/null 2>&1

	labelin; echo " Flushing lists chain (v6)"
	ip6tables -F secthemall-blacklist > /dev/null 2>&1
	ip6tables -F secthemall-whitelist > /dev/null 2>&1

	labelin; echo " Removing lists chain (v6)"
	ip6tables -X secthemall-blacklist > /dev/null 2>&1
	ip6tables -X secthemall-whitelist > /dev/null 2>&1
fi

labelok; echo " done."
