#!/bin/bash
#Changelog: 
# 15/Nov/2016: Creating the func.sh file (Fabio Soares Schmidt)

#FUNCTIONS AND VARIABLES FOR THE UTILITY
NORMAL_TEXT="printf '\e[1;34m%-6s\e[m\n'" #Blue
ERROR_TEXT="printf '\e[1;31m%s\e[0m\n'" #Red
INFO_TEXT="printf '\e[1;33m%s\e[0m\n'" #Yellow
CHOICE_TEXT="printf '\e[1;32m%s\e[0m\n'" #Green
NO_COLOUR="'\e[0m'" #White
MAILBOX_LIST=`zmprov -l gaa | grep -v -E "admin|virus-|ham.|spam.|galsync"` #ALL ZIMBRA ACCOUNTS EXCEPT SYSTEM ACCOUNTS
WORKDIR=`pwd`"/export"
SINGLE_MAILBOX=1
MAILBOX_SERVERS="`zmprov gas mailbox | wc -l`"

##

separator_char()
{
echo ++++++++++++++++++++++++++++++++++++++++
}
##

test_exec()
{
read -p "Continue (Yes/No)?" choice
    case "$choice" in
     y|Y|yes|s|S|sim ) $NORMAL_TEXT "Starting utility";;
     n|N|no|nao ) exit 0;;
     * ) test_exec ;;
esac
}

##

Check_Directory()
{

if [ ! -d "$DIRETORIO" ]; then
	 $ERROR_TEXT "Error: The directory $DIRETORIO does not exist, aborting execution."
	 exit 1 
 else
	 $INFO_TEXT "OK: Existing $DIRECTORY directory."

fi
}

##

Check_Command()
{

for i in "${COMANDOS[@]}"
    do
    # do whatever on $i
    type $i >/dev/null 2>/dev/null
      if [ $? == 0 ]; then
	 	$INFO_TEXT "OK: existing $i command."
		separator_char
       else
    	$ERROR_TEXT "Error: The command $i was not found, aborting execution."
    	exit 1
    fi
done


}

##

Check_Maibox()
{

if (($MAILBOX_SERVERS > $MAILBOX_SERVERS)); then
	$ERROR_TEXT "CAUTION: The current version was developed for Single Server environments or environments with just one mailbox server."
	$ERROR_TEXT "CAUTION: For environments with more than one Mailbox server, it will be necessary to change the exported files if you want to rename the servers"
else
	$NORMAL_TEXT "OK: Environment has only one Mailbox server"
fi
}

##

Enter_New_Hostname()
{

read -p "Enter the new Zimbra server hostname: " userInput


if [[ -z "$userInput" ]]; then
      printf '%s\n' ""
      Enter_New_Hostname
     else
	  TEST_FQDN=`echo $userInput | awk -F. '{print NF}'`
	        if [ ! $TEST_FQDN -ge 2 ]; then
		       $ERROR_TEXT "Error: The hostname provided is not a valid FQDN"
		       Enter_New_Hostname
			fi
	  OLD_HOSTNAME="$zimbra_server_hostname"
	  NEW_HOSTNAME="$userInput"
	  $CHOICE_TEXT "Hostname reported: $NEW_HOSTNAME"
fi
}

##

Run_as_Zimbra()
{

if [ "$(whoami)" == "zimbra" ]; then
    $INFO_TEXT "OK: Running as Zimbra."
   else
    $ERROR_TEXT "ERROR: This command must be run as Zimbra."
    exit 1
fi
}

##

Replace_Hostname()
{
	#$INFO_TEXT "Modificar hostname"
read -p "Will the Zimbra server hostname be changed (yes/no)?" choice
   case "$choice" in
   y|Y|yes|s|S|sim ) 
    $CHOICE_TEXT "The server Hostname will be changed." 
	Enter_New_Hostname 
	Execute_Replace_Hostname 
	;;
   n|N|no|nao ) $CHOICE_TEXT "The server hostname will be maintained.";;
   * ) Replace_Hostname ;;
esac
}

##

Execute_Replace_Hostname()
{
sed -i s/$OLD_HOSTNAME/$NEW_HOSTNAME/g $DESTINO/ACCOUNTS.ldif
sed -i s/$OLD_HOSTNAME/$NEW_HOSTNAME/g $DESTINO/LISTAS.ldif
}

##

export_Mailboxes()
{
read -p "Do you want to export mailboxes (yes/no)?" choice
    case "$choice" in
    y|Y|yes|s|S|sim ) $CHOICE_TEXT "The RELATIONSHIP will be created for the FULL export of all accounts in the system.";;
    n|N|no|nao ) $CHOICE_TEXT "Mailboxes will not be exported. Execution aborted by user." ; exit 0 ;;
    * ) export_Mailboxes ;;
esac
}

##

Export_Dest()
{
read -p "Enter the directory used for export: " userInput
if [[ -z "$userInput" ]]; then
    $ERROR_TEXT "No directories provided"
    Export_Dest
       else
	EXPORT_PATH="$userInput"   
    $CHOICE_TEXT "Directory provided:" "$userInput"
fi
}

##

execute_Export_Full()
{
		 $NORMAL_TEXT "INBOX: Creating a file with related accounts for export:" 
		 $INFO_TEXT   "$WORKDIR/script_export_FULL.sh"
         for mailbox in $( echo $MAILBOX_LIST ); do
		 echo "zmmailbox -z -m $mailbox -t 0 getRestURL \"//?fmt=tgz\" > $EXPORT_PATH/$mailbox.tgz" >> $WORKDIR/script_export_FULL.sh #command to export full
		 chmod +x $WORKDIR/script_export_FULL.sh
		 echo "zmmailbox -z -m $mailbox -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$mailbox.tgz" >> $WORKDIR/script_import_FULL.sh #command to import full
		 chmod +x $WORKDIR/script_import_FULL.sh
done
}

##

execute_Export_Trash()
{
		 $NORMAL_TEXT "TRASH: Creating file with related accounts for export:"
         $INFO_TEXT   "$WORKDIR/script_export_TRASH.sh"
        for i in $( echo $MAILBOX_LIST ); do
		echo "zmmailbox -z -m $i -t 0 gru \"//Trash?fmt=tgz\" > $EXPORT_PATH/$i-Trash.tgz" >> $WORKDIR/script_export_TRASH.sh
		chmod +x $WORKDIR/script_export_TRASH.sh
		echo "zmmailbox -z -m $i -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$i-Trash.tgz" >> $WORKDIR/script_import_TRASH.sh
		chmod +x $WORKDIR/script_import_TRASH.sh
done
}

##

execute_Export_Junk()
{

	     $NORMAL_TEXT "SPAM: Creating file with related accounts for export:"
         $INFO_TEXT   "$WORKDIR/script_export_JUNK.sh"
		 for i in $( echo $MAILBOX_LIST ); do
		 echo "zmmailbox -z -m $i -t 0 gru \"//Junk?fmt=tgz\" > $EXPORT_PATH/$i-Junk.tgz" >> $WORKDIR/script_export_JUNK.sh
		 chmod +x $WORKDIR/script_export_JUNK.sh
		 echo "zmmailbox -z -m $i -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$i-Junk.tgz" >> $WORKDIR/script_import_TRASH.sh
		 chmod +x $WORKDIR/script_import_TRASH.sh
done

}

##

Clear_Workdir()
{
rm -f $WORKDIR/lista_contas.ldif
rm -fr $WORKDIR/alias
}

##
