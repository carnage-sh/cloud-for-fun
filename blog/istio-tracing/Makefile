SHELL := /bin/bash

TARGET := istio-tracing
DESTDIR := build
GO := CGO_ENABLED=0 go
VERSION := $(shell head -n 1 VERSION)

.DEFAULT_GOAL := build

.PHONY: build
build:
	@mkdir -p build
	@${GO} build -a --installsuffix cgo -o ${DESTDIR}/${TARGET} \
	    -ldflags "-X main.version=${VERSION}" .

.PHONY: docker
docker:
	@docker build -t istio-tracing:latest  .

.PHONY: test
test:
	@go test -race ./... -short -cover
