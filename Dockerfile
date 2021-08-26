FROM alpine:3.14.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM config-alpine as config-droneci

RUN apk add --no-cache build-base git go

RUN git config --global advice.detachedHead false

RUN mkdir /usr/lib/go/src/github.com
WORKDIR /usr/lib/go/src/github.com
RUN git clone --branch v2.1.0 --depth 1 https://github.com/drone/drone.git
WORKDIR /usr/lib/go/src/github.com/drone/cmd/drone-server
RUN go build


WORKDIR /

FROM alpine:3.14.1

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

COPY --from=config-droneci /usr/lib/go/src/github.com/drone/cmd/drone-server/drone-server /usr/bin/drone-server

# COPY config.env /etc/droneci/config.env

ENTRYPOINT ["/usr/bin/drone-server"]
CMD ["--env-file=/etc/droneci/config.env"]
