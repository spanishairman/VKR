Astra Linux - установка и настройка ОС. Установка Центра Сертификации. 
Тестовый демонстрационный стенд.
Схема компонентов УЦ. Общая схема приведена в файле CAValidata.drawio.png. 
Удостоверяющий Центр состоит из компонентов:
 - Центр Сертификации (Сигнатура-Сертификат L) - два экземпляра;
 - Центр Регистрации (Сигнатура-Сертификат L) - два экземпляра;
 - АРМ операторов ЦС и ЦР. Дополнительная роль: Bacula-сервер - один экземпляр;
 - Web-сервер (публикация САС, Zabbix-сервер) - один экземпляр.
Роли Удостоверяющего Центра (ЦС и ЦР) продублированы, каждый экземпляр использует базы данных, размещенные на той же виртуальной машине, на которой он установлен.
Синхронизация баз данных между экземплярами происходит с помощью потоковой репликации.
Конфигурационные файлы и БД Удостоверяющего Центра бэкапятся на виртуальную машину Bacula-сервер с использованием службы резервного копирования Bacula.
На всех виртуальных машинах УЦ установлена ОС специального назначения Astra Linux 1.6 Оперативное обновление 12.
