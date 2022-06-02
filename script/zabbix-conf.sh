#!/bin/bash

#	DISCOVERY RULES
FILE_SYSTEM=$(df -P | grep -v "Filesystem\|tmpfs" | awk '{ print $6}' | awk 'BEGIN {first=1; printf "%s","{\"data\":["} {if (first != 1) printf "%s",","; first=0; printf "{\"{#FS}\":\"%s\"}",$$1} END {print "]}"}')
DEVICE=$(sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print $2}' | awk 'BEGIN {first=1; printf "%s","{\"data\":["} {if (first != 1) printf "%s",","; first=0; printf "{\"{#DEV}\":\"%s\"}",$$1} END {print "]}"}')
NETWORK=$(sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print $2}' | awk 'BEGIN {first=1; printf "%s","{\"data\":["} {if (first != 1) printf "%s",","; first=0; printf "{\"{#NET}\":\"%s\"}",$$1} END {print "]}"}')


#	SYSTEM
OPSYSTEM=$(hostnamectl | awk -F: 'NR==7 {print $2}')
KERNEL=$(hostnamectl | awk -F: 'NR==9 {print $2}')
CPU_ARCH=$(hostnamectl | awk -F: 'NR==10 {print $2}')
UPTIME=$(uptime | awk -F, '{print $1}' | awk '{print $3}' | sed 's/\:/./')

#	MEMORY
MEM_TOTAL=$(free -b | grep -vE "(total|Swap)" | awk '{print $2}')
MEM_USED=$(free -b | grep -vE "(total|Swap)" | awk '{print $3}')
MEM_FREE=$(free -b | grep -vE "(total|Swap)" | awk '{print $4}')
MEM_SHARED=$(free -b | grep -vE "(total|Swap)" | awk '{print $5}')
MEM_BUFF_CACHE=$(free -b | grep -vE "(total|Swap)" | awk '{print $6}')
MEM_AVAIL=$(free -b | grep -vE "(total|Swap)" | awk '{print $7}')

#	SWAP
SWAP_TOTAL=$(free -b | grep -vE "(total|Mem)" | awk '{print $2}')
SWAP_USED=$(free -b | grep -vE "(total|Mem)" | awk '{print $3}')
SWAP_FREE=$(free -b | grep -vE "(total|Mem)" | awk '{print $4}')

#	PAGING
PG_IN=$(sar -B 1 1 | grep "Average" | awk '{print $2}')
PG_OUT=$(sar -B 1 1 | grep "Average" | awk '{print $3}')
FAULT=$(sar -B 1 1 | grep "Average" | awk '{print $4}')
MAJ_FLT=$(sar -B 1 1 | grep "Average" | awk '{print $5}')

#	SENDER DISCOVERY RULES
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.discovery.fs" -o "$FILE_SYSTEM"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.discovery.dev" -o "$DEVICE"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.discovery.net" -o "$NETWORK"

#	SENDER SYSTEM
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[opsystem]" -o "$OPSYSTEM"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[kernel_v]" -o "$KERNEL"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[cpu_arch]" -o "$CPU_ARCH"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[uptime]" -o "$UPTIME"

#	SENDER MEMORY
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_total]" -o "$MEM_TOTAL"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_used]" -o "$MEM_USED"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_free]" -o "$MEM_FREE"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_shared]" -o "$MEM_SHARED"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_buff_cache]" -o "$MEM_BUFF_CACHE"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[mem_avail]" -o "$MEM_AVAIL"

#	SENDER SWAP
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[swap_total]" -o "$SWAP_TOTAL"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[swap_used]" -o "$SWAP_USED"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[swap_free]" -o "$SWAP_FREE"

#	SENDER PAGING
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[pg_in]" -o "$PG_IN"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[pg_out]" -o "$PG_OUT"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[fault]" -o "$FAULT"
zabbix_sender -z 192.168.0.119 -s "host-king" -k "custom.static[maj_flt]" -o "$MAJ_FLT"

#	COMMAND
{
	df -P | grep -vE "(Filesystem|tmpfs)" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$6",alocado]\" -o \""$2*1024"\""}'				#ALOCADO
	df -P | grep -vE "(Filesystem|tmpfs)" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$6",usado]\" -o \""$3*1024"\""}'				#USADO
	df -P | grep -vE "(Filesystem|tmpfs)" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$6",livre]\" -o \""$4*1024"\""}'				#LIVRE
	df -P | grep -vE "(Filesystem|tmpfs)" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$6",pclivre]\" -o \""100-$5"\""}' | sed 's/\%//'		#%LIVRE
	df -i | grep -vE "(Filesystem|tmpfs)" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$6",iusado]\" -o \""$5"\""}' | sed 's/%//'			#%INODESUSADOS
	sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",tps]\" -o \""$3"\""}'				#TPS
	sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",rkbs]\" -o \""$4*1024"\""}'				#RKBS
	sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",wkbs]\" -o \""$5*1024"\""}'				#WKBS
	sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",svctm]\" -o \""$9/1000"\""}'			#SVCTM
	sar -d 1 1 | grep "Average" | grep -v "DEV" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",util]\" -o \""$10"\""}'				#%UTIL
	sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",rxpck]\" -o \""$3"\""}'
	sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",txpck]\" -o \""$4"\""}'
	sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",rxkb]\" -o \""$5*1024"\""}'
	sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",txkb]\" -o \""$6*1024"\""}'
	sar -n DEV 1 1 | grep "Average" | grep -v "rxpck" | awk '{print "zabbix_sender -z 192.168.0.119 -s \"host-king\" -k \"custom.dynamic["$2",if_util]\" -o \""$10"\""}'
} >> sender
sh sender
sleep 5
echo "" > sender
