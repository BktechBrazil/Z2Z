#!/bin/bash
#Script to obtain the size (actual usage) of the environment's mailboxes
#Use to validate the migration process
#Reference: https://wiki.zimbra.com/wiki/Get_all_user%27s_mailbox_size_from_CLI

all_accounts=`zmprov -l gaa`

for account in $all_accounts
    do
      mbox_size=`zmmailbox -z -m $account gms`
      echo "USED ​​space of the account $account = $mbox_size"
done
