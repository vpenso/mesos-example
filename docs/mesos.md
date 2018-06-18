

```bash
# show all default configurations
tail -n+1 /etc/default/mesos*  /etc/mesos-*/*       
# start master daemon in foreground 
mesos-master --ip=$(hostname -i) \
             --work_dir=/var/lib/mesos \
             --quorum=2 \
             --zk=zk://10.1.1.9:2128,10.1.1.10:2128,10.1.1.11:2128/mesos \
             --zk_session_timeout=10secs
# tail the log continuously
journalctl -fu mesos-master
```

```bash
:ZOO_ERROR@handle_socket_error_msg@1758: Socket [10.1.1.9:2128] zk retcode=-4, errno=111(Connection refused): server refused to accept the client
```

