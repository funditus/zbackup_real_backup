#!/bin/bash

## Запись в лог
logger -i -t zbackup "Backup script $0 started... "

## Имя раздела, который будет отмонтирован и скопирован
PARTITION='/dev/vda1'

NICE_NAME=$(echo $PARTITION | awk -F/ '{print $3}')

## Загружаем общие переменные
source /root/zbackup/backup.conf

## Создаём локальную точку монтирования
mkdir -p $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог в локальную точку монтирования
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

## Создаём каталог на архив-сервере, куда будут размещаться бэкапы
mkdir -p $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/partition/$NICE_NAME 2>/dev/null

## Отмонтируем раздел
umount $PARTITION

## Архивируем
dd if=$PARTITION bs=10M conv=noerror 2>/dev/null | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/partition/$NICE_NAME/`date '+%Y%m%d-%H-%M'`.dd.bin

## Монтируем раздел обратно
mount $PARTITION

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

## Запись в лог
logger -i -t zbackup "Backup script $0 completed "

