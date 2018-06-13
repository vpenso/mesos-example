


Frameworks (== pluggable schedulers):

* Separate schedulers each use-case:
  - Long running stateless services
  - Periodic (cron like) jobs
  - Stateful services (e.g. databases)
  - Batch jobs (sequential/parallel)

Containerization 

* pluggable architecture (extensible)
  - image format
  - network
  - storage
  - isolation
  - lifecycle (hooks)
  - nested containers
  - provisioner (fetch/cache images)
* **containerizer** (i.e. docker, cgroups/namespaces, appc, oci)
  - between (mesos) agent and containers
  - launch, update, destroy containers
  - configures container isolation
  - provides container stats and status



