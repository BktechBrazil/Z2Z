#!/bin/bash
#Utility to add disclaimer for all domains
#As of version 8.5, the feature of creating a disclaimer per domain was added, which is not possible
#use a universal disclaimer

#Get the list of all domains to add a standard disclaimer
	for DOMAIN in $(zmprov gad); do
		echo Adding Disclaimers to the domain: $DOMAIN
		zmprov md $DOMAIN zimbraAmavisDomainDisclaimerText "$(cat /opt/zimbra/postfix/conf/disclaimer.txt)"
		zmprov md $DOMAIN zimbraAmavisDomainDisclaimerHTML "$(cat /opt/zimbra/postfix/conf/disclaimer.html)"
