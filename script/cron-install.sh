#!/bin/bash

yum -y install cronie

crontab -l > mycron
echo "* * * * * /bin/bash /root/script/monitoring" >> mycron
echo "*/5 * * * * /bin/bash /root/script/zabbix-conf.sh" >> mycron
crontab mycron
