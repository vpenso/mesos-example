# Zookeeper

Cf. Zookeper Administrator's Guide:

<https://zookeeper.apache.org/doc/current/>

Check the Zookeeper cluster state and leader election:

```bash
# check if all ports  are listening
vm ex lxcc01 -r -- \
        yum install -y nmap && nmap 10.1.1.9-11 -p 2181,2888,3888
# find the leader node
NODES=lxcc0[1-3] vn ex '
        ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh status
'
# ..or
NODES=lxcc0[1-3] vn ex '
        yum install -y nmap-ncat
        echo stat | nc 127.0.1.1 2181
' | grep -e ^-- -e Mode
# start a zookeeper daemon in foreground (logging to console)
vm ex lxcc01 -r '
        systemctl stop zookeeper
        ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh start-foreground
'
```

Leader election in the logs:
```bash
>>> NODES=lxcc0[1-3] vn ex 'journalctl -u zookeeper | grep -iE "(lead|follow)ing.*election"'
-- lxcc01 --
...INFO  [QuorumPeer[myid=1]/0.0.0.0:2181:Follower@63] - FOLLOWING - LEADER ELECTION TOOK - 356723
-- lxcc02 --
...INFO  [QuorumPeer[myid=2]/0.0.0.0:2181:Follower@63] - FOLLOWING - LEADER ELECTION TOOK - 174
-- lxcc03 --
...INFO  [QuorumPeer[myid=3]/0.0.0.0:2181:Leader@358] - LEADING - LEADER ELECTION TOOK - 316
```

Zookeeper CLI:

```bash
>>> vm ex lxcc01 -r /opt/mesosphere/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 1] ls /mesos                       
[json.info_0000000003, json.info_0000000001, json.info_0000000002, log_replicas]
[zk: localhost:2181(CONNECTED) 2] get /mesos/json.info_0000000001
{"address":{"hostname":"10.1.1.9","ip":"10.1.1.9","port":5050},"capabilities":[{"type":"AGENT_UPDATE"}],"hostname":"10.1.1.9","id":"96e29ec4-9c04-4ed7-b72e-9016a64f4903","ip":151060746,"pid":"master@10.1.1.9:5050","port":5050,"version":"1.6.0"}
...
```

