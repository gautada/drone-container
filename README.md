# Drone

## Abstract

[Drone](https://drone.io) is a modern continuous integration platform that empowers automated build, test and release workflows using a powerful, cloud native pipeline engine.

**Drone** has joined [Harness](https://harness.io). The product page has moved to [Continuous Integration](https://harness.io/products/continuous-integration) and the project moved repomoved to [harness/drone](https://github.com/harness/drone/).

This container generally connects to [GitHub](https://github.com) to pull other container's code-base down and builds the container image via [Podman](https://podman.io) and then pushes the image to [Docker Hub](https//hub.docker.com) to be used in a Kubernetes cluster.

## Features

- CLI - command line interface
- **Runners**:
 - Docker - runner in a container (dind)
 - Exec - runner within the server container
 - Kube - runner within a pod in the k8s cluster

## Details

### CLI

[Command line client](https://github.com/harness/drone-cli) for the Drone continuous integration server.

### Docker

The [docker runner](https://github.com/drone-runners/drone-runner-docker) executes pipelines inside Docker containers. This runner is intended for linux workloads that are suitable for execution inside containers. This requires Drone server 1.6.0 or higher. Need to figureout the relationship to  [harness/harness-docker-runner](https://github.com/harness/harness-docker-runner).

### Exec

The [exec runner](https://github.com/drone-runners/drone-runner-exec) executes pipelines directly on the host machine. This runner is intended for workloads that are not suitable for running inside containers. This requires Drone server 1.2.3 or higher.

### Kube

The [kubernetes runner](https://github.com/drone-runners/drone-runner-kube) executes pipelines inside Kubernetes pods. This runner is an alternative to the docker runner and is optimize for teams running Drone on Kubernetes. This requires Drone server 1.6.0 or higher.


## Deploy

Being a bootstrap container you may need to push the image to the repository.

Parameters:
- {DRONE_SERVER_VERSION}: Version from the build script
- {DOCKER_USERNAME}: Docker Hub User Name
- {DOCKER_PASSWORD}: Docker Hub Password

On the desktop credentials are usually handled by the desktop app, check `~/.docker/config.json` to confirm.  This should eliminate the need for `docker login --username={DOCKER_USERNAME} --password={DOCKER_PASSWORD} docker.io`

**Integration Script**
```
docker tag drone:dev docker.io/gautada/drone:{DRONE_SERVER_VERSION}
docker push docker.io/gautada/drone:{DRONE_SERVER_VERSION}
```

## Architecture

## Context

![Context Diagram](https://www.plantuml.com/plantuml/svg/VL99Jy9G4BxpAvwSC56vSF1W3DeQGuJOW9wReHtg2szftaBeltUwrwMSElcMRzxCT6aT6EUbc5nnbGYV8di85lDWSPSJ-FWRZGEj79xT1HQuGZFAormhL6F-i50WUJB6OYvq8NlxP5TOXp9-ERjPnjsNtz-mwMjLJAdQQMyIP86cY0qeoD2mMqOysw4vyGIdryE4L2T7DEGBgw9CwEPXMyorvKwRWYB-Woch2PlbEfMWo1vLnS-WMaCXxy5g4FGKhRhNp5AZ5POFAR-jdIkllMNFdekKx7-Wsjk7q48GwdqWZAzZhHCGyyZm4pXaGmsejEnou9atuBXMRAKEsiYgxllGlOm-tblgi6dAijkRtwDHwD0Efem4k3AYxSkElIflk7AHQoZYi3jfDGcXMnJnjaFR9NqOdj4ebdoT0E42tn23TzS_Lgi8MqLtnq-BlRr5kz-5O8HQiKILUYc-0G00)

## Container

## Component

## Administration

### Checklist

- [2022-11-28 Checklist](https://github.com/gautada/drone-container/issues/34)

### Issues

The official to list is kept in a [GitHub Issue List](https://github.com/gautada/drone-container/issues)

## Notes

- The podman environment needs to use the `--format` to build like docker.  This needed if the `VOLUME` command is used in the container file. To remove the subsequent warning user `--format docker`.





