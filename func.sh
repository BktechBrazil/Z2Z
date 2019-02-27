#!/bin/bash
#Changelog: 
# 15/Nov/2016: Criação do arquivo func.sh (Fabio Soares Schmidt)

#FUNCOES E VARIAVEIS PARA O UTILITARIO
NORMAL_TEXT="printf '\e[1;34m%-6s\e[m\n'" #Azul
ERROR_TEXT="printf '\e[1;31m%s\e[0m\n'" #Vermelho
INFO_TEXT="printf '\e[1;33m%s\e[0m\n'" #Amarelo
CHOICE_TEXT="printf '\e[1;32m%s\e[0m\n'" #Verde
NO_COLOUR="'\e[0m'" #Branco
MAILBOX_LIST=`zmprov -l gaa | grep -v -E "admin|virus-|ham.|spam.|galsync"` #TODAS AS CONTAS DO ZIMBRA, EXCETO CONTAS DE SISTEMA
WORKDIR=`pwd`"/export"

##

separator_char()
{
echo ++++++++++++++++++++++++++++++++++++++++
}
##

test_exec()
{
read -p "Continuar (sim/nao)?" choice
    case "$choice" in
     y|Y|yes|s|S|sim ) $NORMAL_TEXT "Iniciando utilitario";;
     n|N|no|nao ) exit 0;;
     * ) test_exec ;;
esac
}

##

Check_Directory()
{

if [ ! -d "$DIRETORIO" ]; then
	 $ERROR_TEXT "ERRO: O diretorio $DIRETORIO nao existe, abortando execucao."
	 exit 1 
 else
	 $INFO_TEXT "OK: Diretorio $DIRETORIO existente."

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
	 	$INFO_TEXT "OK: comando $i existente."
		separator_char
       else
    	$ERROR_TEXT "ERRO: O comando $i nao foi encontrado, abortando execucao."
    	exit 1
    fi
done


}

##

Enter_New_Hostname()
{

read -p "Informe o novo hostname do servidor Zimbra: " userInput


if [[ -z "$userInput" ]]; then
      printf '%s\n' ""
      Enter_New_Hostname
     else
	  TEST_FQDN=`echo $userInput | awk -F. '{print NF}'`
	        if [ ! $TEST_FQDN -ge 2 ]; then
		       $ERROR_TEXT "ERRO: O hostname informado nao e um FQDN valido"
		       Enter_New_Hostname
			fi
	  OLD_HOSTNAME="$zimbra_server_hostname"
	  NEW_HOSTNAME="$userInput"
	  $CHOICE_TEXT "Hostname informado: $NEW_HOSTNAME"
fi
}

##

Run_as_Zimbra()
{

if [ "$(whoami)" == "zimbra" ]; then
    $INFO_TEXT "OK: Executando como Zimbra."
   else
    $ERROR_TEXT "ERRO: Esse comando deve ser executado como Zimbra."
    exit 1
fi
}

##

Replace_Hostname()
{
	#$INFO_TEXT "Modificar hostname"
read -p "O Hostname do servidor do Zimbra sera alterado (sim/nao)?" choice
   case "$choice" in
   y|Y|yes|s|S|sim ) 
    $CHOICE_TEXT "O Hostname do servidor sera alterado." 
	Enter_New_Hostname 
	Execute_Replace_Hostname 
	;;
   n|N|no|nao ) $CHOICE_TEXT "Sera mantido o hostname do servidor.";;
   * ) Replace_Hostname ;;
esac
}

##

Execute_Replace_Hostname()
{
sed -i s/$OLD_HOSTNAME/$NEW_HOSTNAME/g $DESTINO/CONTAS.ldif
sed -i s/$OLD_HOSTNAME/$NEW_HOSTNAME/g $DESTINO/LISTAS.ldif
}

##

export_Mailboxes()
{
read -p "Deseja exportar as caixas postais (sim/nao)?" choice
    case "$choice" in
    y|Y|yes|s|S|sim ) $CHOICE_TEXT "Sera criada a RELACAO para o export FULL de todas as contas do sistema.";;
    n|N|no|nao ) $CHOICE_TEXT "Nao sera efetuado o export das caixas postais. Execucao abortada pelo usuario." ; exit 0 ;;
    * ) export_Mailboxes ;;
esac
}

##

Export_Dest()
{
read -p "Informe qual sera o diretorio utilizado para exportacao: " userInput
if [[ -z "$userInput" ]]; then
    $ERROR_TEXT "Nenhum diretorio informado"
    Export_Dest
       else
	EXPORT_PATH="$userInput"   
    $CHOICE_TEXT "Diretorio informado:" "$userInput"
fi
}

##

execute_Export_Full()
{
		 $NORMAL_TEXT "INBOX: Criando arquivo com as contas relacionadas para exportacao:" 
		 $INFO_TEXT   "$WORKDIR/script_export_FULL.sh"
         for mailbox in $( echo $MAILBOX_LIST ); do
		 echo "zmmailbox -z -m $mailbox -t 0 getRestURL \"//?fmt=tgz\" > $EXPORT_PATH/$mailbox.tgz" >> $WORKDIR/script_export_FULL.sh #comando para export full
		 chmod +x $WORKDIR/script_export_FULL.sh
		 echo "zmmailbox -z -m $mailbox -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$mailbox.tgz" >> $WORKDIR/script_import_FULL.sh #comando para import full
		 chmod +x $WORKDIR/script_import_FULL.sh
done
}

##

execute_Export_Trash()
{
		 $NORMAL_TEXT "LIXEIRA: Criando arquivo com as contas relacionadas para exportacao:"
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

	     $NORMAL_TEXT "SPAM: Criando arquivo com as contas relacionadas para exportacao:"
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
