#!/bin/bash

CDIR="$( cd "$( dirname "$0" )" && pwd )"
source $CDIR/bash_colors.sh

labelin; echo " Removing lists from INPUT chain"
iptables -D INPUT -j secthemall-blacklist > /dev/null 2>&1
iptables -D INPUT -j secthemall-whitelist > /dev/null 2>&1

labelin; echo " Removing lists from FORWARD chain"
iptables -D FORWARD -j secthemall-blacklist > /dev/null 2>&1
iptables -D FORWARD -j secthemall-whitelist > /dev/null 2>&1

labelin; echo " Flushing lists chain"
iptables -F secthemall-blacklist > /dev/null 2>&1
iptables -F secthemall-whitelist > /dev/null 2>&1

labelin; echo " Removing lists chain"
iptables -X secthemall-blacklist > /dev/null 2>&1
iptables -X secthemall-whitelist > /dev/null 2>&1

labelok; echo " done."
