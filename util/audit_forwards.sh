#!/bin/sh
#Script to audit all forwarding configured in Zimbra accounts
#Reference: https://wiki.zimbra.com/wiki/Obtain_all_the_forwards_per_each_account

for account in `zmprov -l gaa`; do
	forwardingaddress=`zmprov ga $account |grep 'zimbraPrefMailForwardingAddress' |sed 's/zimbraPrefMailForwardingAddress: //'`
	if [ "$forwardingaddress" != "" ]; then
		echo "$account esta com encaminhamento para $forwardingaddress"
	else
		forwardingaddress=""
fi
done
