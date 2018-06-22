# Mesos Slave

```bash
# show a running daemon with arguments
>>> vm ex lxb001 -r 'ps --no-headers -o command -p $(pgrep mesos-slave) | sed "s/ /\n\t/g"'
/usr/sbin/mesos-slave
	--master=zk://10.1.1.9:2181,10.1.1.10:2181,10.1.1.11:2181/mesos
	--log_dir=/var/log/mesos
	--containerizers=docker,mesos
	--hostname=10.1.1.15
	--ip=10.1.1.15
	--work_dir=/var/lib/mesos
```

Also called Mesos **agents**:

* **Execute tasks** from frameworks using local resources
* Provide resource **isolation** (while running multiple tasks)

### Resources & Attributes

Node specifics advertised to the master by slave resources and slave attributes:

* Resources - CPUs, memory, disks, ports, etc. allocated for frameworks and **consumed** by a task
* Attributes - **Identify** slaves with some information (environment, software, network, etc.) interpreted by frameworks

Cf. [Mesos Attributes & Resources][1], [Slave Recovery in Apache Mesos][2]

```bash
# read attributes and resources for a given node from hte HTTP API 
>>> curl -S HTTP://$(vm ip lxb001):$MESOS_SLAVE_PORT/state | jq '{resources,attributes}'
{
  "resources": {
    "disk": 35068,
    "mem": 460,
    "gpus": 0,
    "cpus": 1,
    "ports": "[31000-32000]"
  },
  "attributes": {}
}
```

Configure by program argument or configuration file:

```bash
mesos-slave --resources='cpus:24;mem:122880;disk:921600;ports:[21000-29000]' \
            --attributes='os:centos7;rack:3' ...
# configuration files in /etc
/etc/mesos-slave/resources
/etc/mesos-slave/attributes
```

Simple configuration example:

```bash
>>> vm ex lxb001 -r '
        echo "os:centos7;rack:3" > /etc/mesos-slave/attributes
        # delete the latest slave recovery configuration
        rm -rf /var/lib/mesos/meta/slaves/latest
        systemctl restart mesos-slave
'
# the mesos-slave starts with the --attributes argument
>>> vm ex lxb001 -r 'ps --no-headers -o command -p $(pgrep mesos-slave) | sed "s/ /\n\t/g"'
/usr/sbin/mesos-slave
        ...
	--attributes=os:centos7;rack:3
        ...
# read the slave attributes from the HTTP API
>>> curl -s http://$(vm ip lxb001):$MESOS_SLAVE_PORT/state | jq '.attributes'
{                                                                            
  "os": "centos7",
  "rack": 3
}
```

### Containerization

* Pluggable architecture (extensible)
  - Image format
  - Network
  - Storage
  - Isolation
  - Life-cycle (hooks)
  - Nested containers
  - Provisioner (fetch/cache images)
* **Containerizer** (i.e. docker, cgroups/namespaces, appc, oci)
  - Between (Mesos) agent and containers
  - Launch, update, destroy containers
  - Configures container isolation
  - Provides container stats and status

```bash
# check the containerizer
curl -s http://$(vm ip lxb001):$MESOS_SLAVE_PORT/state |\
        jq '.flags.containerizers'
# configure the containerizer
NODES=lxb00[1-4] vn ex '
        echo mesos,docker > /etc/mesos-slave/containerizers
        systemctl restart mesos-slave
'
```

### Executor

Agents (slaves) launch an executor to run framework tasks:

- Communicates to the agent via HTTP API
- Can launch multiple tasks
- Notifies agent about task state, may receive state change from agent

List of executors:

Name                  | Description
----------------------|--------------------------------------------------------
command executor      | (legacy v0 API) starting a single task
docker executor       | launches docker container (instead of a command)
default executor      | (v1 API) capable of running **pods** (task groups)
custom executor       | build to handle custom workloads

```bash
# start a simple task 
>>> vm lo lxcc01 -r '
        mesos-execute --master=$(hostname -i):5050 \
                      --containerizer=mesos \
                      --name=sleep \
                      --command="echo sleep... ; sleep 300"
'
...
Submitted task 'sleep' to agent '96e29ec4-9c04-4ed7-b72e-9016a64f4903-S2'
...
# list all agends with IP address
>>> curl -s http://$MESOS_MASTER_IP_PORT/slaves | jq '.slaves[] | {id,hostname}'
{
  "id": "96e29ec4-9c04-4ed7-b72e-9016a64f4903-S2",
  "hostname": "10.1.1.18"
}
...
# list the process hierarchy on the slave node
>>> vm lo $(vm name 10.1.1.18) -r '
  ps -A --forest -o command= | grep ^/usr/sbin/mesos-slave -A6
'
/usr/sbin/mesos-slave ...
 \_ /usr/libexec/mesos/mesos-containerizer launch
     \_ mesos-executor --launcher_dir=/usr/libexec/mesos
         \_ sh -c echo sleep... ; sleep 5000
             \_ sleep 5000
```


[1]: https://mesos.apache.org/documentation/attributes-resources/
[2]: https://mesos.apache.org/blog/slave-recovery-in-apache-mesos/
