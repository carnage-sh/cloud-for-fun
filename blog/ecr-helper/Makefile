SHELL = /bin/bash
MAKEFLAGS = "-s"

TARGET := ecr-helper
VERSION := $(shell head -n 1 VERSION)

.DEFAULT_GOAL := build

build:
	docker build -t $(TARGET):$(VERSION) .

clean:
	docker rmi ${TARGET}:${VERSION}

deploy:
	cat ecr-helper-deployment.yaml | sed s/AWS_ACCOUNT/${AWS_ACCOUNT}/g | \
		sed s/eu-west-1/${AWS_DEFAULT_REGION}/g | \
		kubectl apply -f -

logs:
	echo "Deployment: $$(kubectl get pod -l app=ecr-helper -n ecr-helper -o custom-columns=name:.metadata.name --no-headers)"
	kubectl logs -n ecr-helper -f $$(kubectl get pod -l app=ecr-helper -n ecr-helper -o custom-columns=name:.metadata.name --no-headers | head -n 1)

push:
	aws ecr get-login --no-include-email|sh
	docker tag ${TARGET}:${VERSION} \
		${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${TARGET}:${VERSION}
	docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${TARGET}:${VERSION}

