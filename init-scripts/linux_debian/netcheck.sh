#!/bin/sh
#
###############################################################################
#   - NetCheck init.d Script -
#
#   Author: Joel Eriksson (joel.a.eriksson@gmail.com)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################
#
### BEGIN INIT INFO
# Provides:          netcheck
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop NetCheck
# Description:       This is the init script for NetCheck.
### END INIT INFO
 
DIR=/home/pi/netcheck
LOG_FILE=$DIR/netcheck.log
MY_IP=`hostname -I`
PORT="8081"
# Comment out below line if you don't want to enable the WEB API/UI
WEB_API_OPTS="-w $MY_IP -p $PORT"
DAEMON=$DIR/netcheck.py
DAEMON_OPTS="-l $LOG_FILE $WEB_API_OPTS"
DAEMON_NAME=netcheck
DAEMON_USER=root
PIDFILE=/var/run/$DAEMON_NAME.pid
 
. /lib/lsb/init-functions
 
do_start () {
    if [ -e $PIDFILE ]; then
     status_of_proc -p $PIDFILE "$DAEMON_NAME" "$DAEMON" && status="0" || status="$?"
     # If the status is SUCCESS then don't need to start again.
     if [ $status = "0" ]; then
      exit # Exit
     fi
    fi
    log_daemon_msg "Starting system $DAEMON_NAME daemon"
    start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile --user $DAEMON_USER --chuid $DAEMON_USER --exec $DAEMON -- $DAEMON_OPTS
    log_end_msg $?
}
do_stop () {
    log_daemon_msg "Stopping system $DAEMON_NAME daemon"
    start-stop-daemon --stop --signal INT --pidfile $PIDFILE --retry 10
    log_end_msg $?
}
 
case "$1" in
 
    start|stop)
        do_${1}
        ;;
 
    restart|reload|force-reload)
        do_stop
        do_start
        ;;
 
    status)
        status_of_proc -p $PIDFILE "$DAEMON_NAME" "$DAEMON" && exit 0 || exit $?
        ;;
    *)
        echo "Usage: /etc/init.d/$DAEMON_NAME {start|stop|restart|status}"
        exit 1
        ;;
 
esac
exit 0
