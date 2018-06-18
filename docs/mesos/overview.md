[Apache Mesos][1] - OpenSource cluster resource manager system

- Distributed system kernel, abstract resource pool (CPUs, memory, etc)
- API for resource management across datacenters and/or cloud providers

[Mesosphere][3] - Company offering DC/OS and heavily contributing to Mesos

[DC/OS][4] (Data Center Operating System)

- Commercial product build around/upon Mesos "kernel"
- Simplifies framework deployment (app-store like installation)
- Built-in high-availability and fault-tolerance (services & frameworks)
- Advanced operational tools (CLI & GUI)
- [DC/OS OpenSource][5] available on Github

Univa [URB][7] (Universal Resource Broker) is Mesos API compatible

Competing systems build for container orchestration:

- [Kubernetes][8]
- [Nomad][9]
- [Swarm][10]

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

Frameworks (== pluggable schedulers):

* User-land interface for distributed applications
* Receive **resource offers** from Mesos, accept/reject offer, dispatch tasks
* Tell Mesos (kernel) how to run applications
* Separate schedulers for different **workloads**:
  - Long running stateless services (i.e. Marathon)
  - Stateful services (e.g. databases)
  - Periodic (cron like) jobs, (i.e. Chronos, Jenkins)
  - Batch jobs (sequential/parallel)

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

### High-Availability

* If the master is unavailable
  - Existing tasks continue execution
  - New resources can not be allocated
* Use multiple Mesos masters:
  - **Leader**, active master
  - Backup masters in case of failure
  - Master **election** with Apache Zookeeper

[1]:  https://mesos.apache.org
[2]:  https://github.com/apache/mesos
[3]:  https://mesosphere.com
[4]:  https://dcos.io
[5]:  https://github.com/dcos/dcos
[7]:  https://github.com/UnivaCorporation/urb-core
[8]:  https://kubernetes.io
[9]:  https://www.nomadproject.io
[10]: https://docs.docker.com/engine/swarm/
