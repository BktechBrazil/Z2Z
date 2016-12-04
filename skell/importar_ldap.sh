#/bin/bash
###   Z2Z - Mantido por BKTECH <http://www.bktech.com.br>                         ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>     ###
###   PARA INFORMACOES SOBRE A FERRAMENTA, FAVOR LER OS ARQUIVOS README E INSTALL ###


#FUNCOES E VARIAVEIS PARA O UTILITARIO
NORMAL_TEXT="printf \e[1;34m%-6s\e[m\n" #Azul
ERROR_TEXT="printf \e[1;31m%s\e[0m\n" #Vermelho
INFO_TEXT="printf \e[1;33m%s\e[0m\n" #Amarelo
CHOICE_TEXT="printf \e[1;32m%s\e[0m\n" #Verde
NO_COLOUR="printf \e[0m" #Branco
DEFAULTCOS_DN="cn=default,cn=cos,cn=zimbra"
DEFAULTEXTERNALCOS_DN="cn=defaultExternal,cn=cos,cn=zimbra"
SERVER_HOSTNAME=$zimbra_server_hostname

#CONFIRMA SE ESTA SENDO EXECUTADO COM O USUARIO ZIMBRA
if [ "$(whoami)" != "zimbra" ]; then
    $ERROR_TEXT "Esse comando deve ser executado como Zimbra."
    exit 1
fi

#ARQUIVOS NECESSARIOS PARA EXECUCAO
declare -a ARQUIVOS_IMPORT=('APELIDOS.ldif' 'CONTAS.ldif' 'COS.ldif' 'LISTAS.ldif');

for i in "${ARQUIVOS_IMPORT[@]}"
    do
    if [ -r $i ]
      then
	  $INFO_TEXT "OK: Arquivo $i encontrado"
	  else
      $ERROR_TEXT  "ERRO: Arquivo $i nao encontrado ou sem permissao de leitura."
      exit 1
fi
done

#OBTENDO HOSTNAME NAS ENTRADAS PARA CONFIRMAR SE CORRESPONDE AO HOSTNAME DO SERVIDOR
LDIF_HOSTNAME=`grep zimbraMailHost CONTAS.ldif | uniq | awk '{print $2}'`
if [ "$SERVER_HOSTNAME" != "$LDIF_HOSTNAME" ]; then
	   $ERROR_TEXT "ERRO: O hostname do servidor nao corresponde ao hostname dos arquivos de importacao"
	   exit 1
fi

#COMANDOS NECESSARIOS PARA A EXECUCAO
declare -a COMANDOS=('test' 'ldapsearch' 'zmhostname' 'zmshutil' 'zmmailbox');

for i in "${COMANDOS[@]}"
    do
	type $i >/dev/null 2>/dev/null
if [ $? != 0 ]; then
	  $ERROR_TEXT "ERRO: O comando $i nao foi encontrado, abortando execucao."
	  exit 1
fi
done

#
clear
cat banner_simples.txt #Exibir Banner


#DEFININDO VARIAVEIS DE AMBIENTE DO ZIMBRA
source ~/bin/zmshutil
zmsetvars
ZIMBRAADMIN_DN=`ldapsearch -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -b '' -LLL uid=admin dn | awk '{print $2}'` #OBTER DN DO ADMIN

#INTERATIVIDADE: execucao da importacao
test_exec()
{
echo ""
read -p "Deseja iniciar a importacao das CLASSES DE SERVICO, CONTAS, NOMES ALTERNATIVOS E LISTAS E DISTRIBUICAO (sim/nao)?" choice
    case "$choice" in
     y|Y|yes|s|S|sim ) $NORMAL_TEXT "Iniciando Z2Z";;
     n|N|no|nao ) exit 0;;
	 * ) test_exec ;;
     esac
}
test_exec #executa a funcao test_exec


#INTERATIVIDADE: importacao do usuario admin
test_importadmin()
{
echo ""
read -p "Deseja importar o usuario ADMIN (sim/nao)?" choice
    case "$choice" in
	  y|Y|yes|s|S|sim ) 
	               $NORMAL_TEXT "Removendo ADMIN: $ZIMBRAADMIN_DN" 
				   ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $ZIMBRAADMIN_DN
				   ;;
	  n|N|no|nao ) $INFO_TEXT "O usuario admin nao sera importado";;
	  * ) test_importadmin ;;
esac
}

test_importadmin #executa a funcao test_importadmin

#INICIA IMPORTACAO DAS CLASSES DE SERVICO, CONTAS, NOMES ALTERNATIVOS E LISTAS DE DISTRIBUICAO
## REMOVE AS CLASSES DE SERVICO PADRAO DO ZIMBRA: DEFAULT E ZIMBRADEFAULT
$INFO_TEXT "Removendo classes de servico padrao: Default e DefaultExternal"
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTCOS_DN
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTEXTERNALCOS_DN

## IMPORTACAO DAS COS, CONTAS, APELIDOS E LISTAS

ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f COS.ldif

ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f CONTAS.ldif

ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f APELIDOS.ldif

ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f LISTAS.ldif
