#!/bin/sh
#Script para auditoria de todos os encaminhamentos configurados nas contas do Zimbra
#Referencia: https://wiki.zimbra.com/wiki/Obtain_all_the_forwards_per_each_account

for account in `zmprov -l gaa`; do
	forwardingaddress=`zmprov ga $account |grep 'zimbraPrefMailForwardingAddress' |sed 's/zimbraPrefMailForwardingAddress: //'`
	if [ "$forwardingaddress" != "" ]; then
		echo "$account esta com encaminhamento para $forwardingaddress"
	else
		forwardingaddress=""
fi
done
