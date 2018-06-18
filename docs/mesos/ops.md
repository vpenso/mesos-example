
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


### Trouble Shooting

```bash
...ZOO_ERROR...errno=111(Connection refused): server refused to accept the client
```

Make sure the firewall is not blocking access, and IP addresses and ports a correctly configured in `/etc/master/zk`

