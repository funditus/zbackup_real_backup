#!/bin/sh

## Выполняем с пониженным приоритетом по CPU (nice) и IO (ionice)
TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/bootloader+partition_table.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/lvm_metadata.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/partition_boot.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/folders_weekly.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/lvm_lv_root.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

