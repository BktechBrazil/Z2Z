#/bin/bash
###   Z2Z - Mantido por BKTECH <http://www.bktech.com.br>                         ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>     ###
###   PARA INFORMACOES SOBRE A FERRAMENTA, FAVOR LER OS ARQUIVOS README E INSTALL ###

#DEFININDO VARIAVEIS DE AMBIENTE DO ZIMBRA
source ~/bin/zmshutil
zmsetvars

#FUNCOES E VARIAVEIS PARA O UTILITARIO
NORMAL_TEXT="printf \e[1;34m%-6s\e[m\n" #Azul
ERROR_TEXT="printf \e[1;31m%s\e[0m\n" #Vermelho
INFO_TEXT="printf \e[1;33m%s\e[0m\n" #Amarelo
CHOICE_TEXT="printf \e[1;32m%s\e[0m\n" #Verde
NO_COLOUR="printf \e[0m" #Branco
DEFAULTCOS_DN="cn=default,cn=cos,cn=zimbra"
DEFAULTEXTERNALCOS_DN="cn=defaultExternal,cn=cos,cn=zimbra"
SERVER_HOSTNAME=$zimbra_server_hostname
SESSION=`date +"%d_%b_%Y-%H-%M"`
SESSION_LOG="registro-$SESSION.log"


#CONFIRMA SE ESTA SENDO EXECUTADO COM O USUARIO ZIMBRA
if [ "$(whoami)" != "zimbra" ]; then
    $ERROR_TEXT "Esse comando deve ser executado como Zimbra."
    exit 1
fi

#ARQUIVOS NECESSARIOS PARA EXECUCAO
declare -a ARQUIVOS_IMPORT=('CONTAS.ldif' 'COS.ldif');

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
	   $INFO_TEXT "Hostname do servidor: $SERVER_HOSTNAME"
	   $INFO_TEXT "Hostname nos arquivos para importacao: $LDIF_HOSTNAME"
	   exit 1
fi

#COMANDOS NECESSARIOS PARA A EXECUCAO
declare -a COMANDOS=('ldapsearch' 'zmhostname' 'zmshutil' 'zmmailbox');

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

#INICIANDO ROTINAS DE IMPORTACAO
echo ""
echo ""
$INFO_TEXT "Essa versao NAO cria ou importa os dominios, somente continue se ja tiver criado os dominios do ambiente"
$INFO_TEXT "Importacao iniciada em: $SESSION" &> $SESSION_LOG
$NORMAL_TEXT "Registro da sessao: $SESSION_LOG"
ZIMBRAADMIN_DN=`ldapsearch -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -b '' -LLL uid=admin dn | awk '{print $2}'` &>> $SESSION_LOG #OBTER DN DO ADMIN

#INTERATIVIDADE: execucao da importacao
test_exec()
{
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
				   ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $ZIMBRAADMIN_DN &>> $SESSION_LOG
				   ;;
	  n|N|no|nao ) $CHOICE_TEXT "O usuario admin nao sera importado. Utilize a senha da NOVA instalacao";;
	  * ) test_importadmin ;;
esac
}

test_importadmin #executa a funcao test_importadmin

#INICIA IMPORTACAO DAS CLASSES DE SERVICO, CONTAS, NOMES ALTERNATIVOS E LISTAS DE DISTRIBUICAO
## REMOVE AS CLASSES DE SERVICO PADRAO DO ZIMBRA: DEFAULT E ZIMBRADEFAULT
$INFO_TEXT "Removendo classes de servico padrao: Default e DefaultExternal"
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTCOS_DN &>> $SESSION_LOG
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTEXTERNALCOS_DN &>> $SESSION_LOG

## IMPORTACAO DAS COS, CONTAS, APELIDOS E LISTAS

$INFO_TEXT "Importando classes de servico"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f COS.ldif &>> $SESSION_LOG
$INFO_TEXT "Importando contas"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f CONTAS.ldif &>> $SESSION_LOG
$INFO_TEXT "importando nomes alternativos"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f APELIDOS.ldif &>> $SESSION_LOG
$INFO_TEXT "importando listas de distribuicao"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f LISTAS.ldif &>> $SESSION_LOG

#
