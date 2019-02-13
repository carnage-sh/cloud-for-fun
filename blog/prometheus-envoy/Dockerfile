FROM consul:1.4.2 as consul
FROM envoyproxy/envoy:v1.8.0
COPY --from=consul /bin/consul /bin/consul
ENTRYPOINT ["dumb-init", "consul"]
