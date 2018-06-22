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




## Architecture

Mesos allocates resources to frameworks which do workload specific scheduling

* Mesos provides low-level **abstraction of physical resources**
* **Frameworks** abstract away operational concerns of distributed systems
* **Tasks** concerned with computation-specific problems

(Application) **Two-level scheduling** separates responsibilities between Mesos and frameworks

Mesos (distributed system kernel, data center time-sharing)

- Enables dynamic **resource parititoning** (fault-tolerant elastic distributed systems)
- Abstracts CPU, memory, storage(, etc.) away from machines (physical/virtual)
- Understands primitives of distributed computing, no intelligence on using these efficiently
- **Master** node (+ standby masters for HA), requires service discovery (e.g. ZooKeeper)
- **Slave** (agent) nodes (physical resources), advertise available resources/attributes
- **Offers resources** to frameworks (schedulers)
- Dispatches tasks to the slave nodes, reallocates when tasks end

Dominant Resource Fairness (DRF) Algorithm (concurrent pessimistic)

* A dominant resource is the resource a user has biggest share of
* The dominant share is the fraction of the dominant resource a user has allocated
* **Schedules tasks to the user with smallest dominant share**

High-Availability:

* If the master is unavailable
  - Existing tasks continue execution
  - New resources can not be allocated
* Use multiple Mesos masters:
  - **Leader**, active master
  - Backup masters in case of failure
  - Master **election** with Apache Zookeeper

Frameworks (== pluggable schedulers):

* User-land interface for distributed applications
* Receive **resource offers** from Mesos, accept/reject offer, dispatch tasks
* Tell Mesos (kernel) how to run applications
* Separate schedulers for different **workloads**:
  - Long running stateless services (i.e. Marathon)
  - Stateful services (e.g. databases)
  - Periodic (cron like) jobs, (i.e. Chronos, Jenkins)
  - Batch jobs (sequential/parallel)

## Ecosystem

Apache Mesos][1] - OpenSource cluster resource manager system

- Distributed system kernel, abstract resource pool (CPUs, memory, etc)
- API for resource management across datacenters and/or cloud providers

[Mesosphere][3] - Company offering DC/OS and heavily contributing to Mesos

[DC/OS][4] (Data Center Operating System)

- Commercial product build around/upon Mesos "kernel"
- Simplifies framework deployment (app-store like installation)
- Built-in high-availability and fault-tolerance (services & frameworks)
- Advanced operational tools (CLI & GUI)
- [DC/OS OpenSource][5] available on Github

Univa [URB][7] (Universal Resource Broker) is Mesos API compatible.

Frameworks (application schedulers) build onto of Mesos:

<https://mesos.apache.org/documentation/latest/frameworks/>

Other systems build for container orchestration:

- [Kubernetes][8]
- [Nomad][9]
- [Swarm][10]


[0]:  https://github.com/vpenso/vm-tools
[1]:  https://mesos.apache.org
[2]:  https://github.com/apache/mesos
[3]:  https://mesosphere.com
[4]:  https://dcos.io
[5]:  https://github.com/dcos/dcos
[7]:  https://github.com/UnivaCorporation/urb-core
[8]:  https://kubernetes.io
[9]:  https://www.nomadproject.io
[10]: https://docs.docker.com/engine/swarm/





