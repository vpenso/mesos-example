
This example uses virtual machines setup with vm-tools:

<https://github.com/vpenso/vm-tools>

## Single Node

```bash
# start a CentOS 7 VM instance
vm s centos7 lxdev01
# login and configure manually 
vm lo lxdev01 -r
# open Mesos web GUI 
$BROWSER http://$(vm ip lxdev01):5050
# open Marathon web GUI
$BROWSER http://$(vm ip lxdev01):8080
# open Chronos web GUI
$BROWSER http://$(vm ip lxdev01):4400
```

Configuration in the VM instance:

```bash
## -- CentOS --##
# Add the repository
rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm
# install packages
yum -y install --enablerepo=mesosphere mesos docker mesosphere-zookeeper marathon chronos
# use Docker as containerizer
echo 'docker,mesos' > /etc/mesos-slave/containerizers
# configure Marathon
cat << EOF > /etc/default/marathon
MARATHON_MASTER=zk://127.0.0.1:2181/mesos
MARATHON_ZK=zk://127.0.0.1:2181/marathon
EOF
# start all services
for SERVICES in docker zookeeper mesos-master mesos-slave marathon chronos; do
    systemctl enable --now $SERVICES
done
# firewall configuration
firewall-cmd --permanent --zone=public --add-port=5050/tcp # mesos-master
firewall-cmd --permanent --zone=public --add-port=5051/tcp # mesos-slave
firewall-cmd --permanent --zone=public --add-port=8080/tcp # marathon
firewall-cmd --permanent --zone=public --add-port=4400/tcp # chronos
firewall-cmd --reload
```

## Small Cluster

Provision all required virtual machine instances with vm-tools:

```bash
# list the VM instances
>>> NODES
lxcc0[1-3],lxb00[1-4]
# start new VM instances using `centos7` as source image
>>> vn s centos7
# clean up everything to start from scratch
>>> vn r
```

### Deployment

Install required packages on all nodes

```bash
# configure the Mesosphere package repository on all nodes
vn ex 'rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm'
# install the master nodes
NODES=lxcc0[1-3] vn ex 'yum -y install --enablerepo=mesosphere mesos mesosphere-zookeeper marathon'
# install the slave nodes
NODES=lxb00[1-4] vn ex 'yum -y install --enablerepo=mesosphere mesos docker'
```

### Configuration

Configure ZooKeeper on the cluster:

```bash
# configure the node IDs
for i in 1 2 3 ; do NODES=lxcc0$i vn ex "echo $i > /etc/zookeeper/conf/myid"; done
# main configure file
NODES=lxcc0[1-3] vn ex 'echo -n "server.1=10.1.1.9:2888:3888\nserver.2=10.1.1.10:2888:3888\nserver.3=10.1.1.11:2888:3888\n" > /etc/zookeeper/conf/zoo.cfg'
# configure the Zookeeper end-points for all Mesos nodes
vn ex 'echo "zk://10.1.1.9:2128,10.1.1.10:2128,10.1.1.11:2128/mesos" > /etc/mesos/zsk'
```

Configure the Mesos masters:

```bash
# configure the Mesos quorum
NODES=lxcc0[1-3] vn ex 'cat /etc/mesos-master/quorum'
# configure the Mesos master IPs and hostnames
vm ex lxcc01 -r 'echo 10.1.1.9 > /etc/mesos-master/ip'
vm ex lxcc02 -r 'echo 10.1.1.10 > /etc/mesos-master/ip'
vm ex lxcc03 -r 'echo 10.1.1.11 > /etc/mesos-master/ip'
NODES=lxcc0[1-3] vn ex 'cp /etc/mesos-master/ip /etc/mesos-master/hostname'
# configure Marathon
NODES=lxcc0[1-3] vn ex '
  mkdir -p /etc/marathon/conf
  cp /etc/mesos-master/hostname /etc/marathon/conf
  cp /etc/mesos/zk /etc/marathon/conf/master
'
NODES=lxcc0[1-3] vn ex 'echo "zk://10.1.1.9:2128,10.1.1.10:2128,10.1.1.11:2128/marathon" > /etc/marathon/conf/zk'
```
