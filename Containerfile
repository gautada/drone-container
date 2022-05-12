ARG ALPINE_VERSION=3.15.4
ARG PODMAN_VERSION=3.4.7

FROM docker.io/gautada/alpine:$ALPINE_VERSION as build-drone

ARG DRONE_BRANCH=v2.11.1
ARG EXEC_RUNNER_BRANCH=v1.0.0-beta.9
ARG DOCKER_RUNNER_BRANCH=v1.8.1
ARG KUBE_RUNNER_BRANCH=v1.0.0-rc.3
ARG CLI_BRANCH=v0.0.0

USER root
WORKDIR /

RUN apk add --no-cache build-base git go
RUN git config --global advice.detachedHead false

RUN mkdir /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $DRONE_BRANCH --depth 1 https://github.com/drone/drone.git
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $EXEC_RUNNER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-exec.git
WORKDIR /usr/lib/go/src/github.com/drone-runner-exec
RUN go build -o release/linux/arm64/drone-runner-exec

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $DOCKER_RUNNER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-docker.git
WORKDIR /usr/lib/go/src/github.com/drone-runner-docker
RUN go build -o release/linux/arm64/drone-runner-docker

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $KUBE_RUNNER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-kube.git
WORKDIR /usr/lib/go/src/github.com/drone-runner-kube
RUN go build -o release/linux/arm64/drone-runner-kube

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $CLI_BRANCH --depth 1 https://github.com/drone/drone-cli.git
WORKDIR /usr/lib/go/src/github.com/drone-cli
RUN go install ./...

#
# ------------------------------------------------------------- CONTAINER
FROM docker.io/gautada/podman:$PODMAN_VERSION

USER root
WORKDIR /

LABEL source="https://github.com/gautada/drone-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a drone CI installation."

EXPOSE 8080
EXPOSE 3000

VOLUME /opt/drone

COPY --from=build-drone /etc/localtime /etc/localtime
COPY --from=build-drone /etc/timezone  /etc/timezone
COPY --from=build-drone /usr/lib/go/src/github.com/drone/cmd/drone-server/drone-server /usr/bin/drone-server
COPY --from=build-drone /usr/lib/go/src/github.com/drone-runner-exec/release/linux/arm64/drone-runner-exec /usr/bin/drone-runner-exec
COPY --from=build-drone /usr/lib/go/src/github.com/drone-runner-docker/release/linux/arm64/drone-runner-docker /usr/bin/drone-runner-docker
COPY --from=build-drone /usr/lib/go/src/github.com/drone-runner-kube/release/linux/arm64/drone-runner-kube /usr/bin/drone-runner-kube
COPY --from=build-drone /usr/lib/go/bin/drone /usr/bin/drone

COPY 20-entrypoint.sh /etc/entrypoint.d/20-entrypoint.sh

RUN ln -s /tmp/podman-run-1002/podman/podman.sock /var/run/docker.sock

ARG USER=drone
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER \
 && /bin/touch /var/log/drone-server.log \
 && /bin/touch /var/log/drone-runner-exec.log \
 && /bin/touch /var/log/drone-runner-docker.log \
 && /bin/touch /var/log/drone-runner-kube.log \
 && /bin/chown $USER:$USER -R /opt/$USER /var/log/drone-*.log
 # && /bin/touch /opt/$USER/$USER.sqlite \
 
USER $USER
# WORKDIR /home/$USER
WORKDIR /opt/drone
