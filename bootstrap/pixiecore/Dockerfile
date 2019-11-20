FROM golang:alpine as builder
RUN apk add --update \
      git
RUN go get go.universe.tf/netboot/cmd/pixiecore


FROM alpine
COPY --from=builder /go/bin/pixiecore /app/
WORKDIR /app
ENTRYPOINT ["./pixiecore"]
