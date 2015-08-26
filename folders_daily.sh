#!/bin/bash -x

## Запись в лог
logger -i -t zbackup "Backup script $0 started... "

## Каталоги и файлы к архивации через пробел, без запятых, начинающиеся с '/'
DIRS='/etc/ /root/ /home/ /opt/ /srv/ /var/log/'

## Загружаем общие переменные
source /root/zbackup/backup.conf

## Создаём точку монтирования
mkdir $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог в точку монтирования с авторизацией по ключу
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

##  Для каждой указанной директории
for DIR in $DIRS
    do  
        ## Создаём директорию на архив-сервере
        mkdir -p $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/folders$DIR 2>/dev/null

        ## Архивируем при помощи tar (без сжатия!)
        tar --one-file-system --ignore-failed-read -cf - $DIR  2>/dev/null | zbackup --silent backup $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/folders$DIR/`date '+%Y%m%d-%H-%M'`.tar
    done

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

## Запись в лог
logger -i -t zbackup "Backup script $0 completed "

