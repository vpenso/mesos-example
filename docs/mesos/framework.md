# Frameworks

Framework, basically a pluggable application **workload schedulers**:

* User-interface for distributed applications
* Components: 
  - **Scheduler** - Communicates with master (match offers, launch/monitor tasks) 
  - **Executor** - Executes task launched by scheduler, communicates task status
* Schedulers require to be build high-available (automatic failover) (like the Mesos master)
* Frameworks communicate to the Mesos master by HTTP API

```bash
# list frameworks
cul -s http://$MESOS_MASTER_IP_PORT/frameworks | jq '.frameworks[] | {name,hostname,active}'
```

List of Mesos frameworks: 

<https://mesos.apache.org/documentation/latest/frameworks/>

Separate schedulers for different workloads:

* Long running stateless services (i.e. Marathon)
* Stateful services (e.g. databases)
* Periodic (cron like) jobs, (i.e. Chronos, Jenkins)
* Batch jobs (sequential/parallel)

### Flow of Events

Typical flow of events for a framework:

1. (Re-)Registers with the master (gets framework ID)
2. Continuously receive a resource offers from the master
3. Accept offer(, or reject the offer)
4. Send tasks (executors) to the master
5. Master allocates resources and launches tasks
6. React task state change (complete, failure, lost, etc.)
7. Disconnect from the master




