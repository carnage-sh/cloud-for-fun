.DEFAULT_GOAL := build
VERSION := $(shell node -p -e "require('./version.json').version")
PROJECT := $(shell node -p -e "require('./package.json').name")

.PHONY: build
build:
	docker build -t ${PROJECT}:${VERSION} .
	docker tag ${PROJECT}:${VERSION} ${PROJECT}:latest

