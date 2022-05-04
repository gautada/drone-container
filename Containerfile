ARG ALPINE_VERSION=3.15.4
ARG PODMAN_VERSION=3.4.7

FROM gautada/alpine:$ALPINE_VERSION as config-drone

ARG DRONE_BRANCH=v2.11.1
ARG RUNNER_BRANCH=v1.0.0-rc.3
ARG CLI_BRANCH=v0.0.0

RUN apk add --no-cache build-base git go
RUN git config --global advice.detachedHead false

RUN mkdir /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $DRONE_BRANCH --depth 1 https://github.com/drone/drone.git
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $RUNNER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-kube.git
WORKDIR /usr/lib/go/src/github.com/drone-runner-kube
RUN go test ./...
ENV CGO_ENABLED=0
RUN set -e
RUN set -x
RUN GOOS=linux GOARCH=arm64
RUN go build -o release/linux/arm64/drone-runner-kube


WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $CLI_BRANCH --depth 1 https://github.com/drone/drone-cli.git
WORKDIR /usr/lib/go/src/github.com/drone-cli
RUN go install ./...

#

# ------------------------------------------------------------- CONTAINER
FROM gautada/podman:$PODMAN_VERSION as build-drone

USER root
WORKDIR /

LABEL source="https://github.com/gautada/drone-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a drone CI installation."

EXPOSE 8080
EXPOSE 3000

COPY --from=config-drone /etc/localtime /etc/localtime
COPY --from=config-drone /etc/timezone  /etc/timezone
COPY --from=config-drone /usr/lib/go/src/github.com/drone/cmd/drone-server/drone-server /usr/bin/drone-server
COPY --from=config-drone /usr/lib/go/src/github.com/drone-runner-kube/release/linux/arm64/drone-runner-kube /usr/bin/drone-runner-kube
COPY --from=config-drone /usr/lib/go/bin/drone /usr/bin/drone

RUN touch /eoo
COPY entrypoint /entrypoint

RUN mkdir -p /opt/drone-data
RUN touch /opt/drone-data/core.sqlite

ARG USER=drone
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "%wheel         ALL = (ALL) NOPASSWD: /usr/sbin/crond" >> /etc/sudoers \
 && usermod -aG wheel $USER \
 && echo "$USER:$USER" | chpasswd \
 && chown $USER:$USER -R /opt/drone-data

USER $USER
WORKDIR /home/$USER

# RUN chmod 777 -R /opt/drone-data
# ARG USER=drone
# RUN addgroup $USER \
#  && adduser -D -s /bin/sh -G $USER $USER \
#  && echo "$USER:$USER" | chpasswd
#

#
# RUN ln -s /opt/drone-data/core.sqlite ~/core.sqlite
#

COPY config.env /etc/drone/config.env
ENTRYPOINT ["/entrypoint"]
# CMD ["/usr/bin/drone-server", "--env-file", "/etc/drone/config.env"]
CMD ["server"]
