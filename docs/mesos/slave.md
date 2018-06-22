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

* Resources - CPUs, memory, disks, ports, etc. allocated for frameworks and consumed by a task
* Attributes - Identify slaves with some information (environement, software, network, etc.) interpreted by frameworks

<https://mesos.apache.org/documentation/attributes-resources/>



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
