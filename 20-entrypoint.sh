#!/bin/ash
#
# Launch the DroneCI application.  This launches bother

echo "$0"
# if [ -z "$ENTRYPOINT_PARAMS" ] ; then
if [ "server" == "$ENTRYPOINT_PARAMS" ] ; then
 echo "---------- [ CONTINUOUS INTEGRATION(drone) ] ----------"
 TEST="$(/usr/bin/pgrep drone-runner-exec)"
 if [ $? -eq 1 ] ; then
  echo "drone-runner-exec..."
  /usr/bin/drone-runner-exec daemon "/opt/drone/runner-exec.env" &
 fi
 TEST="$(/usr/bin/pgrep drone-server)"
 if [ $? -eq 1 ] ; then
  echo "drone-server..."
  /usr/bin/drone-server --env-file /opt/drone/server.env
 fi
 return 1
fi
