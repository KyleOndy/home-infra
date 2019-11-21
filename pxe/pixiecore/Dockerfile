FROM golang:alpine as builder
RUN apk add --update \
      git
RUN go get go.universe.tf/netboot/cmd/pixiecore
ENTRYPOINT ["/go/bin/pixiecore"]
