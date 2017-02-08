#!/bin/bash
###   Z2Z - Mantido por BKTECH <http://www.bktech.com.br>                         ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>     ###
###   PARA INFORMACOES SOBRE A FERRAMENTA, FAVOR LER OS ARQUIVOS README E INSTALL ###

###   VERSAO 1.0.0b (08/02/2017)

#CARREGA FUNCOES UTILIZADAS PELO SCRIPT
. func.sh
 
#INICIAR Z2Z
clear
cat banner.txt
echo ""
#

#CONFIRMA SE ESTA SENDO EXECUTADO COM O USUARIO ZIMBRA
Run_as_Zimbra
separator_char

#CONFIRMA SE O USUARIO DESEJA CONTINUAR COM A EXECUCAO
test_exec
separator_char

#TESTES PARA EXECUCAO DO UTILITARIO

#COMANDOS NECESSARIOS
declare -a COMANDOS=('ldapsearch' 'zmmailbox' 'zmshutil');

Check_Command
separator_char


#DEFININDO VARIAVEIS DE AMBIENTE DO ZIMBRA
source ~/bin/zmshutil
zmsetvars


#DEFININDO NOME DO SERVIDOR COM VARIAVEL DO AMBIENTE
ZIMBRA_HOSTNAME=$zimbra_server_hostname
#DEFININDO USUARIO PARA BIND NO LDAP DO ZIMBRA COM VARIAVEL DO AMBIENE
ZIMBRA_BINDDN=$zimbra_ldap_userdn


####DIRETORIOS

DIRETORIO=$WORKDIR
Check_Directory
separator_char
DIRETORIO="`pwd`/skell"
Check_Directory
separator_char
DESTINO=$WORKDIR
mkdir $WORKDIR/alias #Cria diretorio temporario para exportar os nomes alternativos

#PODE CONTINUAR


 #EXPORTANDO CLASSES DE SERVICO
 $NORMAL_TEXT "EXPORTANDO CLASSES DE SERVICO"
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraCOS)" > $DESTINO/COS.ldif
 $INFO_TEXT "CLASSES DE SERVICO EXPORTADAS COM SUCESSO: $DESTINO/COS.ldif"
 separator_char
 
 #EXPORTANDO CONTAS - DESCONSIDERANDO CONTAS DE SERVICO DO ZIMBRA (zimbraIsSystemResource=TRUE)
 $NORMAL_TEXT  "EXPORTANDO CONTAS"
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL '(&(!(zimbraIsSystemResource=TRUE))(objectClass=zimbraAccount))' > $DESTINO/CONTAS.ldif
 $INFO_TEXT "CONTAS EXPORTADAS COM SUCESSO: $DESTINO/CONTAS.ldif"
 separator_char
 
 #EXPORTANDO NOMES ALTERNATIVOS
 $NORMAL_TEXT  "EXPORTANDO NOMES ALTERNATIVOS"
 separator_char

 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password  -b '' -LLL '(&(!(uid=root))(!(uid=postmaster))(objectclass=zimbraAlias))' uid | grep ^uid | awk '{print $2}' > $DESTINO/lista_contas.ldif

 for MAIL in $(cat $DESTINO/lista_contas.ldif);
 	do 
	      ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(&(uid=$MAIL)(objectclass=zimbraAlias))" > $DESTINO/alias/$MAIL.ldif
		  	cat $DESTINO/alias/*.ldif > $DESTINO/APELIDOS.ldif
			done 

   $INFO_TEXT "NOMES ALTENATIVOS EXPORTADOS COM SUCESSO: $DESTINO/APELIDOS.ldif"
   separator_char

#EXPORTANDO LISTAS DE DISTRIBUICAO
   $NORMAL_TEXT  "EXPORTANDO LISTAS DE DISTRIBUICAO"
   separator_char
ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraDistributionList)" > $DESTINO/LISTAS.ldif
   $INFO_TEXT "LISTAS DE DISTRIBUICAO EXPORTADAS COM SUCESSO: $DESTINO/LISTAS.ldif"
   separator_char

#LIMPA OS ARQUIVOS TEMPORARIOS CRIADOS NO DIRETORIO EXPORT
Clear_Workdir

#COPIA SCRIPT DE IMPORTACAO E BANNER SIMPLES 
cp skell/importar_ldap.sh export/
cp skell/banner_simples.txt export/
chmod +x export/importar_ldap.sh

#INTERATIVIDADE: ALTERAR HOSTNAME DO SERVIDOR
Replace_Hostname
separator_char

#INTERATIVIDADE: EXPORTAR (RELACAO) DE CAIXAS POSTAIS

export_Mailboxes
separator_char

Export_Dest

#EXPORTANDO CAIXA POSTAL
execute_Export_Full
separator_char

#EXPORTANDO LIXEIRA
execute_Export_Trash
separator_char

#EXPORTANDO SPAM
execute_Export_Junk
separator_char

#FIM
