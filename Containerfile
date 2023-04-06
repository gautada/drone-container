ARG ALPINE_VERSION=latest

# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                         │
# │ STAGE 1: Build drone from source                                        │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as src

# ╭――――――――――――――――――――╮
# │ VERSION(S)         │
# ╰――――――――――――――――――――╯
ARG DRONE_SERVER_VERSION=2.15.0
ARG DRONE_SERVER_BRANCH=v"$DRONE_SERVER_VERSION"

# ARG DRONE_CLI_VERSION=1.6.2
# ARG DRONE_CLI_BRANCH=v"$DRONE_CLI_VERSION"

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

# RUN git clone --branch $DRONE_CLI_BRANCH --depth 1 https://github.com/harness/drone-cli.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build -o release/linux/arm64/drone-server

# WORKDIR /usr/lib/go/src/github.com/drone-cli
# # RUN go build -o release/linux/arm64/drone-cli
# # Not sure why CLI is different thant the others
# RUN go install ./...

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
LABEL description="This container is a a drone installation with commandline with the exec kube runners"

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
# RUN /sbin/apk add --no-cache build-base yarn npm git openssh-client openssh
RUN /sbin/apk add --no-cache  sqlite
# buildah podman fuse-overlayfs git slirp4netns
 
COPY --from=src /usr/lib/go/src/github.com/drone/cmd/drone-server/release/linux/arm64/drone-server /usr/bin/drone-server

# COPY --from=src /usr/lib/go/bin/drone /usr/bin/drone

RUN /bin/mkdir -p /etc/container

RUN /bin/ln -fsv /mnt/volumes/configmaps/drone-server.env /etc/container/drone-server.env \
 && /bin/ln -fsv /mnt/volumes/container/drone-server.env /mnt/volumes/configmaps/drone-server.env
 
# RUN /bin/ln -fsv /mnt/volumes/configmaps/drone-cli.env /etc/container/drone-cli.env \
#  && /bin/ln -fsv /mnt/volumes/container/drone-cli.env /mnt/volumes/configmaps/drone-cli.env
 
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
WORKDIR /home/$USER

# ╭――――――――――――――――――――╮
# │ CONFIGRE          │
# ╰――――――――――――――――――――╯
# RUN /usr/bin/yarn global add wetty
