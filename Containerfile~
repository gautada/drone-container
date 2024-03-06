ARG ALPINE_VERSION=latest

# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                           │
# │ STAGE 1: src-drone - Build drone from source and several (Docker, Exec,   |
# | Kube) runners also from source.                                           │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as src-drone

# ╭――――――――――――――――――――╮
# │ VERSION(S)         │
# ╰――――――――――――――――――――╯
ARG DRONE_SERVER_VERSION=2.15.0
ARG DRONE_SERVER_BRANCH=v"$DRONE_SERVER_VERSION"

ARG DRONE_RUNNER_EXEC_VERSION=1.0.0-beta.10
ARG DRONE_RUNNER_EXEC_BRANCH=v"$DRONE_RUNNER_EXEC_VERSION"

ARG DRONE_CLI_VERSION=1.6.2
ARG DRONE_CLI_BRANCH=v"$DRONE_CLI_VERSION"

# ARG DRONE_RUNNER_DOCKER_VERSION=1.8.1
# ARG DRONE_RUNNER_DOCKER_BRANCH=v"$DRONE_RUNNER_DOCKER_VERSION"

# ARG DRONE_RUNNER_KUBE_VERSION=1.0.0-rc.3
# ARG DRONE_RUNNER_KUBE_BRANCH=v"$DRONE_RUNNER_KUBE_VERSION"

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
RUN git clone --branch $DRONE_SERVER_BRANCH --depth 1 https://github.com/harness/drone.git
RUN git clone --branch $DRONE_CLI_BRANCH --depth 1 https://github.com/harness/drone-cli.git
# RUN git clone --branch $DRONE_RUNNER_DOCKER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-docker.git
RUN git clone --branch $DRONE_RUNNER_EXEC_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-exec.git
# RUN git clone --branch $DRONE_RUNNER_KUBE_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-kube.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build -o release/linux/arm64/drone-server
WORKDIR /usr/lib/go/src/github.com/drone-cli
# RUN go build -o release/linux/arm64/drone-cli
# Not sure why CLI is different thant the others
RUN go install ./...
# WORKDIR /usr/lib/go/src/github.com/drone-runner-docker
# RUN go build -o release/linux/arm64/drone-runner-docker
WORKDIR /usr/lib/go/src/github.com/drone-runner-exec
RUN go build -o release/linux/arm64/drone-runner-exec
# WORKDIR /usr/lib/go/src/github.com/drone-runner-kube
# RUN go build -o release/linux/arm64/drone-runner-kube

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE: container                                                        │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/drone-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a drone CI installation."

# ╭――――――――――――――――――――╮
# │ STANDARD CONFIG    │
# ╰――――――――――――――――――――╯

# USER:
ARG USER=drone

ARG UID=1001
ARG GID=1001
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd

# PRIVILEGE:
# COPY wheel  /etc/container/wheel

# BACKUP:
COPY backup /etc/container/backup

# ENTRYPOINT:
RUN rm -v /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint

# FOLDERS
RUN /bin/chown -R $USER:$USER /mnt/volumes/container \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /var/backup \
 && /bin/chown -R $USER:$USER /tmp/backup


# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache buildah podman fuse-overlayfs git slirp4netns sqlite

RUN /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER
 
COPY --from=src-drone /usr/lib/go/src/github.com/drone/cmd/drone-server/release/linux/arm64/drone-server /usr/bin/drone-server
COPY --from=src-drone /usr/lib/go/bin/drone /usr/bin/drone
COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-exec/release/linux/arm64/drone-runner-exec /usr/bin/drone-runner-exec
# COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-docker/release/linux/arm64/drone-runner-docker /usr/bin/drone-runner-docker
# COPY --from=src-drone /usr/lib/go/src/github.com/drone-runner-kube/release/linux/arm64/drone-runner-kube /usr/bin/drone-runner-kube

RUN /bin/mkdir -p /etc/container \
 && /bin/ln -fsv /mnt/volumes/configmaps/server.env /etc/container/server.env \
 && /bin/ln -fsv /mnt/volumes/configmaps/runner-docker.env /etc/container/runner-docker.env \
 && /bin/ln -fsv /mnt/volumes/configmaps/runner-exec.env /etc/container/runner-exec.env \
 && /bin/ln -fsv /mnt/volumes/configmaps/runner-kube.env /etc/container/runner-kube.env \
 && /bin/ln -fsv /mnt/volumes/configmaps/cli.env /etc/container/cli.env \
 && /bin/ln -fsv /mnt/volumes/container/server.env /mnt/volumes/configmaps/server.env \
 && /bin/ln -fsv /mnt/volumes/container/runner-docker.env /mnt/volumes/configmaps/runner-docker.env \
 && /bin/ln -fsv /mnt/volumes/container/runner-exec.env /mnt/volumes/configmaps/runner-exec.env \
 && /bin/ln -fsv /mnt/volumes/container/runner-kube.env /mnt/volumes/configmaps/runner-kube.env \
 && /bin/ln -fsv /mnt/volumes/container/cli.env /mnt/volumes/configmaps/cli.env \
 && /bin/ln -fsv /tmp/podman-run-1002/podman/podman.sock /var/run/docker.sock

RUN /bin/touch /var/log/drone-server.log \
 && /bin/touch /var/log/drone-runner-exec.log \
 && /bin/touch /var/log/drone-runner-docker.log \
 && /bin/touch /var/log/drone-runner-kube.log
 
RUN /bin/mkdir -p /opt/$USER \
 && /bin/chown $USER:$USER -R /opt/$USER /var/log/drone-*.log

# RUN ln -s /etc/container/configmap.d /etc/drone

# Not home so the core.sqlite database is accessable via volume
RUN /bin/ln -fsv /mnt/volumes/container/core.sqlite /home/$USER/core.sqlite

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
EXPOSE 8080/tcp
EXPOSE 3000/tcp
WORKDIR /home/$USER
