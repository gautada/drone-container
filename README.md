# Drone

## Abstrct

[Drone](https://www.drone.io) is a modern continuous integration platform that empowers automated build, test and release workflows using a powerful, cloud native pipeline engine.

This container generally connects to [GitHub](https://github.com) to pull other container's code-base down and builds the container image via [Podman](https://podman.io) and then pushes the image to [Docker Hub](https//hub.docker.com) to be used in a Kubernetes cluster.

## Features

### Stateless

The **Drone** container is ment to be stateless and therefore these should not be a need for backup.

## Development

This container is considered a bootstrap component and needs to be buildable all on it's own

### Build Script

```
```

### Run Script

```
```

### Deploy Script

```
```

## Test

## Deploy

## Architecture

## Context

![Context Diagram](https://www.plantuml.com/plantuml/svg/VL99Jy9G4BxpAvwSC56vSF1W3DeQGuJOW9wReHtg2szftaBeltUwrwMSElcMRzxCT6aT6EUbc5nnbGYV8di85lDWSPSJ-FWRZGEj79xT1HQuGZFAormhL6F-i50WUJB6OYvq8NlxP5TOXp9-ERjPnjsNtz-mwMjLJAdQQMyIP86cY0qeoD2mMqOysw4vyGIdryE4L2T7DEGBgw9CwEPXMyorvKwRWYB-Woch2PlbEfMWo1vLnS-WMaCXxy5g4FGKhRhNp5AZ5POFAR-jdIkllMNFdekKx7-Wsjk7q48GwdqWZAzZhHCGyyZm4pXaGmsejEnou9atuBXMRAKEsiYgxllGlOm-tblgi6dAijkRtwDHwD0Efem4k3AYxSkElIflk7AHQoZYi3jfDGcXMnJnjaFR9NqOdj4ebdoT0E42tn23TzS_Lgi8MqLtnq-BlRr5kz-5O8HQiKILUYc-0G00)

## Container

## Component

## Administration

### Checklist

- [ ] README conforms to the [gist](https://gist.github.com/gautada/ec549c846e8e50daf355d01b06eb0665)
- [ ] .gitignore conforms to the [gist](https://gist.github.com/gautada/3a0a4a76d3c7e4539e71fc02c7f599ad)
- [ ] Volume folders are present (development-volume & backup-volume)
- [ ] docker-compose(.yml) works
- [ ] Manifst folder present (and origin to private repository is correct
- [ ] Issue List is linked to proper URI
- [ ] Signoff ({date and signature of last check})

### Issues

The official to list is kept in a [GitHub Issue List](https://github.com/gautada/drone-container/issues)

- [Drone](https://github.com/harness/drone) is a continuous delivery system built on container technology. Drone uses a simple YAML build file, to define and execute build pipelines inside Docker containers.
- [Command line client](https://github.com/harness/drone-cli) for the Drone continuous integration server.
- [Runners](https://github.com/drone-runners) This container contains multiple runners.
 - Docker - Lauches a docker container
 - Exec - Runs locally on the drone host
 - Kube - Runs a pod in the k8s cluster
 
## Container

### Versions

### Build

Drone is a part of the core CICD system and therefore may need to be built manually

```
docker run --detach --name drone --rm --publish 8080:8080 --privileged --volume ~/Workspace/drone/drone-container:/opt/drone gautada/drone:2.11.1 server


docker build --build-arg PODMAN_VERSION=4.1.0 --build-arg DRONE_SERVER_VERSION=2.11.1 --build-arg DRONE_CLI_VERSION=1.5.0 --build-arg DRONE_RUNNER_DOCKER_VERSION=1.8.1 --build-arg DRONE_RUNNER_EXEC_VERSION=1.0.0-beta.9 --build-arg DRONE_RUNNER_KUBE_VERSION=1.0.0-rc.3 --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag drone:build .

export ALPINE_VERSION=3.15.4 ; export PODMAN_VERSION=3.4.7 ; export DRONE_VERSION="2.11.1" ; DRONE_BRANCH=v"$DRONE_VERSION"; export RUNNER_VERSION="1.0.0-rc.3" ; export RUNNER_BRANCH=v"$RUNNER_VERSION" ; export CLI_VERSION="1.5.0" ; export CLI_BRANCH=v"$CLI_VERSION" ; docker build --build-arg ALPINE_VERSION=$ALPINE_VERSION --build-arg PODMAN_VERSION=$PODMAN_VERSION --build-arg DRONE_BRANCH=$DRONE_BRANCH --build-arg RUNNER_BRANCH=$RUNNER_BRANCH --build-arg CLI_BRANCH=$CLI_BRANCH --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag drone:dev .


export ALPINE_VERSION="3.15.4" ; export PODMAN_VERSION="3.4.7" ; export DRONE_VERSION="2.11.1" ; DRONE_BRANCH=v"$DRONE_VERSION"; export RUNNER_VERSION="1.0.0-rc.3" ; export RUNNER_BRANCH=v"$RUNNER_VERSION" ; export CLI_VERSION="1.5.0" ; export CLI_BRANCH=v"$CLI_VERSION" ; docker build --build-arg ALPINE_VERSION=$ALPINE_VERSION --build-arg PODMAN_VERSION=$PODMAN_VERSION --build-arg DRONE_BRANCH=$DRONE_BRANCH --build-arg RUNNER_BRANCH=$RUNNER_BRANCH --build-arg CLI_BRANCH=$CLI_BRANCH --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag podman:dev .

```

### Run

There are three configurations for the **Drone** container:
- **Server:** Launches the CICD server with a configured CLI interface for direct manipulation
- **Runner** Launches (in a seperate container) the worker node for the CICD system
- **Exec** Runs the command given

The default configuration is the **Server**

```
docker run --interactive --tty --name drone-server --rm drone:dev
```

Or the **Server** can be explicit

```
docker run --interactive --tty --name drone-server --rm drone:dev server
```

The server configuration should work with the CLI instance to provide easy management

```
docker exec --interactive --tty drone drone-server --version
```

To run the **Runner** configuration

```
docker run --interactive --tty --name drone-runner --rm drone:dev runner
```

Finally an command could be run to help maintain the container or to just test functionality

```
docker run --interactive --tty --name drone --rm drone:dev which drone
```






[Repository](https://github.com/drone/drone)

  - podman --remote --connection arm build --build-arg ALPINE_TAG=3.14.2  --file Containerfile --no-cache  --tag drone:dev .
  - podman --remote --connection arm tag drone:dev docker.io/gautada/drone:v2.3.1-arm
  - podman --remote --connection arm login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD docker.io
  - podman --remote --connection arm push docker.io/gautada/drone:v2.3.1-arm
  - podman --remote --connection x86 build --build-arg ALPINE_TAG=3.14.2  --build-arg SERVER_BRANCH=v2.3.1 --build-arg RUNNER_BRANCH=v1.0.0-beta.12 --build-arg CLI_BRANCH=v1.4.0 --file Containerfile --no-cache  --tag drone:dev .
  - podman --remote --connection x86 tag drone:dev docker.io/gautada/drone:v2.3.1-x86
  - podman --remote --connection x86 login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD docker.io
  - podman --remote --connection x86 push docker.io/gautada/drone:v2.3.1-x86
  - podman --remote --connection arm manifest create drone:man
  - podman --remote --connection arm manifest add drone:man docker.io/gautada/drone:v2.3.1-arm
  - podman --remote --connection arm manifest add drone:man docker.io/gautada/drone:v2.3.1-x86
  - podman --remote --connection arm tag drone:man docker.io/gautada/drone:v2.3.1
  - podman --remote --connection arm login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD docker.io
  - podman --remote --connection arm push docker.io/gautada/drone:v2.3.1
  - podman --remote --connection arm rmi drone:man


Manual Build

ALPINE_TAG: 3.14.2
SERVER_BRANCH: v2.3.1
RUNNER_BRANCH: v1.0.0-beta.12
CLI_BRANCH: v1.4.0
    
podman --remote --connection arm build --build-arg ALPINE_TAG=3.14.2 --build-arg SERVER_BRANCH=v2.3.1 --build-arg RUNNER_BRANCH=v1.0.0-beta.12 --build-arg CLI_BRANCH=v1.4.0 --file Containerfile --no-cache  --tag drone:dev .
podman --remote --connection arm tag drone:dev docker.io/gautada/drone:v2.3.1-arm
podman --remote --connection arm login --username=gautada docker.io
podman --remote --connection arm push docker.io/gautada/drone:v2.3.1-arm
podman --remote --connection x86 build --build-arg ALPINE_TAG=3.14.2  --build-arg SERVER_BRANCH=v2.3.1 --build-arg RUNNER_BRANCH=v1.0.0-beta.12 --build-arg CLI_BRANCH=v1.4.0 --file Containerfile --no-cache  --tag drone:dev .
podman --remote --connection x86 tag drone:dev docker.io/gautada/drone:v2.3.1-x86
podman --remote --connection x86 login --username=gautada docker.io
podman --remote --connection x86 push docker.io/gautada/drone:v2.3.1-x86
podman --remote --connection arm manifest create drone:man
podman --remote --connection arm manifest add drone:man docker.io/gautada/drone:v2.3.1-arm
podman --remote --connection arm manifest add drone:man docker.io/gautada/drone:v2.3.1-x86
podman --remote --connection arm tag drone:man docker.io/gautada/drone:v2.3.1
podman --remote --connection arm login --username=gautada docker.io
podman --remote --connection arm push docker.io/gautada/drone:v2.3.1
podman --remote --connection arm rmi drone:man

```
docker build --build-arg ALPINE_TAG=3.14.1 --build-arg SERVER_BRANCH=v2.1.0 --build-arg RUNNER_BRANCH=v1.0.0-beta.9 --build-arg CLI_BRANCH=v1.3.3 --no-cache --tag localhost/droneci:dev . -f Containerfile
docker run -i -p 8080:8080 -t --rm --name droneci localhost/droneci:dev 
```

```
openssl rand -hex 16
```

## Configuration

### Secrets

drone orgsecret add gautada ID_RSA_KEY = "..."
drone orgsecret add gautada ID_RSA_KEY_PUB = "..."

ff4


## Notes

These note are for the drone contaienr and general build notes as well.  

### Docker Format

**Podman** builds within **drone** require the format to be set via the `--format` flag. To eliminate the warning use `--format docker`.
 
 ```
podman build --build-arg ALPINE_VERSION=$ALPINE_VERSION --build-arg POSTGRES_VERSION=$POSTGRES_VERSION --file Containerfile --format docker --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag postgres:build .
```

### git - Specific source code for a tag.

```
git config --global advice.detachedHead false
git clone --branch $POSTGRES_BRANCH --depth 1 https://github.com/postgres/postgres.git
```
