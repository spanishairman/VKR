#!/bin/bash
# Пример pg_dump со сжатием:
# sudo -u postgres pg_dump -d CACSTORE | gzip > /media/backup/dump/cacstore.sql.gz
# Мы делаем без сжатия, так как сжимать файлы будет bacula
postgreshome="/var/lib/postgresql"
cd $postgreshome
sudo -u postgres pg_dump -d zabbix > /media/backup/dump/zabbix.sql
