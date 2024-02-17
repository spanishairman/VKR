#!/bin/bash
# Restore DB from dumps
sudo -u postgres psql -d CACSTORE < /media/backup/dump/cacstore.sql
sudo -u postgres psql -d CALSTORE < /media/backup/dump/calstore.sql
sudo -u postgres psql -d RACSTORE < /media/backup/dump/racstore.sql
sudo -u postgres psql -d RALSTORE < /media/backup/dump/ralstore.sql
