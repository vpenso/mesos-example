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
### Configuration

Configure Mesos on all nodes:

```bash
# add mesosphere RPM repo, disable IPv6 and security
vn ex '
        rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        systemctl disable --now firewalld
        setenforce 0 && sestatus
'
# configure the master nodes
NODES=lxcc0[1-3] vn ex '
        yum -y install -q --enablerepo=mesosphere mesos mesosphere-zookeeper marathon
        systemctl disable --now mesos-slave
        echo 2 > /etc/mesos-master/quorum
        hostname -i > /etc/mesos-master/ip
        cp /etc/mesos-master/ip /etc/mesos-master/hostname
'
# configure the slave nodes
NODES=lxb00[1-4] vn ex '
        yum -y install -q --enablerepo=mesosphere mesos docker
        systemctl disable --now mesos-master
        hostname -i > /etc/mesos-slave/ip
        cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
        #echo docker,mesos > /etc/mesos-slave/containerizers
'
```

Configure ZooKeeper on the cluster:

```bash
# configure the master nodes
for i in 1 2 3
do 
        NODES=lxcc0$i vn ex "
                echo $i > /var/lib/zookeeper/myid
                echo server.1=10.1.1.9:2888:3888 >> /etc/zookeeper/conf/zoo.cfg 
                echo server.2=10.1.1.10:2888:3888 >> /etc/zookeeper/conf/zoo.cfg
                echo server.3=10.1.1.11:2888:3888 >> /etc/zookeeper/conf/zoo.cfg
        "
done
# configure the Zookeeper end-points for all Mesos nodes
vn ex 'echo "zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos" > /etc/mesos/zk'
```


Configure Marathon:

```bash
NODES=lxcc0[1-3] vn ex '
        mkdir -p /etc/marathon/conf
        cp /etc/mesos-master/hostname /etc/marathon/conf
        cp /etc/mesos/zk /etc/marathon/conf/master
        echo -e "MARATHON_MASTER=zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos" > /etc/default/marathon
        echo -e "MARATHON_ZK=zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/marathon" >> /etc/default/marathon
'
```

### Operations

```bash
# enable and start required services on the mastes
NODES=lxcc0[1-3] vn ex '
        tail -n+1 /etc/mesos-master/{quorum,ip,hostname} \
                  /etc/mesos/zk \
                  /var/lib/zookeeper/myid \
                  /etc/marathon/conf/{hostname,master} \
                  /etc/default/marathon
        grep server /etc/zookeeper/conf/zoo.cfg /dev/null
        systemctl enable --now zookeeper mesos-master marathon
        systemctl status zookeeper mesos-master marathon
'
# enable and start required serices on the slaves
NODES=lxb00[1-4] vn ex '
        tail -n+1 /etc/mesos-slave/{ip,hostname,containerizers}\
                  /etc/mesos/zk
        systemctl enable --now docker mesos-slave
        systemctl status docker mesos-slave
'
```

### Usage

```bash
# web GUis
$BROWSER http://$(vm ip lxcc01):5050
$BROWSER http://$(vm ip lxcc01):8080
# environment
export MARATHON_URL=http://$(vm ip lxcc01):8080
# start an example application
curl -s $MARATHON_URL/v2/apps \
     -X POST \
     -H "Content-type: application/json" \
     -d @$MESOS_EXAMPLE/var/marathon/apps/docker-http-server.json
```