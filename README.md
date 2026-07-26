# Kafka-exporter --- Dockerfile 

**FROM ghcr.io/cpsicorp/danielqsj/kafka-exporter:v1.9.0 AS base**
The Base layer is uses the existing Kafka Exporter image that is already available in the CPSICorp GitHub Container Registry (GHCR).

The image already contains:
                    Kafka Exporter executable
                    Runtime dependencies
                    Default startup configuration
                    Default entrypoint
                    
**FROM alpine:3.20 AS tools **                   
The Kafka Exporter base image is intentionally minimal and does not contain a package manager such as: yum, apt, apk
Therefore, additional packages cannot be installed directly into the Kafka Exporter image. Instead, a temporary tools stage is created to prepare any additional files required by the final image.  

**RUN apk add --no-cache ca-certificates**
This installs the latest trusted Certificate Authority (CA) certificates. These certificates are required whenever an application establishes secure TLS/SSL connections. For Kafka Exporter, this may be required when connecting to Kafka brokers configured with:
TLS
SSL
SASL_SSL

Having updated CA certificates ensures the exporter can validate the broker's server certificate during secure communication.

The --no-cache option prevents Alpine from storing package indexes, keeping the intermediate image as small as possible.

**FROM base AS release**
The final image is created from the original Kafka Exporter image rather than from Alpine. This preserves all functionality already provided by the upstream image while allowing additional files prepared in previous stages to be copied into it.

Using the base image ensures that:
                                Kafka Exporter executable remains unchanged
                                Existing runtime configuration is preserved
                                Existing startup behavior is preserved

**COPY --from=tools \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/certs/ca-certificates.crt**
This copies only the CA certificate bundle from the temporary tools stage into the final runtime image. This approach avoids copying the entire Alpine operating system, only the required certificate file is included.    

**EXPOSE 9308**
Kafka Exporter exposes Prometheus metrics on port 9308 by default.
