#!/bin/bash
# Run as csadmin
eval "$(ssh-agent -s)"
ssh-add
# rsync -e ssh --archive --progress max@192.168.122.1:/home/max/repo/ /home/csadmin/
rsync -e ssh --archive --recursive --progress --exclude '1.CopyFiles.sh' max@192.168.122.1:/home/max/repo/ /home/csadmin/
# chmod u+x 1.CopyFiles.sh
chmod u+x 3.InstallSoft.sh
chmod u+x 4.InstallZabbix.sh
