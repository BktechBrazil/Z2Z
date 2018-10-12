# Z2Z (Zimbra2Zimbra Migration Tool) - _Versão 1.0.1_ - Mantido por BKTECH <http://www.bktech.com.br>
 
# Copyright (C) 2016-2018  Fabio Soares Schmidt <fabio@respirandolinux.com.br> 

# DISTRIBUÍDO SOB A LICENÇA CREATIVE COMMONS: Atribuição-NãoComercial-CompartilhaIgual (CC BY-NC-SA)

Esta licença permite que outros remixem, adaptem e criem a partir do trabalho original para fins não comerciais, desde que atribuam
ao CRIADOR o devido crédito (banner original e Copyright), e que licenciem as novas criações sob os MESMOS termos. Este programa é 
distribuído na esperança de que possa ser útil, mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a qualquer MERCADO ou 
APLICAÇÃO EM PARTICULAR.
 
#################################################################################################################################
 
# Contato:
 
 Site: <http://www.bktech.com.br>
 E-mail: <z2z@bktech.com.br>
 
 Desenvolvedor: Fabio Soares Schmidt <fabio@respirandolinux.com.br> ou <https://respirandolinux.com.br>

#################################################################################################################################
										
[README - v1.0.0b]
												
# CHANGELOG: 

 (FAVOR LER O ARQUIVO CHANGELOG)

# INSTALAÇÃO
 
 (FAVOR LER O ARQUIVO INSTALL)
 
# UTILIZAÇÃO
 
 (FAVOR LER O ARQUIVO INSTALL)
  
# Z2Z

Essa ferramenta foi criada visando facilitar o processo de migração entre ambientes Zimbra, independentemente de qual versão
ou edição esteja sendo **utilizada**. Motivada pelos desafios encontrados em migrações efetuadas pela BKTECH (parceiro oficial Zimbra para negócios e treinamentos), além da participação em comunidades do Zimbra, a ferramenta visa, no decorrer de sua evolução, atender os mais diversos cenários, contemplando também a migração de outras plataformas, livres e proprietárias - "A2Z: Anything/Anywhere to Zimbra".

**Em casos de Upgrade, isto é, migrar PARA uma versão mais nova do Zimbra. Não é garantido o funcionamento em casos de downgrade.**

# O QUE SERÁ MIGRADO?

Embora o Zimbra seja uma ferramenta bastante avançada na questão de utilitários de migração, a ferramenta agiliza e simplifica o processo, exportando:

**(Permitindo que seja possível renomear o nome do servidor durante a exportação)**.

[x] Classes de serviço

[x] Contas - Preservando as senhas, caso esteja utilizando autenticação interna

[x] Nomes alternativos

[x] Listas de distribuição

[x] Caixas postais (e-mails, calendários, tarefas, contatos, porta-arquivos, preferências,etc...)

Nesta primeira versão, Z2Z facilita o processo de exportação das entradas citadas, além de criar o lote de contas que devem ser exportadas, utilizando o comando nativo - zmmailbox. **Os domínios devem ser previamente criados antes da importação.**

![alt tag](https://respirandolinux.files.wordpress.com/2017/02/zimbrazimbratmp333z2z-master.jpg) 

# DEPOIMENTOS

"Recentemente utilizamos como apoio à migração de 2400 contas a ferramenta **Z2Z** no Tribunal Regional do Trabalho da 13ª Região. Tal ferramenta foi bastante útil pois estávamos em uma versão bem antiga do zimbra o que impossibilitou o update via script. A migração ocorreu de forma incremental devido a quantidade de contas até o chaveamento. Tudo ocorreu conforme o esperado e hoje estamos usando a versão mais atual do zimbra." - Filipe A. Motta Braga - Tribunal Regional do Trabalho da 13a. Região - Paraíba 

"Gostaria de parabeniza-lo pela excelente ferramenta z2z, me ajudou bastante em uma migração do Zimbra 8.0.7 para 8.7.11
Grande abraço!" - Marco Brandão - Plus Informática - Minas Gerais

"Parabéns por essa excelente ferramenta, seria impossível migrar o servidor antigo de nossa empresa sem o auxílio do seu projeto. A importação foi perfeita, quase 160 contas contas com mais de 700GB de dados, nenhuma falha e ambiente rápido e estável após a importação." - Alisson S. Conde – Equipe de TI Paranatex Têxtil LTDA - Paraná

# ROADMAP
 
Em versões futuras, a ferramenta visa atender cenários com ambientes Multi-Server que envolvam a substituição de hostnames de servidores mailbox, além da exportação das principais configurações do ambiente Zimbra.

Também está no plano de evolução da mesma, o tratamento de diferentes estratégias de migração, permitindo migrações gradativas, por exemplo, através  de processos de export e import incrementais. 
 
**TODA avaliação e contribuição _(codificação,testes,críticas,sugestões)_ é muito bem-vinda !**
 
Obrigado desde já pela atenção.
