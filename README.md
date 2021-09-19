# droneci

[Drone](https://www.drone.io) is a self-service Continuous Integration platform for busy development teams.

[Repository](https://github.com/drone/drone)

Manual Build
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

ff2
