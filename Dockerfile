FROM ghcr.io/cpsicorp/danielqsj/kafka-exporter:v1.9.0 AS base

FROM alpine:3.20 AS tools

RUN apk add --no-cache ca-certificates

FROM base AS release

COPY --from=tools \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/certs/ca-certificates.crt

EXPOSE 9308