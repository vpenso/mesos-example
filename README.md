The shell **script [source_me.sh](source_me.sh)** adds the tool-chain in this repository to your shell environment.

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

# Mesos

_Mesos is platform to share computing resources between multiple cluster computing frameworks._

* Provides a low-level **abstraction of physical resources**
* Abstracts cores, memory, storage, etc. away from machines (physical and/or virtual)
* Enables **dynamic resource parititoning** (fault-tolerant, elastic distributed systems)
* The [master][18] offers resources to [frameworks][21] responsible for **workload specific scheduling**
* **Dispatches tasks** to the resources on [slave][20] nodes, and reallocates these when a previous task ends

**Two-level scheduling** separates responsibilities between Mesos (master) and frameworks:

* Scheduler (master and frameworks) do not have a global knowledge about resource utilization
* Resource allocation decisions can be non-optimal from a global view

Dominant Resource Fairness (DRF) Algorithm (concurrent pessimistic)

* Min-max fairness algorithm maximizes the minimum resources allocated to a user (1/Nth to each)
* DRF generalizes the min-max algorithm for multiple resources
* A dominant resource is the resource a user has biggest share of
* The dominant share is the fraction of the dominant resource a user has allocated
* **Schedules tasks to the user with smallest dominant share**

## Ecosystem

[Mesosphere][3] - Company offering DC/OS and heavily contributing to Mesos

[DC/OS][4] (Data Center Operating System)

- Commercial product build around/upon Mesos "kernel"
- Simplifies framework deployment (app-store like installation)
- Built-in high-availability and fault-tolerance (services & frameworks)
- Advanced operational tools (CLI & GUI)
- [DC/OS OpenSource][5] available on Github

Univa [URB][7] (Universal Resource Broker) is Mesos API compatible.

[MiniMesos][11] is a testing tool for Mesos.

Other Open-Source **Container Orchestration Engines** (COEs):

- [Kubernetes][8]
- [Nomad][9]
- [Swarm][10]
- [Kontena][12]


[0]:  https://github.com/vpenso/vm-tools
[1]:  https://mesos.apache.org
[2]:  https://github.com/apache/mesos
[3]:  https://mesosphere.com
[4]:  https://dcos.io
[5]:  https://github.com/dcos/dcos
[7]:  https://github.com/UnivaCorporation/urb-core
[8]:  https://kubernetes.io
[9]:  https://www.nomadproject.io
[10]: https://docs.docker.com/engine/swarm
[11]: https://minimesos.org
[12]: https://github.com/kontena/kontena
[18]: docs/mesos/master.md
[19]: docs/zookeeper.md
[20]: docs/mesos/slave.md
[21]: docs/mesos/framework.md





