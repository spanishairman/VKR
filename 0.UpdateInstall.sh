#!/bin/bash
# Монтируем, если отключен установочный диск. Предварительно подключаем его в настройках ВМ
if [ `ls /media/cdrom0 | wc -l` -eq 0 ];
then mount /media/cdrom0/
fi
# Создаем каталог для монтирования образа с оперативным обновлением
mkdir /media/repo
# Задаем перкменные с путем и именами образов
basepath="/home/csadmin"
smolensk="$basepath/smolensk-1.6-20.06.2018_15.56.iso"
repo="$basepath/repository-update-bin.iso"
# Проверяем праильность имен и путей
if [ ! -d $basepath ] || [ ! -f $repo ] || [ ! -f $smolensk ]; 
then echo "Directory $basepath or file $smolensk or $repo not exist!" 
exit 2
fi
cd $basepath
# Монтируем образ с обновлениями
mount $repo /media/repo/
# Устанавливаем пакет astra-update
apt install -y /media/repo/pool/non-free/a/astra-update/astra-update_*.deb
# Отключаем диск с обновлениями
umount /media/repo
# Обновлямем систему
astra-update -A $smolensk $repo
# Создаем директорию для образа установочного диска
mkdir /media/distro
# Добавляем образы в файл fstab
echo "$smolensk /media/distro/  iso9660 loop    0       0" >> /etc/fstab
echo "$repo         /media/repo/    iso9660 loop    0       0" >> /etc/fstab
# Закрываем комментарием источник - CDROM в файле /etc/apt/sources.list
sed -i 's/^/#/' /etc/apt/sources.list
# И добавляем в качестве источников образы дисков
echo "deb file:/media/distro/ smolensk contrib main non-free" >> /etc/apt/sources.list
echo "deb file:/media/repo/ smolensk contrib main non-free" >> /etc/apt/sources.list
# Перезагружаем машину.
# reboot
