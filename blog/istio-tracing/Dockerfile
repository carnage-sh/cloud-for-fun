FROM golang:1 as builder

COPY . /app/
WORKDIR /app
RUN make

FROM debian:stretch

WORKDIR /app

COPY --from=builder /app/build/istio-tracing /app/

CMD ["/app/istio-tracing"]