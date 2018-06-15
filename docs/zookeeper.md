


```bash
# start ZooKeeper
systemctl restart zookeeper && systemctl status zookeeper
# loggin configuration
/etc/zookeeper/conf/log4j.properties               
# check the state
ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh status
# start logging to console
ZOOCFGDIR=/etc/zookeeper/conf /opt/mesosphere/zookeeper/bin/zkServer.sh start-foreground
```
