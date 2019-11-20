FROM golang:alpine as builder
RUN apk add --update \
      git
RUN go get github.com/ns1/waitron
ENTRYPOINT ["/go/bin/waitron"]
