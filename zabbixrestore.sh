#!/bin/bash
# Restore DB from dumps
sudo -u postgres psql -d zabbix < /media/backup/dump/zabbix.sql
