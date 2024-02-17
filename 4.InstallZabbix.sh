#!/bin/bash
basepath="/home/csadmin"
postgresconf="postgresql.conf"
postgreshome="/var/lib/postgresql"
basepath="/home/csadmin"
sed -i 's\zero_if_notfound: no\zero_if_notfound: yes\' /etc/parsec/mswitch.conf
apt install -y zabbix-server-pgsql zabbix-frontend-php php-pgsql
sed -i 's\;date.timezone =\date.timezone = Europe/Moscow\' /etc/php/7.0/apache2/php.ini
sed -i 's\# AstraMode on\AstraMode off\' /etc/apache2/apache2.conf
systemctl reload apache2
echo "host zabbix zabbix 127.0.0.1/32 trust" >> /etc/postgresql/9.6/main/pg_hba.conf
systemctl restart postgresql
cd $postgreshome
sudo -u postgres psql -c 'CREATE DATABASE zabbix;'
sudo -u postgres psql -c "CREATE USER zabbix WITH ENCRYPTED PASSWORD '********';"
sudo -u postgres psql -c 'GRANT ALL ON DATABASE zabbix to zabbix;'
zcat /usr/share/zabbix-server-pgsql/{schema,images,data}.sql.gz | psql -h localhost zabbix zabbix
# В случае получения ошибки psql: СБОЙ: error obtaining MAC configuration for user "zabbix", выполнить:
# usermod -a -G shadow postgres
# setfacl -d -m u:postgres:r /etc/parsec/macdb
# setfacl -R -m u:postgres:r /etc/parsec/macdb
# setfacl -m u:postgres:rx /etc/parsec/macdb
# setfacl -d -m u:postgres:r /etc/parsec/capdb
# setfacl -R -m u:postgres:r /etc/parsec/capdb
# setfacl -m u:postgres:rx /etc/parsec/capdb
# pdpl-user -l 0:0 zabbix
a2enconf zabbix-frontend-php
systemctl reload apache2
cd $basepath
# Копирование файлов из примеров, входящих в установочный пакет:
# cp /usr/share/zabbix/conf/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php
# или cp /usr/share/doc/zabbix-frontend-php/examples/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php
cp /home/csadmin/zabbix.conf.php /etc/zabbix/
cp /home/csadmin/zabbix_server.conf /etc/zabbix/
chown www-data:www-data /etc/zabbix/zabbix.conf.php
systemctl enable zabbix-server
systemctl start zabbix-server
# Создаем директории для резервного копирования баз данных и журналов
mkdir -p /media/backup/{base,dump,wal}
cp $basepath/zabbixrestore.sh /media/backup/dump
chown -R postgres:postgres /media/backup/{base,dump,wal}
chmod 760 /media/backup/{base,dump,wal}
chmod u+x /media/backup/dump/zabbixrestore.sh
# Создаем скрипты для резервного копирования
# Параметры для pg_basebackup:
# -F t tar-format
# -z Enables gzip compression of tar file output, with the default compression level
# -U User name to connect as
# -w Never issue a password prompt.
# -c fast Sets checkpoint mode to fast (immediate) or spread (default)
# -l Sets the label for the backup. If none is specified, a default value of “pg_basebackup base backup” will be used.
# Пример:
# /usr/bin/pg_basebackup -D /media/backup/base -F t -z -U bacula -w -c fast -l "pg_basebackup ${DATE}"
cp $basepath/zabbix-{before,after}-{base,dump}.sh /etc/bacula/scripts/
chown bacula:bacula /etc/bacula/scripts/zabbix-{before,after}-{base,dump}.sh
chmod u+x /etc/bacula/scripts/zabbix-{before,after}-{base,dump}.sh
#
# Копируем файл postgresql.conf
if [ ! -f /etc/postgresql/9.6/main/postgresql.conf.default ];
    then cp -p /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.default
fi
cp $basepath/$postgresconf /etc/postgresql/9.6/main/
systemctl restart postgresql
