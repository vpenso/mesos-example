# Frameworks

Pluggable **application schedulers**:

* User-land interface for distributed applications
* Receive **resource offers** from Mesos, accept/reject offer, dispatch tasks
* Tell Mesos (kernel) how to run applications
* Separate schedulers for different workloads:
  - Long running stateless services (i.e. Marathon)
  - Stateful services (e.g. databases)
  - Periodic (cron like) jobs, (i.e. Chronos, Jenkins)
  - Batch jobs (sequential/parallel)

```bash
# list frameworks
cul -s http://$MESOS_MASTER_IP_PORT/frameworks | jq '.frameworks[] | {name,hostname,active}'
```
List of Mesos frameworks: 

<https://mesos.apache.org/documentation/latest/frameworks/>
