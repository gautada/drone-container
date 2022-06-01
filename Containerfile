ARG PODMAN_VERSION=3.4.7
# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                           │
# │ STAGE 1: src-drone - Build drone from source and several (Docker, Exec,   |
# | Kube) runners also from source.                                           │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/podman:$PODMAN_VERSION as src-drone

# ╭――――――――――――――――――――╮
# │ VERSION(S)         │
# ╰――――――――――――――――――――╯
ARG DRONE_SERVER_VERSION=2.11.1
ARG DRONE_CLI_VERSION=1.5.0
ARG DRONE_RUNNER_DOCKER_VERSION=1.8.1
ARG DRONE_RUNNER_EXEC_VERSION=1.0.0-beta.9
ARG DRONE_RUNNER_KUBE_VERSION=1.0.0-rc.3

ARG DRONE_SERVER_BRANCH=v"$DRONE_SERVER_VERSION"
ARG DRONE_CLI_BRANCH=v"$DRONE_CLI_VERSION"
ARG DRONE_RUNNER_DOCKER_BRANCH=v"$DRONE_RUNNER_DOCKER_VERSION"
ARG DRONE_RUNNER_EXEC_BRANCH=v"$DRONE_RUNNER_EXEC_VERSION"
ARG DRONE_RUNNER_KUBE_BRANCH=v"$DRONE_RUNNER_KUBE_VERSION"

# ╭――――――――――――――――――――╮
# │ CHANGE UPS USER    │
# ╰――――――――――――――――――――╯
USER root
WORKDIR /

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apk add --no-cache build-base git go
RUN git config --global advice.detachedHead false

# ╭――――――――――――――――――――╮
# │ SOURCE             │
# ╰――――――――――――――――――――╯
RUN mkdir -p /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $DRONE_SERVER_BRANCH --depth 1 https://github.com/drone/drone.git
RUN git clone --branch $DRONE_CLI_BRANCH --depth 1 https://github.com/drone/drone-cli.git
RUN git clone --branch $DRONE_RUNNER_DOCKER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-docker.git
RUN git clone --branch $DRONE_RUNNER_EXEC_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-exec.git
RUN git clone --branch $DRONE_RUNNER_KUBE_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-kube.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build -o release/linux/arm64/drone-server
WORKDIR /usr/lib/go/src/github.com/drone-cli
# RUN go build -o release/linux/arm64/drone-cli
# Not sure why CLI is different thant the others
RUN go install ./...
WORKDIR /usr/lib/go/src/github.com/drone-runner-docker
RUN go build -o release/linux/arm64/drone-runner-docker
WORKDIR /usr/lib/go/src/github.com/drone-runner-exec
RUN go build -o release/linux/arm64/drone-runner-exec
WORKDIR /usr/lib/go/src/github.com/drone-runner-kube
RUN go build -o release/linux/arm64/drone-runner-kube




# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 2: drone-container                                                │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/podman:$PODMAN_VERSION

# ╭――――――――――――――――――――╮
# │ CHANGE UPS USER    │
# ╰――――――――――――――――――――╯
USER root
WORKDIR /

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/drone-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a drone CI installation."

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080
EXPOSE 3000

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=src-drone /usr/lib/go/src/github.com/drone/cmd/drone-server/release/linux/arm64/drone-server /usr/bin/drone-server
COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-exec/release/linux/arm64/drone-runner-exec /usr/bin/drone-runner-exec
COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-docker/release/linux/arm64/drone-runner-docker /usr/bin/drone-runner-docker
COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-kube/release/linux/arm64/drone-runner-kube /usr/bin/drone-runner-kube
COPY --from=src-drone /usr/lib/go/bin/drone /usr/bin/drone
COPY 20-entrypoint.sh /etc/entrypoint.d/20-entrypoint.sh
RUN mkdir -p /etc/drone \
 && ln -s /opt/drone/server.env /etc/drone/server.env \
 && ln -s /opt/drone/runner-docker.env /etc/drone/runner-docker.env \
 && ln -s /opt/drone/runner-exec.env /etc/drone/runner-exec.env \
 && ln -s /opt/drone/runner-kube.env /etc/drone/runner-kube.env \
 && ln -s /tmp/podman-run-1002/podman/podman.sock /var/run/docker.sock

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=drone
VOLUME /opt/$USER
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
# Not home so the core.sqlite database is accessable via volume
WORKDIR /opt/drone
