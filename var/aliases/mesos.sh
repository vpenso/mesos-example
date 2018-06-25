MESOS_MASTER=lxcc01
MESOS_MASTER_PORT=5050
MESOS_MASTER_IP_PORT=$(vm ip $MESOS_MASTER):$MESOS_MASTER_PORT
MESOS_SLAVE_PORT=5051
MESOS_REPOSITORY=https://github.com/apache/mesos
MESOS_SOURCE=$MESOS_EXAMPLE/usr/src

export  MESOS_MASTER \
        MESOS_MASTER_PORT \
        MESOS_MASTER_IP_PORT \
        MESOS_SLAVE_PORT \
        MESOS_APACHE_REPOSITORY

#
# Open Mesos master web-interface in the default browser
#
@mesos() { 
        $BROWSER http://$MESOS_MASTER_IP_PORT 
}

# Open the Mesos REST interface documentation the default browser
@mesos-help() {
        $BROWSER http://$MESOS_MASTER_IP_PORT/help
}

#
# Enable verbose logging on the Mesos master
#
@mesos-toggle-log() {
        curl "http://$MESOS_MASTER_IP_PORT/logging/toggle?level=3&duration=15mins"
}

#
# download the Mesos source code from the Apache Github mirror
#
mesos-download-source() {
        [ -d $MESOS_SOURCE ] || mkdir -vp $MESOS_SOURCE
        git clone $MESOS_REPOSITORY $MESOS_SOURCE/
}
