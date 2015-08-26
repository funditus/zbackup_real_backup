#!/bin/bash

## Запись в лог
logger -i -t zbackup "Backup script $0 started... "

## Название группы разделов (VG)
VG='alma-home-x'

## Загружаем общие переменные
source /root/zbackup/backup.conf

## Создаём локальную точку монтирования
mkdir -p $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог архив-сервера в локальную точку монтирования
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

## Создаём каталог для архивации LVM в удалённом каталоге
mkdir -p $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/lvm/$VG/$LV 2>/dev/null

## Создаём бэкап метаданных LVM. Это нужно для восстановления из архива метаданных PV, VG и LV.
vgcfgbackup -f $VG.vgcfgbackup.temp $VG 1>/dev/null

## Архивируем в текстовом виде
cat $VG.vgcfgbackup.temp | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/lvm/$VG/`date '+%Y%m%d-%H-%M'`.vgcfgbackup.txt

## Удаляем временный файл
rm $VG.vgcfgbackup.temp

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

## Запись в лог
logger -i -t zbackup "Backup script $0 completed "

