This example uses virtual machines setup with **vm-tools**:

<https://github.com/vpenso/vm-tools>

The shell script [source_me.sh](source_me.sh) adds the tool-chain in this repository to your shell environment:

Provision all required virtual machine instances with vm-tools:

```bash
# start new VM instances using `centos7` as source image
>>> vn s centos7
# clean up everything to start from scratch
>>> vn r
```

List of required virtual machines and services:

Nodes            | Description
-----------------|---------------------
lxcm01           | SaltStack master
lxcc0[1-3]       | Zookeeper & Mesos Scheduler
lxb00[1-4]       | Mesos Agents & Docker

# Manual Install

Manual installation of a Mesos CLuster.

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




# SaltStack Install

Use SaltStack to deploy the Mesos Cluster.

### Prerequisites

Include the [SaltStack package repository][spr] to the **CentOS** virtual machine image:

[spr]: https://docs.saltstack.com/en/latest/topics/installation/rhel.html

```bash
>>> cat /etc/yum.repos.d/salt.repo
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux $releasever
baseurl=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/base/RPM-GPG-KEY-CentOS-7
```

### Deployment

Install Saltstack on all nodes (cf. [Salt configuration](https://docs.saltstack.com/en/latest/ref/configuration/index.html)):

```bash
# install the SaltStack master
vm ex lxcm01 -r '
        yum install -y salt-master;
        firewall-cmd --permanent --zone=public --add-port=4505-4506/tcp;
        firewall-cmd --reload;
        systemctl enable --now salt-master && systemctl status salt-master
'
# install the SaltStack minions on all nodes
vn ex '
        yum install -y salt-minion;
        echo "master: 10.1.1.7" > /etc/salt/minion;
        systemctl enable --now salt-minion && systemctl status salt-minion
'
```

## Configuration

Sync the Salt configuration to the master:

* [srv/salt/](srv/salt/) - The **state tree** includes all SLS (SaLt State file) representing the state in which all nodes should be
* [etc/salt/master](etc/salt/master) - Salt master configuration (`file_roots` defines to location of the state tree)
* [srv/salt/top.sls](srv/salt/top.sls) - Maps nodes to SLS configuration files (cf. [top file](https://docs.saltstack.com/en/latest/ref/states/top.html))

```bash
# upload the salt-master service configuration files
vm sy lxcm01 -r $MESOS_EXAMPLE/etc/salt/master :/etc/salt/
# upload the salt configuration reposiotry
vm sy lxcm01 -r $MESOS_EXAMPLE/srv/salt :/srv/
# accept all Salt minions
vm ex lxcm01 -r 'systemctl restart salt-master ; salt-key -A -y'
```

### Zookeeper

Node       | SLS                  | Description
-----------|----------------------|-----------------------
lxcc0[1-3] | [zookeeper.sls][5]   | Zookeeper cluster configuration


```bash
# configure zookeeper on the nodes
vm ex lxcm01 -r 'salt lxcc*.devops.test state.apply zookeeper'
# check if it is running
vm ex lxcm01 -r 'salt lxcc*.devops.test service.status zookeeper'
```

### Mesos


Node       | SLS                     | Description
-----------|--------------------------|-----------------------
lxcc0[1-3] | [mesos-master.sls][6]    | Master configuration
~          | [mesos-zookeeper.sls][7] | Connection to Zookeeper
lxb00[1-4] | [mesos-slave.sls][8]    | Slave configuration

```bash
# configure masters/slaves 
vm ex lxcm01 -r 'salt -E lxcc* state.apply mesos-master'
vm ex lxcm01 -r 'salt -E lxb* state.apply'
```

[5]: srv/salt/zookeeper.sls
[6]: srv/salt/mesos-master.sls
[7]: srv/salt/mesos-zookeeper.sls
[8]: srv/salt/mesos-slave.sls
