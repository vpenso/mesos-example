


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
