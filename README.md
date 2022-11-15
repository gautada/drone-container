# Drone

## Abstrct

[Drone](https://www.drone.io) is a modern continuous integration platform that empowers automated build, test and release workflows using a powerful, cloud native pipeline engine.

This container generally connects to [GitHub](https://github.com) to pull other container's code-base down and builds the container image via [Podman](https://podman.io) and then pushes the image to [Docker Hub](https//hub.docker.com) to be used in a Kubernetes cluster.

## Features

- [Drone](https://github.com/harness/drone) is a continuous delivery system built on container technology. Drone uses a simple YAML build file, to define and execute build pipelines inside Docker containers.
- [Command line client](https://github.com/harness/drone-cli) for the Drone continuous integration server.
- [Runners](https://github.com/drone-runners) This container contains multiple runners.
 - Docker - Lauches a docker container
 - Exec - Runs locally on the drone host
 - Kube - Runs a pod in the k8s cluster

## Development

This container is considered a bootstrap component and needs to be buildable all on it's own without dependencies. 

### Build Script

Parameters:
- ALPINE_VERSION
- PODMAN_VERSION
- DRONE_SERVER_VERSION
- DRONE_RUNNER_DOCKER_VERSION
- DRONE_RUNNER_EXEC_VERSION
- DRONE_RUNNER_KUBE_VERSION

```
docker compose build drone --no-cache
```

### Run Script

The `{command} parameter is option and is only needed if you want to overide the default.

```
docker compose run --service-ports drone {command}
```

### Deploy Script

Being a bootstrap container you may need to push the image to the repository.

Parameters:
- {DRONE_SERVER_VERSION}: Version from the above build script
- {DOCKER_USERNAME}: Docker Hub User Name
- {Docker_PASSWORD}: Docker Hub Password

On the desktop credentials are usually handled by the desktop app, check `~/.docker/config.json` to confirm.  This should eliminate the need for `docker login --username={DOCKER_USERNAME} --password={DOCKER_PASSWORD} docker.io`
```
docker tag drone:dev docker.io/gautada/drone:{DRONE_SERVER_VERSION}
docker push docker.io/gautada/drone:{DRONE_SERVER_VERSION}
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

## Notes

- The podman environment needs to use the `--format` to build like docker.  This needed if the `VOLUME` command is used in the container file. To remove the subsequent warning user `--format docker`.




