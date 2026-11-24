#Stage 1 - Build Gatus
FROM golang:1.26-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /build

# Pin App Version
ARG GATUS_VERSION=v5.38.0

RUN git clone --branch "${GATUS_VERSION}" --depth 1 https://github.com/TwiN/gatus.git .

# Compile without C libraries
RUN CGO_ENABLED=0 GOOS=linux go build -o gatus .

# Stage 2 - Minimal runtime image
FROM scratch

COPY --from=builder /build/gatus /gatus
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY /config.yaml /config/config.yaml

# Run as a non-root yser
USER 65534:65534

ENV GATUS_CONFIG_PATH="/config/config.yaml"
ENV GATUS_LOG_LEVEL="INFO"
ENV PORT="8080"

EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
