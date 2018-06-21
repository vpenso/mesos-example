

## Operations

<https://mesos.readthedocs.io>

### Master

```bash
# open the web GUI in our default browser
$BROWSER http://$MESOS_MASTER_IP_PORT
# show all default configurations
tail -n+1 /etc/default/mesos*  /etc/mesos-*/*       
# start master daemon in foreground 
mesos-master --ip=$(hostname -i) \
             --work_dir=/var/lib/mesos \
             --quorum=2 \
             --zk=zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos \
             --zk_session_timeout=10secs
# tail the log continuously
journalctl -fu mesos-master
# leader election
mesos-resolve $(cat /etc/mesos/zk)
```

Status information exposed by the HTTP API

```bash
# query master state
curl -s http://$MESOS_MASTER_IP_PORT/state | jq
# master configuration (authentication/authorization)
curl -s http://$MESOS_MASTER_IP_PORT/master/flags | jq
# check agent state
curl -s http://$MESOS_MASTER_IP_PORT/master/state-summary |\
        jq '.slaves[] | {hostname,active,resources}'
```

### Agents

```
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

```bash
# check the containerizer
curl -s http://$(vm ip lxb001):$MESOS_SLAVE_PORT/state |\
        jq '.flags.containerizers'
# configure the containerizer
NODES=lxb00[1-4] vn ex '
        echo mesos,docker > /etc/mesos-slave/containerizers
        systemctl restart mesos-slave
'
```

### Tasks

Launch tasks from the **Mesos master**:

```bash
# as simple as possible
mesos-execute --master=$(hostname -i):5050 \
              --name=sleep \
              --command='echo sleep... ; sleep 15'
# specify resources and the containerizer
mesos-execute --master=$(hostname -i):5050 \
              --name=sleep \
              --containerizer=mesos \
              --resources='cpus:0.1;mem:32' \
              --command='echo sleep... ; sleep 300'
# process hierarchy on the agent node 
/usr/sbin/mesos-slave ...
...
  /usr/libexec/mesos/mesos-containerizer launch
    mesos-executor --launcher_dir=/usr/libexec/mesos
      sh -c echo sleep
```

A task with a simple docker container:

```bash
mesos-execute --master=$(hostname -i):5050 \
              --name=sleep \
              --containerizer=docker \
              --docker_image='busybox:latest' \
              --resources='cpus:0.5;mem:128' \
              --command='echo sleep... ; sleep 300'
# process hierarchy on the agent node 
/usr/sbin/mesos-slave ...
  ...
  mesos-docker-executor ...
    /usr/bin/docker-current -H unix:///var/run/docker.sock ... busybox:latest -c echo sleep... ; sleep 300
```

### Frameworks

```bash
# list frameworks
curl -s http://$MESOS_MASTER_IP_PORT/frameworks |\
        jq '.frameworks[] | {name,hostname,active}'
```

## Trouble Shooting

Mesos can not connect to the Zookeeper cluster:

```bash
...ZOO_ERROR...errno=111(Connection refused): server refused to accept the client
```

Make sure the firewall is not blocking access, and IP addresses and ports a correctly configured in `/etc/master/zk`

