#/bin/bash
### Z2Z -Maintained by BKTECH <http://www.bktech.com.br> ###
### Copyright (C) 2016 Fabio Soares Schmidt <fabio@respirandolinux.com.br> ###
### FOR INFORMATION ABOUT THE TOOL, PLEASE READ THE README AND INSTALL FILES ###

#DEFINING ZIMBRA ENVIRONMENTAL VARIABLES
source ~/bin/zmshutil
zmsetvars

#FUNCTIONS AND VARIABLES FOR THE UTILITY
NORMAL_TEXT="printf \e[1;34m%-6s\e[m\n" #Blue
ERROR_TEXT="printf \e[1;31m%s\e[0m\n" #Red
INFO_TEXT="printf \e[1;33m%s\e[0m\n" #Yellow
CHOICE_TEXT="printf \e[1;32m%s\e[0m\n" #Green
NO_COLOUR="printf \e[0m" #White
DEFAULTCOS_DN="cn=default,cn=cos,cn=zimbra"
DEFAULTEXTERNALCOS_DN="cn=defaultExternal,cn=cos,cn=zimbra"
SERVER_HOSTNAME=$zimbra_server_hostname
SESSION=`date +"%d_%b_%Y-%H-%M"`
SESSION_LOG="registro-$SESSION.log"


#CONFIRM IF IT IS RUN WITH USER ZIMBRA
if [ "$(whoami)" != "zimbra" ]; then
    $ERROR_TEXT "This command must be run as Zimbra."
    exit 1
fi

#FILES REQUIRED FOR EXECUTION
declare -a IMPORT_FILES=('ACCOUNTS.ldif' 'COS.ldif');

for i in "${IMPORT_FILES[@]}"
    do
    if [ -r $i ]
      then
	  $INFO_TEXT "OK: File $i found"
	  else
      $ERROR_TEXT  "ERROR: File $i not found or without read permission."
      exit 1
fi
done

#GETTING HOSTNAME IN ENTRIES TO CONFIRM IF IT MATCHES THE SERVER'S HOSTNAME
LDIF_HOSTNAME=`grep zimbraMailHost ACCOUNTS.ldif | uniq | awk '{print $2}'`
if [ "$SERVER_HOSTNAME" != "$LDIF_HOSTNAME" ]; then
	   $ERROR_TEXT "ERROR: The server hostname does not match the hostname of the import files"
	   $INFO_TEXT "Server hostname: $SERVER_HOSTNAME"
	   $INFO_TEXT "Hostname in the files for import: $LDIF_HOSTNAME"
	   exit 1
fi

#COMMANDS REQUIRED FOR EXECUTION
declare -a COMANDOS=('ldapsearch' 'zmhostname' 'zmshutil' 'zmmailbox');

for i in "${COMANDOS[@]}"
    do
	type $i >/dev/null 2>/dev/null
if [ $? != 0 ]; then
	  $ERROR_TEXT "ERROR: The command $i was not found, aborting execution."
	  exit 1
fi
done

#
clear
cat banner_simples.txt #Display Banner

#STARTING IMPORT ROUTINES
echo ""
echo ""
$INFO_TEXT "This version DOES NOT create or import domains, only continue if you have already created the environment domains"
$INFO_TEXT "Import started at: $SESSION" &> $SESSION_LOG
$NORMAL_TEXT "Session registration: $SESSION_LOG"
ZIMBRAADMIN_DN=`ldapsearch -x -H ldap://$SERVER_LDAP_HOSTNAME -D $zimbra_ldap_userdn -w $zimbra_ldap_password -b '' -LLL uid=admin dn | awk '{print $2}'` &>> $SESSION_LOG #GET ADMIN DN

#INTERACTIVITY: execution of the import
test_exec()
{
read -p "Do you want to start importing COS, ACCOUNTS, ALIAS AND DISTRIBUTION LIST (yes/no)?" choice
    case "$choice" in
     y|Y|yes|s|S|sim ) $NORMAL_TEXT "Starting Z2Z";;
     n|N|no|nao ) exit 0;;
	 * ) test_exec ;;
     esac
}

test_exec #executa a funcao test_exec


#INTERACTIVITY: importing the admin user
test_importadmin()
{
echo ""
read -p "Do you want to import the ADMIN user (yes/no)?" choice
    case "$choice" in
	  y|Y|yes|s|S|sim ) 
	               $NORMAL_TEXT "Removing ADMIN: $ZIMBRAADMIN_DN" 
				   ldapdelete -r -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $ZIMBRAADMIN_DN &>> $SESSION_LOG
				   ;;
	  n|N|no|nao ) $CHOICE_TEXT "The admin user will not be imported. Use the NEW installation password";;
	  * ) test_importadmin ;;
esac
}

test_importadmin #executes the test_importadmin function

#BEGINS IMPORTATION OF SERVICE CLASSES, ACCOUNTS, ALTERNATIVE NAMES AND DISTRIBUTION LISTS
## REMOVE ZIMBRA'S DEFAULT COS: DEFAULT AND ZIMBRADEFAULT
$INFO_TEXT "Removing default service classes: Default e DefaultExternal"
ldapdelete -r -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTCOS_DN &>> $SESSION_LOG
ldapdelete -r -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTEXTERNALCOS_DN &>> $SESSION_LOG

## IMPORT OF COS, ACCOUNTS, ALIAS AND DISTRIBUTION LISTS

$INFO_TEXT "Importing COS"
ldapadd -c -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f COS.ldif &>> $SESSION_LOG
$INFO_TEXT "Importing accounts"
ldapadd -c -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f ACCOUNTS.ldif &>> $SESSION_LOG
$INFO_TEXT "importing alias"
ldapadd -c -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f ALIAS.ldif &>> $SESSION_LOG
$INFO_TEXT "import distribution lists"
ldapadd -c -x -H ldap://$SERVER_HOSTNAME -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f LISTAS.ldif &>> $SESSION_LOG

#
