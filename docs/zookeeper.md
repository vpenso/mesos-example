Cf. Zookeper Administrator's Guide:

<https://zookeeper.apache.org/doc/current/>

```bash
# check if all ports  are listening
vm ex lxcc01 -r -- \
        yum install -y nmap && nmap 10.1.1.9-11 -p 2181,2888,3888
# find the leader node
NODES=lxcc0[1-3] vn ex '
        yum install -y nmap-ncat
        echo stat | nc 127.0.1.1 2181
' | grep -e ^-- -e Mode
# ..or
NODES=lxcc0[1-3] vn ex '
        ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh status
'
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

