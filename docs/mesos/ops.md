
# Mesos Master

<https://mesos.readthedocs.io>

```bash
# open the web GUI in our default browser
$BROWSER http://$MESOS_MASTER_IP_PORT
# help pages for the REAT endpoints
$BROWSER http://$MESOS_MASTER_IP_PORT/help
# start master daemon in foreground 
vm ex lxcc01 -r '
        systemctl stop mesos-master
        mesos-master --ip=$(hostname -i) \
                     --work_dir=/var/lib/mesos \
                     --quorum=2 \
                     --zk=zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos \
                     --zk_session_timeout=10secs
'
# force leader election
vm ex lxcc01 -r 'mesos-resolve $(cat /etc/mesos/zk)'
```

Open the logger application from the home-page in the left column under "Mater Log: Download | View"

```bash
# increase the verbosity of the log output for a given duration
curl "http://$MESOS_MASTER_IP_PORT/logging/toggle?level=3&duration=15mins"
```

Status information exposed by the HTTP API

```bash
# query master state
curl -s http://$MESOS_MASTER_IP_PORT/state | jq
# master configuration (authentication/authorization)
curl -s http://$MESOS_MASTER_IP_PORT/master/flags | jq
```

### Agents

```bash
# check agent state
curl -s http://$MESOS_MASTER_IP_PORT/master/state-summary |\
        jq '.slaves[] | {hostname,active,resources}'
# check if the slave have registered with the master
>>> NODES=lxb00[1-4] vn ex 'journalctl -u mesos-slave | grep -i registered'
-- lxb001 --
...Registered with master master@10.1.1.9:5050; given agent ID...
-- lxb002 --
...Registered with master master@10.1.1.9:5050; given agent ID...
-- lxb003 --
...Registered with master master@10.1.1.9:5050; given agent ID...
-- lxb004 --
...Registered with master master@10.1.1.9:5050; given agent ID...
```
