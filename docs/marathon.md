# Marathon 

Mesos framework designed to launch **long-running applications** (services).

* Replaces the traditional init-system in a **clustered** environment
* Adds scaling and self-healing capabilities (high-availability, health checks)

<https://mesosphere.github.io/marathon/docs/>

## Application

* Typically a long-running service with instances on multiple nodes
* Application instances are called **task**
* The **application definition** describes the task setup and configuration

```bash

# example application definitions
ls -1 $MESOS_EXAMPLE/var/marathon/apps
```

## REST API

<https://mesosphere.github.io/marathon/api-console/index.html>

```bash
# deploy app
curl -s $MARATHON_URL/v2/apps \
     -X POST \
     -H "Content-type: application/json" \
     -d @$MESOS_EXAMPLE/var/marathon/apps/hello.json
# list apps
curl -s $MARATHON_URL/v2/apps | jq '.apps[].id'
# list command executed by app
curl -s $MARATHON_URL/v2/apps/<app-name> | jq '.app.cmd'
# delete an app
curl -s -X DELETE $MARATHON_URL/v2/apps/<app-name> | jq '.'
```

Start an HTTP server from a Docker image: 

```bash
curl -s $MARATHON_URL/v2/apps \
     -X POST \
     -H "Content-type: application/json" \
     -d @$MESOS_EXAMPLE/var/marathon/apps/docker-http-server.json
```
