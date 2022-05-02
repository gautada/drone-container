# droneci

[Drone](https://www.drone.io) is a self-service Continuous Integration platform for busy development teams. This container contains three drone compoments:

- [Drone](https://github.com/harness/drone) is a continuous delivery system built on container technology. Drone uses a simple YAML build file, to define and execute build pipelines inside Docker containers.
- The [kubernetes runner](https://github.com/drone-runners/drone-runner-kube) executes pipelines inside Kubernetes pods. This runner is an alternative to the docker runner and is optimize for teams running Drone on Kubernetes. This requires Drone server 1.6.0 or higher.
- [Command line client](https://github.com/harness/drone-cli) for the Drone continuous integration server.

## Container

### Versions

### Build

Drone is a part of the core CICD system and therefore may need to be built manually

```
export DRONE_VERSION="2.11.1" ; DRONE_BRANCH=v"$DRONE_VERSION"; export RUNNER_VERSION="1.0.0-rc.3" ; export RUNNER_BRANCH=v"$RUNNER_VERSION" ; export CLI_VERSION="1.5.0" ; export CLI_BRANCH=v"$CLI_VERSION" ; docker build --build-arg DRONE_BRANCH=$DRONE_BRANCH --build-arg RUNNER_BRANCH=$RUNNER_BRANCH --build-arg CLI_BRANCH=$CLI_BRANCH --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag drone:dev .
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
