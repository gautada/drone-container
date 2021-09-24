# droneci

[Drone](https://www.drone.io) is a self-service Continuous Integration platform for busy development teams.

[Repository](https://github.com/drone/drone)

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
