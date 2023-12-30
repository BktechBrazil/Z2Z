#!/bin/bash
###   Z2Z - Mantido por BKTECH <http://www.bktech.com.br>                         ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>     ###
###   PARA INFORMACOES SOBRE A FERRAMENTA, FAVOR LER OS ARQUIVOS README E INSTALL ###

###   VERSION 1.0.3 - Translated in english

#LOADS FUNCTIONS USED BY THE SCRIPT
. func.sh
 
#START Z2Z TOOL
clear
cat banner.txt
echo ""
#

#CONFIRM THAT IT IS RUNNING WITH ZIMBRA USER
Run_as_Zimbra
separator_char

#CONFIRMS THAT THE USER WANTS TO CONTINUE WITH THE EXECUTION
test_exec
separator_char

#TESTS FOR RUNNING THE UTILITY

#NECESSARY COMMANDS
declare -a COMANDOS=('ldapsearch' 'zmmailbox' 'zmshutil' 'zmprov');

Check_Command
separator_char

#VALIDATES SINGLE SERVER OR SINGLE MAILBOX ENVIRONMENT
Check_Maibox
separator_char

#SETTING ZIMBRA ENVIRONMENT VARIABLES
source ~/bin/zmshutil
zmsetvars


#SETTING SERVER NAME WITH ENVIRONMENT VARIABLE
ZIMBRA_HOSTNAME=$zimbra_server_hostname
#DEFINING USER FOR BIND IN ZIMBRA LDAP WITH ENVIRONMENT VARIABLE
ZIMBRA_BINDDN=$zimbra_ldap_userdn


####DIRECTORIS

DIRETORIO=$WORKDIR
Check_Directory
separator_char
DIRETORIO="`pwd`/skell"
Check_Directory
separator_char
DESTINATION=$WORKDIR
mkdir $WORKDIR/alias #Create temporary directory to export alternative names

#CAN CONTINUE


 #EXPORTING COS
 $NORMAL_TEXT "EXPORTING COS "
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraCOS)" > $DESTINATION/COS.ldif
 $INFO_TEXT "COS SUCCESSFULLY EXPORTED: $DESTINATION/COS.ldif"
 separator_char
 
 #EXPORTING ACCOUNTS - EXCLUDING SERVICES ACCOUNTS ZIMBRA (zimbraIsSystemResource=TRUE)
 $NORMAL_TEXT  "EXPORTING ACCOUNTS"
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL '(&(!(zimbraIsSystemResource=TRUE))(objectClass=zimbraAccount))' > $DESTINATION/ACCOUNTS.ldif
 $INFO_TEXT "ACCOUNTS SUCCESSFULLY EXPORTED: $DESTINATION/ACCOUNTS.ldif"
 separator_char
 
 #EXPORTING ALIAS
 $NORMAL_TEXT  "EXPORTING ALIAS"
 separator_char

 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password  -b '' -LLL '(&(!(uid=root))(!(uid=postmaster))(objectclass=zimbraAlias))' uid | grep ^uid | awk '{print $2}' > $DESTINATION/lista_contas.ldif

 for MAIL in $(cat $DESTINATION/lista_contas.ldif);
 	do 
	      ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(&(uid=$MAIL)(objectclass=zimbraAlias))" > $DESTINATION/alias/$MAIL.ldif
		  	cat $DESTINATION/alias/*.ldif > $DESTINATION/APELIDOS.ldif
			done 

   $INFO_TEXT "ALIAS EXPORTED SUCCESSFULLY: $DESTINATION/APELIDOS.ldif"
   separator_char

#EXPORTING DISTRIBUTION LISTS
   $NORMAL_TEXT  "EXPORTING DISTRIBUTION LISTS"
   separator_char
ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(|(objectclass=zimbraGroup)(objectclass=zimbraDistributionList))" > $DESTINATION/LISTAS.ldif
   $INFO_TEXT "SUCCESSFUL EXPORTED DISTRIBUTION LISTS: $DESTINATION/LISTAS.ldif"
   separator_char

#CLEANS TEMPORARY FILES CREATED ON THE EXPORT DIRECTORY
Clear_Workdir

#COPY IMPORT SCRIPT AND SIMPLE BANNER
cp skell/importar_ldap.sh export/
cp skell/banner_simples.txt export/
chmod +x export/importar_ldap.sh

#INTERACTIVITY: CHANGE SERVER HOSTNAME
Replace_Hostname
separator_char

#INTERACTIVITY: EXPORT (LIST) OF MAILBOXES

export_Mailboxes
separator_char

Export_Dest

#EXPORTING MAILBOXES
execute_Export_Full
separator_char

#EXPORTING TRASH
execute_Export_Trash
separator_char

#EXPORTING SPAM
execute_Export_Junk
separator_char

#END