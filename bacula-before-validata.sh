#!/bin/bash
# Создаем архив каталога ~/.Validata
# Для просмотра содержимого архива используйте tar -tf arch.tar
# Для извлечения файлов из архива используйте tar -xf arch.tar
# Для извлечения определенных файлов из архива используйте tar -xf arch.tar file1 file2 ..
cd /media/backup/validata
arch="validata.tar"
if [ ! -f $arch ];
    then tar -cvf $arch /home/csadmin/.Validata/
    else if [ -f $arch ];
        then tar -uvf $arch /home/csadmin/.Validata/
    fi
fi
