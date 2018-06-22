# Apache Mesos Cluster with SaltStack 

Component     | Description                             | CF.
--------------|-----------------------------------------|----------------------------
CentOS 7      | Operating system                        | https://www.centos.org
SaltStack     | Infrastructure orchestration            | https://saltstack.com
Mesos         | Resource orchestration                  | https://mesos.apache.org
Marathon      | Container orchestration (service)       | https://mesosphere.github.io/marathon
Chronos       | Container orchestration (periodic jobs)  | https://mesos.github.io/chronos/

**Install Zookeeper, Mesos, Marathon and Chronos on a single node**

This example uses a virtual machine setup with [vm-tools][0].

```bash
# start a CentOS 7 virtual machine instance
vm s centos7 lxdev01
# login and configure the virtual machine
vm lo lxdev01 -r
## -- CentOS --##
# Add the repository
rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm
# install packages
yum -y install --enablerepo=mesosphere \
        mesos docker mesosphere-zookeeper marathon chronos
# use Docker as containerizer
echo docker,mesos > /etc/mesos-slave/containerizers
# configure Marathon
cat << EOF > /etc/default/marathon
MARATHON_MASTER=zk://127.0.0.1:2181/mesos
MARATHON_ZK=zk://127.0.0.1:2181/marathon
EOF
# start all services
systemctl enable --now \
        docker zookeeper mesos-master mesos-slave marathon chronos
# firewall configuration
firewall-cmd --permanent --zone=public --add-port=5050/tcp # mesos-master
firewall-cmd --permanent --zone=public --add-port=5051/tcp # mesos-slave
firewall-cmd --permanent --zone=public --add-port=8080/tcp # marathon
firewall-cmd --permanent --zone=public --add-port=4400/tcp # chronos
firewall-cmd --reload
```

Use the web-interfaces to Mesos and start tasks:

```bash
# open Mesos web GUI 
$BROWSER http://$(vm ip lxdev01):5050
# open Marathon web GUI
$BROWSER http://$(vm ip lxdev01):8080
# open Chronos web GUI
$BROWSER http://$(vm ip lxdev01):4400
```

**Find a more comprehensive Mesos Cluster example in [INSTALL.md](INSTALL.md)**

[0]: https://github.com/vpenso/vm-tools
