MESOS_MASTER=lxcc01
MESOS_MASTER_PORT=5050
MESOS_MASTER_IP_PORT=$(vm ip $MESOS_MASTER):$MESOS_MASTER_PORT
MESOS_SLAVE_PORT=5051

export  MESOS_MASTER \
        MESOS_MASTER_PORT \
        MESOS_MASTER_IP_PORT \
        MESOS_SLAVE_PORT

echo MESOS_MASTER_IP_PORT=$MESOS_MASTER_IP_PORT

@mesos() { 
        $BROWSER http://$MESOS_MASTER_IP_PORT 
}

@mesos-help() {
        $BROWSER http://$MESOS_MASTER_IP_PORT/help
}

@mesos-toggle-log() {
        curl "http://$MESOS_MASTER_IP_PORT/logging/toggle?level=3&duration=15mins"
}
