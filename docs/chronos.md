# Chronos

Chronos is a framework designed to run **periodic tasks**.

<https://github.com/mesos/chronos>  
<https://mesos.github.io/chronos/>

* Schedule tasks with **repeating interval**
* Tasks may have parent **dependencies**

## REST API

<https://mesos.github.io/chronos/docs/api.html>

```bash
# deploy app
curl -s $CHRONOS_URL \
     -X POST \
     -H "Content-type: application/json" \
     -d @$MESOS_EXAMPLE/var/chronos/hello.json
# list jobs
curl -s $CHRONOS_URL/scheduler/jobs
```
