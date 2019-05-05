FROM golang AS build
COPY . /src/
RUN cd /src && go build -o kevent .

FROM debian:stretch
WORKDIR /app
COPY --from=build /src/kevent /app/kevent
ENTRYPOINT ["/app/kevent"]
EXPOSE 8080

