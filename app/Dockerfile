FROM golang:1.26-alpine AS builder
RUN apk add --no-cache git ca-certificates
WORKDIR /build
RUN git clone https://github.com/TwiN/gatus.git . && \
 go mod tidy -diff && \
 CGO_ENABLED=0 GOOS=linux go build -o gatus .


FROM scratch
COPY --from=builder /build/gatus /gatus
COPY --from=builder /build/config.yaml ./config/config.yaml
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV GATUS_CONFIG_PATH=""
ENV GATUS_LOG_LEVEL="INFO"
ENV PORT="8080"
EXPOSE ${PORT}
ENTRYPOINT ["/gatus"]
