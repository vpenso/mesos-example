# Chronos

Chronos is a framework designed to run **periodic jobs**.

<https://github.com/mesos/chronos>  
<https://mesos.github.io/chronos/>

* Distributed and fault-tolerant
* Supports bash and custom executor
* Schedule jobs with **repeating interval** (ISO8601 notation)
* Tasks may have **job dependencies**

## REST API

<https://mesos.github.io/chronos/docs/api.html>

```bash
# deploy app
curl -s $CHRONOS_URL/scheduler/iso8601 \
     -X POST \
     -H "Content-type: application/json" \
     -d @$MESOS_EXAMPLE/var/chronos/hello.json
# list jobs
curl -s $CHRONOS_URL/scheduler/jobs | jq '.[].name'
# delete the job
curl -s $CHRONOS_URL/scheduler/job/hello -X DELETE
```
