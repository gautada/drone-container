#!/bin/ash
#
# Launch the DroneCI application.  This launches bother

# if [ -z "$ENTRYPOINT_PARAMS" ] ; then
if [ -z "$ENTRYPOINT_PARAMS" ] ; then
 echo "---------- [ CONTINUOUS INTEGRATION(drone) ] ----------"
 TEST="$(/usr/bin/pgrep /usr/bin/podman)"
 if [ $? -eq 1 ] ; then
  echo "podman..."
  /usr/bin/podman --log-level fatal system service --time 0 &
 fi
 TEST="$(/usr/bin/pgrep drone-runner-exec)"
 if [ $? -eq 1 ] ; then
  echo "drone-runner-exec..."
  /usr/bin/drone-runner-exec daemon "/etc/drone/runner-exec.env" &
 fi
 TEST="$(/usr/bin/pgrep drone-server)"
 if [ $? -eq 1 ] ; then
  echo "drone-server..."
  /usr/bin/drone-server --env-file /etc/drone/server.env
 fi
 return 1
fi
