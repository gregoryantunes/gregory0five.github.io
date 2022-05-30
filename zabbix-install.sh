#!/bin/bash
# Instalação
#-------------------------------------------------------------------
{
systemctl disable firewalld.service
systemctl stop firewalld.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release setup -y ps80
yum -y install percona-server-server
} > /dev/null 2>&1
{
systemctl start mysqld
systemctl enable mysqld
MYSQL_PASSWD=$(grep "password" /var/log/mysqld.log | awk '{print $NF}')
mysql --connect-expired-password -uroot -p"$MYSQL_PASSWD" -e "
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'N@8815fm5';
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'N@8815fm5';
ALTER USER 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY 'N@8815fm5';
grant all privileges on zabbix.* to zabbix@localhost;"
} > /dev/null 2>&1
{
rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-6.0-1.el8.noarch.rpm
dnf clean all
dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent
zcat /usr/share/doc/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p'N@8815fm5' zabbix
sed -i 's/# DBPassword=/DBPassword=N@8815fm5/' /etc/zabbix/zabbix_server.conf
} > /dev/null 2>&1

# ZABBIX FRONT-END CONFIGURATION
echo "<?php
// Zabbix GUI configuration file.

\$DB['TYPE']                             = 'MYSQL';
\$DB['SERVER']                   = 'localhost';
\$DB['PORT']                             = '0';
\$DB['DATABASE']                 = 'zabbix';
\$DB['USER']                             = 'zabbix';
\$DB['PASSWORD']                 = 'N@8815fm5';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']                   = '';

// Used for TLS connection.
\$DB['ENCRYPTION']               = false;
\$DB['KEY_FILE']                 = '';
\$DB['CERT_FILE']                = '';
\$DB['CA_FILE']                  = '';
\$DB['VERIFY_HOST']              = false;
\$DB['CIPHER_LIST']              = '';

// Vault configuration. Used if database credentials are stored in Vault secrets manager.
\$DB['VAULT_URL']                = '';
\$DB['VAULT_DB_PATH']    = '';
\$DB['VAULT_TOKEN']              = '';

// Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
// This option is enabled by default for new Zabbix installations.
// For upgraded installations, please read database upgrade notes before enabling this option.
\$DB['DOUBLE_IEEE754']   = true;

// Uncomment and set to desired values to override Zabbix hostname/IP and port.
// \$ZBX_SERVER                  = '';
// \$ZBX_SERVER_PORT             = '';

\$ZBX_SERVER_NAME                = 'test install';

\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//\$HISTORY['url'] = [
//      'uint' => 'http://localhost:9200',
//      'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//\$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//\$SSO['SP_KEY']                        = 'conf/certs/sp.key';
//\$SSO['SP_CERT']                       = 'conf/certs/sp.crt';
//\$SSO['IDP_CERT']              = 'conf/certs/idp.crt';
//\$SSO['SETTINGS']              = [];" > /etc/zabbix/web/zabbix.conf.php

# ZABBIX RESTART N' ENABLE
{
systemctl restart zabbix-server zabbix-agent httpd php-fpm
systemctl enable zabbix-server zabbix-agent httpd php-fpm
} > /dev/null 2>&1
# USER INTERFACE
IP=$(ip a | grep -vE "(:|valid|host)" | awk -F/ '{print $1}' | awk '{print $2}')                                                                                                                                                             #VARIABLE THAT GETS USER IP

echo "
URL: http://$IP/zabbix
User: Admin
Senha: zabbix
"

