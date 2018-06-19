base:
  '*':
     - chronyd
     - salt-minion
     - systemd
  lxcc0[1-3].devops.test:
     - yum-mesos
     - zookeeper
  lxb00[1-4].devops.test:
     - yum-mesos
