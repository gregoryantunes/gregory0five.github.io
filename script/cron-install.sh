#!/bin/bash

yum -y install cronie

crontab -l > mycron
echo "* * * * * /bin/bash /root/zabbix-scripts/monitoring" >> mycron
echo "*/5 * * * * /bin/bash /root/zabbix-scripts/zabbix-conf.sh" >> mycron
crontab mycron
