#!/bin/sh

## Выполняем с пониженным приоритетом по CPU (nice) и IO (ionice)
TIME=`/usr/bin/time -f'%E' nice -n 19 ionice -c2 -n7 /root/zbackup/folders_daily.sh 2>&1`
logger -i -t zbackup "Completion time: $TIME"

