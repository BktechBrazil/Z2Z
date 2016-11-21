#!/bin/bash
#Script para obter o tamanho (utilizacao real) das caixas postais do ambiente
#Util para validar o processo de migracao
#Referencia: https://wiki.zimbra.com/wiki/Get_all_user%27s_mailbox_size_from_CLI

all_accounts=`zmprov -l gaa`

for account in $all_accounts
    do
      mbox_size=`zmmailbox -z -m $account gms`
      echo "Espaco UTILIZADO da conta $account = $mbox_size"
done
