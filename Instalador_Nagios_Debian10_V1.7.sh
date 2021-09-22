#!/bin/bash

#V1.7
#Leonel P. Corrêa
#leonelp.correa@gmail.com


#ATENÇÃO SCRIPT ESCRITO PARA A INSTALAÇÃO DO NAGIOS VERSÃO 4.4.6 A ULTIMA VERSÃO LANÇADA DA DATA DE 09-08-2021
#PLUGINS VERSÃO 2.2.1 TAMBEM DATADO DE 09-08-2021, PNP4NAGIOS 0.6.25 ULTIMA VERSÃO LANÇADA NO SITE DO DESENVOLVEDOR
#E QUE APARENTA QUE SEU DESENVOLVIMENTO FOI INTERROMPIDO
#EM SISTEMA DEBIAN 10.X, NÃO FORAM TESTADAS OUTRAS VERSÕES E/OU SISTEMAS EM VERSÕES DIFERENTES
#CASO SE VENHA A USAR EM OUTRA DISTRIBUIÇÃO DE LINUX E/OU VERSÃO, PODE SER QUE NÃO FUNCIONE OU COM SORTE QUE FUNCIONE.




##instalação Nagios:

#Atualização do Sistema
apt-get update
apt-get upgrade

#Instalação de pacotes essenciais
apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev

#Dowload e descompactação do instalador para compilar
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar xzf nagios-4.4.6.tar.gz

#Compilando a instalação:
cd /tmp/nagios-4.4.6/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
make install-groups-users
usermod -a -G nagios www-data
make install
make install-daemoninit
make install-commandmode
make install-config

#Arquivos de configuração do Apache
make install-webconf
a2enmod rewrite
a2enmod cgi


#Configuração do Firewall
iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
apt-get install -y iptables-persistent

#Criação da senha para o usuario nagiosadmin, se no futuro queira criar mais de um usuario,
#será necessario editar o comando abaixo removendo o parametro -c
echo 'DIGITE A SENHA PARA O USUARIO nagiosadmin'
sleep 5s
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin


#Reiniciando os seriviços, de dois modos diferentes para caso o sistema não aceite um o outro irá funcionar
service apache2 restart
/etc/init.d/apache2 restart
service nagios restart
/etc/init.d/nagios restart

echo '#'
echo '##'
echo '###'
echo 'Nagios Core Totalmente Instalado, vamos instalar os plugins'
echo 'Nagios Core Totalmente Instalado, vamos instalar os plugins'
echo 'Nagios Core Totalmente Instalado, vamos instalar os plugins'
echo 'Nagios Core Totalmente Instalado, vamos instalar os plugins'
echo '###'
echo '##'
echo '#'

sleep 10s

##instalação dos Plugins

#Instalando pacotes necessarios
apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext

#Baixando e descompactando os plugins
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz

#Compilando os plugins
cd /tmp/nagios-plugins-release-2.2.1/
./tools/setup
./configure
make
make install

#Reiniciando os seriviços, de dois modos diferentes para caso o sistema não aceite um o outro irá funcionar
service apache2 restart
/etc/init.d/apache2 restart
service nagios restart
/etc/init.d/nagios restart

echo '#'
echo '##'
echo '###'
echo 'Plugins Totalmente Instalados, vamos instalar o PNP4NAGIOS'
echo 'Plugins Totalmente Instalados, vamos instalar o PNP4NAGIOS'
echo 'Plugins Totalmente Instalados, vamos instalar o PNP4NAGIOS'
echo 'Plugins Totalmente Instalados, vamos instalar o PNP4NAGIOS'
echo '###'
echo '##'
echo '#'

sleep 10s


## Instação do PNP4NAGIOS

#Instalando pacotes
apt-get install php7.3-gd rdtool -y
apt-get -y install rrdtool
apt-get -y install librrds-perl
apt-get -y install libnet-snmp-perl
apt-get -y install php7.3-xml

#Baixando e descompactando
cd /tmp
wget http://downloads.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.25.tar.gz
tar zxvf pnp4nagios-0.6.25.tar.gz

#Compilando
cd pnp4nagios-0.6.25
./configure
make all
make fullinstall
ldconfig

##Configuração

#Habilitando os dados de performance
sed -i 's/process_performance_data=0/process_performance_data=1/' /usr/local/nagios/etc/nagios.cfg

#Escrevendo Configurações do PNP4NAGIOS no final do arquivo nagios.cfg
echo '# ' >> /usr/local/nagios/etc/nagios.cfg
echo '# ' >> /usr/local/nagios/etc/nagios.cfg
echo '#' >> /usr/local/nagios/etc/nagios.cfg
echo '# service performance data' >> /usr/local/nagios/etc/nagios.cfg
echo 'service_perfdata_file=/usr/local/pnp4nagios/var/service-perfdata' >> /usr/local/nagios/etc/nagios.cfg
echo 'service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOST$' >> /usr/local/nagios/etc/nagios.cfg
echo 'service_perfdata_file_mode=a' >> /usr/local/nagios/etc/nagios.cfg
echo 'service_perfdata_file_processing_interval=15' >> /usr/local/nagios/etc/nagios.cfg
echo 'service_perfdata_file_processing_command=process-service-perfdata-file' >> /usr/local/nagios/etc/nagios.cfg
echo '#' >> /usr/local/nagios/etc/nagios.cfg
echo '# host performance data starting with Nagios 3.0' >> /usr/local/nagios/etc/nagios.cfg
echo '#' >> /usr/local/nagios/etc/nagios.cfg
echo 'host_perfdata_file=/usr/local/pnp4nagios/var/host-perfdata' >> /usr/local/nagios/etc/nagios.cfg
echo 'host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATET$' >> /usr/local/nagios/etc/nagios.cfg
echo 'host_perfdata_file_mode=a' >> /usr/local/nagios/etc/nagios.cfg
echo 'host_perfdata_file_processing_interval=15' >> /usr/local/nagios/etc/nagios.cfg
echo 'host_perfdata_file_processing_command=process-host-perfdata-file' >> /usr/local/nagios/etc/nagios.cfg


#Escrevendo configurações no final do arquivo commands.cfg
echo '# PNP4NAGIOS ' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'define command{' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'command_name process-service-perfdata-file' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'command_line /usr/local/pnp4nagios/libexec/process_perfdata.pl --bulk=/usr/local/pnp4nagios/var/service-perfdata' >> /usr/local/nagios/etc/objects/commands.cfg
echo '}' >> /usr/local/nagios/etc/objects/commands.cfg
echo '#' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'define command{' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'command_name process-host-perfdata-file' >> /usr/local/nagios/etc/objects/commands.cfg
echo 'command_line /usr/local/pnp4nagios/libexec/process_perfdata.pl --bulk=/usr/local/pnp4nagios/var/host-perfdata' >> /usr/local/nagios/etc/objects/commands.cfg
echo '}' >> /usr/local/nagios/etc/objects/commands.cfg

#Renomeando o arquivo de instalção e destravando o PNP
mv /usr/local/pnp4nagios/share/install.php /usr/local/pnp4nagios/share/install.php.org


#Reiniciando os seriviços, de dois modos diferentes para caso o sistema não aceite um o outro irá funcionar
service apache2 restart
/etc/init.d/apache2 restart
service nagios restart
/etc/init.d/nagios restart

#Ajustando a configuração no apache
cp /etc/httpd/conf.d/pnp4nagios.conf /etc/apache2/sites-enabled/
cd /etc/apache2/mods-enabled/
ln -s ../mods-available/rewrite.load rewrite.load
a2enmod rewrite

#Criando pasta de serviços
mkdir /usr/local/nagios/etc/services

#Corrigir Erro do PHP, tinha na versão 5 e até a versão 7.3 não foi corrigido.
sed -i 's:if(sizeof(\$pages:if(is_array(\$pages) \&\& sizeof(\$pages:' /usr/local/pnp4nagios/share/application/models/data.php


# Adicionar configuração em templates para o uso do host-pnp e srv-pnp:

#Define Host
echo 'define host {' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'name host-pnp' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=_HOST_' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'register 0' >> /usr/local/nagios/etc/objects/templates.cfg
echo '}' >> /usr/local/nagios/etc/objects/templates.cfg

#Define Service
echo 'define service {' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'name srv-pnp' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=$SERVICEDESC$' >> /usr/local/nagios/etc/objects/templates.cfg
echo 'register 0' >> /usr/local/nagios/etc/objects/templates.cfg
echo '}' >> /usr/local/nagios/etc/objects/templates.cfg


#Reiniciando os seriviços, de dois modos diferentes para caso o sistema não aceite um o outro irá funcionar
service apache2 restart
/etc/init.d/apache2 restart
service nagios restart
/etc/init.d/nagios restart
/etc/init.d/npcd restart
service npcd restart



echo '#'
echo '##'
echo '###'
echo 'Se tudo não explodiu deve estar funcionando'
echo 'Acesse localhost/nagios'
echo 'Acesse com login nagiosadmin e a senha que você escolheu'
echo 'Talvez a explosão tenha delay e exploda quando voce logar, CUIDADO!!!. Brinks or no'
echo '###'
echo '##'
echo '#'

sleep 10s

#############################################################################################################################
#Caso ocorra erro de um grande quadro vermelho no pnp
#error: stdout
#https://github.com/lingej/pnp4nagios/issues/146
#basicamente deve se editar o aquivo /usr/local/pnp4nagios/share/templates.dist/default.php
#procurar a linha: $lower = " --lower=" . $VAL['MIN']; e substituir por: $lower = " --lower-limit=" . $VAL['MIN'];
#procurar a linha: $lower = " --lower=0 "; e substiuir por: $lower = " --lower-limit=0 ";
##############################################################################################################################


