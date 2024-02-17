#!/bin/bash
# Обновим информацию о пакетах в репозиториях
apt update
# Вносим имена серверов и их ip-адреса в файл hosts
# Здесь символы "||" - логическое "ИЛИ". Логическое "И" - "&&".
grep "ucdccamaster" /etc/hosts || echo "192.168.122.11 ucdccamaster" >> /etc/hosts
grep "ucdccaslave" /etc/hosts || echo "192.168.122.12 ucdccaslave" >> /etc/hosts
grep "ucdcweb" /etc/hosts || echo "192.168.122.13 ucdcweb" >> /etc/hosts
grep "ucdcarm" /etc/hosts || echo "192.168.122.14 ucdcarm" >> /etc/hosts
basepath="/home/csadmin"
odbcinst="odbcinst.ini"
# В зависимости от имени хоста, задаем переменной odbcini имя файла с нужными параметрами подключения к БД
if [ $HOSTNAME = "ucdccamaster" ];
    then odbcini="odbc.ini"
    else if [ $HOSTNAME = "ucdccaslave" ];
        then odbcini="odbc2.ini"
    fi
fi
echo "Hostname is $HOSTNAME, use $odbcini"
sleep 5
postgresconf="postgresql.conf"
postgreshome="/var/lib/postgresql"
jakarta="jcPKCS11-2_2.4.0.2946_amd64.deb"
spki="spki-6.0.464.0-0.amd64.deb"
ssdk="ssdk-6.0.464.0-0.amd64.deb"
scara="scara-6.0.464.0-0.amd64.deb"
cd $basepath
if [ ! -f $odbcinst ] || [ ! -f $odbcini ] || [ ! -f $postgresconf ] || [ ! -f $jakarta ] || [ ! -f $spki ] || [ ! -f $ssdk ] || [ ! -f $scara ];
then echo "One or more files not exist! Check it!" 
exit 2
fi
# Создаем системного пользователя replica_user, добавляем его в группу postgres 
# Так же добавим в группу postgres пользователей csadmin и replica_user
# Дадим права на чтение атрибутов мандатного разграничения доступа (Mandatory Access Control, MAC).
# Ключ --system создает системного пользователя. Новый системный пользователь имеет оболочку /bin/false и заблокированный пароль.
# Ключ --group создает одноименную группу. По умолчанию, системные пользователи помещаются в группу nogroup.
# Начальные файлы настроек не копируются.
adduser --system --group replica_user
usermod -a -G postgres csadmin
usermod -a -G postgres replica_user
# Предоставим пользователю СУБД (и, следовательно, ОС) права на чтение 
# атрибутов мандатного разграничения доступа (Mandatory Access Control, MAC).
pdpl-user -l 0:0 csadmin
pdpl-user -l 0:0 replica_user
# Проверяем, установлена ли Windows CodePage 1251 (кодировка ru_RU.cp1251). Если нет, то устанавливаем.
# Здесь символы "||" - логическое "ИЛИ". Логическое "И" - "&&".
locale -a | grep "ru_RU.cp1251" || localedef -c -i ru_RU -f CP1251 ru_RU.cp1251
# если отсутствует, то копируем файл odbinst.ini
[ ! -f /etc/$odbcinst ] && cp $basepath/$odbcinst /etc/
# Перезапускаем Postgresql для того, чтобы применилась новая локаль
systemctl restart postgresql
# -----------------------------------
echo "Настройки для Bacula File Daemon"
# -----------------------------------
sleep 3
# Создаем директории для резервного копирования баз данных и журналов
mkdir -p /media/backup/{base,dump,validata,wal}
cp $basepath/cararestore.sh /media/backup/dump
chown -R postgres:postgres /media/backup/{base,dump,wal}
chown -R csadmin:csadmin /media/backup/validata
chmod 760 /media/backup/{base,dump,validata,wal}
chmod u+x /media/backup/dump/cararestore.sh
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
cp $basepath/bacula-*.sh /etc/bacula/scripts/
chown bacula:bacula /etc/bacula/scripts/bacula-{before,after}-{base,dump,validata}.sh
chmod u+x /etc/bacula/scripts/bacula-{before,after}-{base,dump,validata}.sh
# -----------------------------------
echo "Устанавливаем все необходимые для работы пакеты"
# -----------------------------------
sleep 3
apt install -y libpq5 odbc-postgresql libccid pcscd libpcsclite1 opensc libsasl2-modules-gssapi-mit libcurl3
# Устанавливаем заранее скачанные пакеты
# jcPKCS11-2_2.4.0.2946_amd64.deb - драйвер JaCarta
# spki-6.0.464.0-0.amd64.deb - справочник сертификатов
# ssdk-6.0.464.0-0.amd64.deb - средства разработки
# scara-6.0.464.0-0.amd64.deb - Сервис ЦС/ЦР
dpkg -i jcPKCS11-2_2.4.0.2946_amd64.deb spki-6.0.464.0-0.amd64.deb ssdk-6.0.464.0-0.amd64.deb scara-6.0.464.0-0.amd64.deb
# -----------------------------------
echo "Настраиваем Сигнатура-Сертификат L"
# -----------------------------------
# Копируем данные из файла odbc.ini или odbc2.ini в зависимости от роли сервера
cp /opt/Validata/VDCSP/etc/odbc.ini $basepath/.odbc.ini
cat $basepath/$odbcini >> $basepath/.odbc.ini
chown csadmin:csadmin $basepath/.odbc.ini
# Создаём рабочий каталог .Validata, копируем в него файл настроек по умолчанию
mkdir -p $basepath/.Validata/{armca,armra}/log
mkdir -p $basepath/.Validata/{ca,ra}/{crl,log,upd}
cp /opt/Validata/VDCSP/etc/spki.ini $basepath/.Validata/
# Редактируем строки для подключения к БД
# Здесь параметр /p выводит на терминал содержимое файла в котором производится замена.
# Параметр -n позволяет вывести только те строки, в которых нашлось вхождение в шаблон поиска.
sed -i 's\#PkiODBCUsername = UserName\PkiODBCUsername = csadmin\' $basepath/.Validata/spki.ini
sed -i 's\#PkiODBCPassword = PassWord\PkiODBCPassword = *******\' $basepath/.Validata/spki.ini
chown -R csadmin:csadmin $basepath/.Validata
# -----------------------------------
echo "Настраиваем СУБД"
# -----------------------------------
sleep 3
echo 'local   replication     postgres                                peer' >> /etc/postgresql/9.6/main/pg_hba.conf
# Далее блок для сервера Master
if [ $HOSTNAME = "ucdccamaster" ];
    then
    # Создаём базы и пользователя с правами на них
    cd $postgreshome
    sudo -u postgres psql -c 'CREATE DATABASE "CACSTORE" WITH ENCODING="WIN1251" LC_COLLATE="ru_RU.cp1251" LC_CTYPE="ru_RU.cp1251" CONNECTION LIMIT=-1 TEMPLATE template0;'
    sudo -u postgres psql -c 'CREATE DATABASE "CALSTORE" WITH ENCODING="WIN1251" LC_COLLATE="ru_RU.cp1251" LC_CTYPE="ru_RU.cp1251" CONNECTION LIMIT=-1 TEMPLATE template0;'
    sudo -u postgres psql -c 'CREATE DATABASE "RACSTORE" WITH ENCODING="WIN1251" LC_COLLATE="ru_RU.cp1251" LC_CTYPE="ru_RU.cp1251" CONNECTION LIMIT=-1 TEMPLATE template0;'
    sudo -u postgres psql -c 'CREATE DATABASE "RALSTORE" WITH ENCODING="WIN1251" LC_COLLATE="ru_RU.cp1251" LC_CTYPE="ru_RU.cp1251" CONNECTION LIMIT=-1 TEMPLATE template0;'
    sudo -u postgres psql -c "CREATE USER csadmin WITH PASSWORD '*******';"
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE "CACSTORE" TO csadmin;'
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE "CALSTORE" TO csadmin;'
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE "RACSTORE" TO csadmin;'
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE "RALSTORE" TO csadmin;'
    sudo -u postgres psql -c "CREATE ROLE replica_user WITH REPLICATION LOGIN PASSWORD '*******';"
    cd $basepath
    # Даем права на подключение пользователю replica_user с хоста ucdccaslave
    echo 'host     replication     replica_user    192.168.122.12/32       md5' >> /etc/postgresql/9.6/main/pg_hba.conf
    # Копируем файл postgresql.conf
    if [ ! -f /etc/postgresql/9.6/main/postgresql.conf.default ];
        then cp -p /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.default
    fi
    cp $postgresconf /etc/postgresql/9.6/main/
    systemctl restart postgresql
    # Далее блок для сервера Slave
    else if [ $HOSTNAME = "ucdccaslave" ];
        then systemctl stop postgresql
            if [ ! -f /etc/postgresql/9.6/main/postgresql.conf.default ];
                then cp -p /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.default
            fi
        cp $basepath/$postgresconf /etc/postgresql/9.6/main/
        echo 'host     replication     replica_user    192.168.122.11/32       md5' >> /etc/postgresql/9.6/main/pg_hba.conf
        cd /var/lib/postgresql/9.6/
        # Создаем резервную копию каталога сервера БД
        tar cf - main | 7za a -si main.tar.7z
        # Удаляем рабочий каталог
        rm -rf main
        # Если понадобится восстановить данные каталога main, то необходимо выполнить команду:
        # 7za x -so main.tar.7z | tar xf -
        # Теперь запустим утилиту pg_basebackup, чтобы скопировать данные с основного узла на узел реплики.
        pg_basebackup -h ucdccamaster -U replica_user -W -X stream -R -P -D /var/lib/postgresql/9.6/main/
        # Перевод принимающего (Replica) сервера в режим записи: 
        # pg_ctl promote -D /var/lib/postgresql/9.6/main
        # Поменяем владельца рабочего каталога PostgreSQL и запустим службу.
        # Добавил sleep, так как после репликации postgresql долго стартует.
        sleep 60
        chown -R postgres:postgres main
        systemctl start postgresql
    fi
fi
