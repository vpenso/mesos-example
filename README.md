# Mesos

Mesos allocates resources to frameworks which do workload specific scheduling

Architecture (birds view)

* Mesos provides low-level **abstraction of physical resources**
* **Frameworks** abstract away operational concerns of distributed systems
* **Tasks** concerned with computation-specific problems

**Two-level scheduling** separates responsibilities between Mesos and frameworks

Mesos (distributed system kernel, data center time-sharing)

- Enables dynamic **resource parititoning** (fault-tolerant elastic distributed systems)
- Abstracts CPU, memory, storage(, etc.) away from machines (physical/virtual)
- Understands primitivs of distributed computing, no intelligence on using these efficiently
- **Master** node (+ standby masters for HA), requires service discovery (e.g. ZooKepper)
- **Slave** (agent) nodes (physical resources), advertise available resources/attributes
- **Offers resources** to frameworks (schedulers)
- Dispatches tasks to the slave nodes, reallocates when tasks end

Frameworks (== pluggable schedulers):

* User-land interface for distributed applications
* Receive **resource offers** from Mesos, accept/reject offer, dispatch tasks
* Tell Mesos (kernel) how to run applications
* Separate schedulers for different **workloads**:
  - Long running stateless services (i.e. Marathon)
  - Stateful services (e.g. databases)
  - Periodic (cron like) jobs, (i.e. Chronos, Jenkins)
  - Batch jobs (sequential/parallel)

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



