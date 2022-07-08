#!/bin/ash

# container-backup.fnc
#
# Backup function executed as root in the /tmp/backup working folder

container_backup() {
 /usr/bin/sqlite3 /opt/drone/core.sqlite ".backup 'drone_core_backup.sq3'"
}
