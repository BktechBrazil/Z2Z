#!/bin/bash
#Utilitario para adicionr disclaimer para todos os dominios
#A partir da versão 8.5, foi adicionada o recurso de criacao de disclaimer por dominio, nao sendo possivel
#utilizar um disclaimer universal

#Obtem a relacao de todos os dominios para adicionar um disclaimer padrao
	for DOMAIN in $(zmprov gad); do
		echo Adicionando Disclaimers para o dominio: $DOMAIN
		zmprov md $DOMAIN zimbraAmavisDomainDisclaimerText "$(cat /opt/zimbra/postfix/conf/disclaimer.txt)"
		zmprov md $DOMAIN zimbraAmavisDomainDisclaimerHTML "$(cat /opt/zimbra/postfix/conf/disclaimer.html)"
done
