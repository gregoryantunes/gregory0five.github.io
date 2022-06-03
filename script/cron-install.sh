#!/bin/bash
yum -y install cronie
crontab -l > mycron
echo "* * * * * /root/script/monitoring
*/5 * * * * /root/script/zabbix-conf.sh" > mycron
crontab mycron
