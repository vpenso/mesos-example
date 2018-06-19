mesos_zookeeper:
  file.managed:
    - name: /etc/mesos/zk
    - contents: zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos
