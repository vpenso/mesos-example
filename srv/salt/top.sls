base:
  '*':
     - chronyd
     - salt-minion
     - systemd
  lxcc0[1-3].devops.test:
     - yum-mesos
     - zookeeper
     - mesos-zookeeper
     - mesos-master
  lxb00[1-4].devops.test:
     - yum-mesos
     - docker
     - mesos-zookeeper
     - mesos-slave
