#!/bin/bash
postgreshome="/var/lib/postgresql"
DATE=`date +"%b %d %T"`
cd $postgreshome
sudo -u postgres /usr/bin/pg_basebackup -D /media/backup/base -F t -w -c fast -l "pg_basebackup ${DATE}"
