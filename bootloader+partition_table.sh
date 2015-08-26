#!/bin/bash

## Запись в лог
logger -i -t zbackup "Backup script $0 started... "

## Имя диска, где расположен MBR
DISK='/dev/vda'

## Сколько секторов архивировать с начала диска
## Проверить можно так:
## fdisk -l
##   Device Boot      Start         End      Blocks   Id  System
## /dev/sda1   *        2048      499711      248832   83  Linux
## /dev/sda2          501758   104855551    52176897    5  Extended
## /dev/sda5          501760   104855551    52176896   8e  Linux LVM
## Первый раздел начинается с сектора 2048, значит указывать 2048
## Если не кратно 2048, то стоит задуматься о переразбивке диска с целью
## дальнейшей совместимости с 4K-дисками и RAID:
## http://www.ibm.com/developerworks/linux/library/l-4kb-sector-disks/
SECTORS=2048

## Логический размер сектора (cat /sys/block/sdX/queue/logical_block_size)
SECTOR_SIZE=512

## Загружаем общие переменные
source /root/zbackup/backup.conf

## Создаём локальную точку монтирования
mkdir -p $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог в локальную точку монтирования
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

## Создаём каталог на архив-сервере, куда будут размещаться бэкапы
mkdir -p $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/bootloader+partition_table/{bootloader,partition_table} 2>/dev/null

## Архивируем загрузочик и таблицу разделов (без расширенных разделов)
dd if=$DISK bs=$SECTOR_SIZE count=$SECTORS 2>/dev/null | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/bootloader+partition_table/bootloader/`date '+%Y%m%d-%H-%M'`.dd.bin

## Архивируем таблицу разделов (с расширенными разделами)
sfdisk -d $DISK 2>/dev/null | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/bootloader+partition_table/partition_table/`date '+%Y%m%d-%H-%M'`.sfdisk.txt

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

## Запись в лог
logger -i -t zbackup "Backup script $0 completed "

