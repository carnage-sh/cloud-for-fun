.DEFAULT_GOAL := build
VERSION := $(shell node -p -e "require('./version.json').version")

.PHONY: build
build:
	docker build -t simpleapi:${VERSION} .

