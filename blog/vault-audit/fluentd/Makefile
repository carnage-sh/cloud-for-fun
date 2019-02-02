.DEFAULT_GOAL := build
VERSION := $(shell head -n 1 VERSION)
PROJECT := custom-fluentd

.PHONY: build
build:
	docker build -t ${PROJECT}:${VERSION} .
	docker tag ${PROJECT}:${VERSION} ${PROJECT}:latest

