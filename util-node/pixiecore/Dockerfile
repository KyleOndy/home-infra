FROM golang:alpine as builder

RUN apk add --no-cache make git

WORKDIR /build
RUN git clone https://github.com/danderson/netboot.git .
RUN make build

FROM golang:alpine
COPY --from=builder /go/bin/pixiecore /go/bin/pixiecore
ENTRYPOINT ["/go/bin/pixiecore"]
