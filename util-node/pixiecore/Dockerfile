# can't use 3.13 for now
# https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements
FROM golang:alpine3.12 as builder

RUN apk add --no-cache make git

WORKDIR /build
RUN git clone https://github.com/danderson/netboot.git .
RUN make build

FROM golang:alpine3.12
COPY --from=builder /go/bin/pixiecore /go/bin/pixiecore
ENTRYPOINT ["/go/bin/pixiecore"]
