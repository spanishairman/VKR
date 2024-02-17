#!/bin/bash
# Пример pg_dump со сжатием:
# sudo -u postgres pg_dump -d CACSTORE | gzip > /media/backup/dump/cacstore.sql.gz
# Мы делаем без сжатия, так как сжимать файлы будет bacula
postgreshome="/var/lib/postgresql"
cd $postgreshome
sudo -u postgres pg_dump -d CACSTORE > /media/backup/dump/cacstore.sql
sudo -u postgres pg_dump -d CALSTORE > /media/backup/dump/calstore.sql
sudo -u postgres pg_dump -d RACSTORE > /media/backup/dump/racstore.sql
sudo -u postgres pg_dump -d RALSTORE > /media/backup/dump/ralstore.sql
