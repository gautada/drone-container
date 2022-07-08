#!/bin/ash

# container-backup.fnc
#
# Calls the gitea backup function and unpacks the data
# in the /var/backup folder and delete the zip file.

container_backup() {
 /bin/su -c "/usr/bin/gitea --config /etc/gitea/app.ini --work-path /opt/gitea --custom-path /opt/gitea/custom dump" gitea
 /usr/bin/unzip gitea-dump-*.zip
 /bin/rm gitea-dump-*.zip
}
