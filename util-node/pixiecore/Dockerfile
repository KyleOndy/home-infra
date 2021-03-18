FROM golang:alpine as builder

RUN apk add --no-cache make git

WORKDIR /build
RUN git clone  --single-branch --branch rpi4 https://github.com/KyleOndy/netboot .
RUN make build

FROM golang:alpine
COPY --from=builder /go/bin/pixiecore /go/bin/pixiecore
ENTRYPOINT ["/go/bin/pixiecore"]
