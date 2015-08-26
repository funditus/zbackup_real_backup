#!/bin/bash

## Загружаем общие переменные
source /root/zbackup/recovery/backup.conf

## Создаём точку монтирования
mkdir $LOCAL_MOUNT_POINT 2>/dev/null

## Подключаем удалённый каталог в точку монтирования с авторизацией по ключу
sshfs $ZBACKUP_USER@$SERVER_ADDRESS:$SERVER_MOUNT_POINT $LOCAL_MOUNT_POINT -p $SERVER_SSH_PORT -o idmap=user -o IdentityFile=~/.ssh/id_"$ZBACKUP_USER"_zbackup -o nonempty 2>/dev/null

FREE_MEM=$( free -m | grep 'buffers/cache' | awk '{print $4}')
## Для увеличения производительности восстановления вводим вручную количество ОЗУ для zbackup
echo "На системе свободно $FREE_MEM Мбайт ОЗУ. Введите сколько выделить для zbackup для ускорения процесса - в Мбайтах (для примера 512): "
read USE_MEM
echo "Используется $USE_MEM Мбайт для zbackup…"

## Выводим список файлов для восстановления
ls -lR $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/folders/
## Вручную вводим нужный файл
echo 'Введите имя файла для восстановления (в формате var/20130823-18-00.tar)… '
read FILE

## Создаём папку для восстановления
mkdir -p $(echo "$FILE" | awk -F/ '{print $1}')
zbackup --cache-size "$USE_MEM"mb restore $LOCAL_MOUNT_POINT/zbackup/backups/$ZBACKUP_USER/folders/$FILE > $FILE

## Отмонтируем удалённый каталог
fusermount -u $LOCAL_MOUNT_POINT

