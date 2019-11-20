FROM golang:alpine as builder
RUN apk add --update \
      git
RUN go get go.universe.tf/netboot/cmd/pixiecore
WORKDIR /images/
COPY ./images .
ENTRYPOINT ["/go/bin/pixiecore"]
