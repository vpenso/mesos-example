


```bash
# start ZooKeeper
systemctl restart zookeeper && systemctl status zookeeper
# logging configuration
/etc/zookeeper/conf/log4j.properties               
# check the state
ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh status
# start logging to console
ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh start-foreground
# check the ports
nmap 10.1.1.9-11 -p 2181,2888,3888
```

Leader election in the logs:

```
Trying to create path '/mesos' in ZooKeeper
Group process (zookeeper-group(2)@10.1.1.11:5050) connected to ZooKeeper
...
A new leading master (UPID=master@10.1.1.10:5050) is detected
The newly elected leader is master@10.1.1.10:5050 with id 9d75cf51-dc4e-4561-8e10-fa318c421136
```
