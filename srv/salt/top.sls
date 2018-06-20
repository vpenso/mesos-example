base:
  '*':
     - chronyd
     - salt-minion
     - systemd
  lxcc0[1-3].devops.test:
     - yum-mesos
     - zookeeper
     - mesos-zookeeper
     - mesos-firewall
     - mesos-master
  lxb00[1-4].devops.test:
     - yum-mesos
     - mesos-zookeeper
     - mesos-firewall
     - mesos-slave
