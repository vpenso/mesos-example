
<https://mesos.readthedocs.io>

```bash
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
curl -s http://$(vm ip lxcc01):5050/state | jq
# master configuration (authentication/authorization)
curl -s http://$(vm ip lxcc01):5050/master/flags | jq
# check agent state
curl -s http://$(vm ip lxcc01):5050/master/state-summary |\
        jq '.slaves[] | {hostname,active,resources}'
```

### Tasks

Launch tasks with `mesos-execute`

```bash
# as simple as possible
mesos-execute --master=10.1.1.9:5050 \
              --name=sleep \
              --command='echo sleep... ; sleep 15'
# specify resources and the containerizer
mesos-execute --master=10.1.1.9:5050 \
              --name=sleep \
              --containerizer=mesos \
              --resources='cpus:0.1;mem:32' \
              --command='echo sleep... ; sleep 300'
```

On the following process hierarchy will be started: 

```bash
/usr/sbin/mesos-slave ...
...
  /usr/libexec/mesos/mesos-containerizer launch
    mesos-executor --launcher_dir=/usr/libexec/mesos
      sh -c echo sleep
```

```bash
mesos-execute --master=10.1.1.9:5050 \
              --name=sleep \
              --containerizer=docker \
              --docker_image=' busybox:latest' \
              --resources='cpus:0.5;mem:128' \
              --command='echo sleep... ; sleep 300'
```


### Trouble Shooting

Mesos can not connect to the Zookeeper cluster:

```bash
...ZOO_ERROR...errno=111(Connection refused): server refused to accept the client
```

Make sure the firewall is not blocking access, and IP addresses and ports a correctly configured in `/etc/master/zk`

