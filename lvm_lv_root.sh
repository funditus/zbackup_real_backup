#!/bin/bash

## Запись в лог
logger -i -t zbackup "Backup script $0 started... "

## Название группы разделов (VG)
VG='alma-home-x'

## Имя логического раздела (LV) для резервирования
LV='root'

## Место для снэпшота (к примеру 500M, 5G). Оно должно быть доступно в VG! Его можно проверить командой vgs (VFree).
SNAPSHOT_SIZE=5G

## Загружаем общие переменные
source /root/zbackup/backup.conf

## Создаём локальную точку монтирования
mkdir -p $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог архив-сервера в локальную точку монтирования
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

## Создаём каталог для архивации LVM в удалённом каталоге
mkdir -p $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/lvm/$VG/$LV 2>/dev/null

## Здесь можно внести необходимые команды по сбросу кэша ОС или БД на диск
sync; sleep 2

## Создаём снэпшот раздела
lvcreate -L $SNAPSHOT_SIZE -s -n "$LV"_snapshot /dev/$VG/$LV 1>/dev/null

## Архивируем из снэпшота в бинарном виде на архив-сервер
dd if=/dev/$VG/"$LV"_snapshot bs=10M conv=noerror 2>/dev/null | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/lvm/$VG/$LV/`date '+%Y%m%d-%H-%M'`.dd.bin

## Удаляем снэпшот
lvremove -f /dev/$VG/"$LV"_snapshot 1>/dev/null

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

## Запись в лог
logger -i -t zbackup "Backup script $0 completed "

