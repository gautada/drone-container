ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION as src

# ╭――――――――――――――――――――╮
# │ VERSION(S)         │
# ╰――――――――――――――――――――╯
ARG CONTAINER_VERSION="1.0.0"
ARG DRONE_RUNNER="exec"
ARG DRONE_VERSION="$CONTAINER_VERSION"
ARG DRONE_BRANCH=v"$DRONE_VERSION"

ARG CGO_CFLAGS="-D_LARGEFILE64_SOURCE"

RUN apk add --no-cache build-base git go sqlite-dev

RUN git config --global advice.detachedHead false
RUN mkdir -p /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com

RUN echo "$DRONE_BRANCH -- $DRONE_RUNNER"
RUN git clone --branch $DRONE_BRANCH --depth 1 https://github.com/harness/drone.git

WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
# RUN /usr/bin/go mod download github.com/hashicorp/go-rootcerts
RUN /usr/bin/go build -o release/linux/arm64/drone-server

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE: container                                                        │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM docker.io/gautada/alpine:$ALPINE_VERSION as container

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/drone-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a drone installation with commandline with the exec kube runners"


# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=drone
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges
# COPY wheel  /etc/container/wheel
# RUN /bin/ln -fsv /etc/container/wheel /etc/sudoers.d/wheel

# BACKUP:
RUN /bin/rm -f /etc/periodic/hourly/container-backup
# COPY backup /etc/container/backup

# ENTRYPOINT:
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache  sqlite
# buildah podman fuse-overlayfs git slirp4netns
 
COPY --from=src /usr/lib/go/src/github.com/drone/cmd/drone-server/release/linux/arm64/drone-server /usr/bin/drone-server

RUN /bin/ln -fsv /mnt/volumes/configmaps/drone-server.env /etc/container/drone-server.env \
 && /bin/ln -fsv /mnt/volumes/container/drone-server.env /mnt/volumes/configmaps/drone-server.env

# COPY .envs.conf /mnt/volumes/container/drone-server.env

RUN /bin/ln -fsv /mnt/volumes/container/core.sqlite /home/$USER/core.sqlite

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER
USER $USER

VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER
