ARG ALPINE_TAG=3.14.1

FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

# ------------------------------------------------------------- BUILD DRONECI
FROM alpine:$ALPINE_TAG as config-droneci
ARG SERVER_BRANCH=v0.0.0
ARG RUNNER_BRANCH=v0.0.0
ARG CLI_BRANCH=v0.0.0

RUN apk add --no-cache build-base git go

RUN git config --global advice.detachedHead false

RUN mkdir /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $SERVER_BRANCH --depth 1 https://github.com/drone/drone.git
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $RUNNER_BRANCH --depth 1 https://github.com/drone-runners/drone-runner-kube.git
WORKDIR /usr/lib/go/src/github.com/drone-runner-kube
RUN go test ./...
ENV CGO_ENABLED=0
RUN set -e
RUN set -x
RUN GOOS=linux GOARCH=arm64 go build -o release/linux/arm64/drone-runner-kube

WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch $CLI_BRANCH --depth 1 https://github.com/drone/drone-cli.git
WORKDIR /usr/lib/go/src/github.com/drone-cli
RUN go install ./...


WORKDIR /

FROM alpine:$ALPINE_TAG

EXPOSE 8080
EXPOSE 3000

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

COPY --from=config-droneci /usr/lib/go/src/github.com/drone/cmd/drone-server/drone-server /usr/bin/drone-server
COPY --from=config-droneci /usr/lib/go/src/github.com/drone-runner-kube/release/linux/arm64/drone-runner-kube /usr/bin/drone-runner-kube
COPY --from=config-droneci /usr/lib/go/bin/drone /usr/bin/drone

RUN mkdir -p /opt/droneci-data \
 && touch /opt/droneci-data/core.sqlite && \
 && chmod 777 -R /opt/droneci-data
 
ARG USER=droneci
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd
 
USER $USER

RUN ln -s /opt/droneci-data/core.sqlite

