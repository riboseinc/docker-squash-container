.PHONY: all login build run pull_build pull push push_latest tag_latest docker-squash-exists

NS_LOCAL := ribose
NS_REMOTE ?= $(NS_LOCAL)
NAME := docker-squash
VERSION := 1.0.7
SHELL := /bin/bash

BASE_IMAGE_TAG := centos:7.5.1804
IMAGE_TAG_LATEST := $(NS_REMOTE)/$(NAME):latest
IMAGE_TAG_WITH_VER := $(NS_REMOTE)/$(NAME):$(VERSION)

DOCKER_RUN := docker run
DOCKER_SQUASH_IMG := $(NS_REMOTE)/docker-squash
DOCKER_SQUASH_CMD := $(DOCKER_RUN) --rm \
  -v $(shell which docker):/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /docker_tmp $(DOCKER_SQUASH_IMG)

DOCKER_LOGIN_USERNAME ?=
DOCKER_LOGIN_PASSWORD ?=
DOCKER_LOGIN_CMD ?= "docker login --username=$(DOCKER_LOGIN_USERNAME) --password=\"$(DOCKER_LOGIN_PASSWORD)\""

all: pull_build pull build squash
postall: tag_latest push push_latest

login:
	eval $(DOCKER_LOGIN_CMD)

build:
	docker build -t $(IMAGE_TAG_WITH_VER) --rm .

run:
	docker run -it $(IMAGE_TAG_LATEST) bash

pull_build: login
	docker pull $(BASE_IMAGE_TAG)

pull: login
	docker pull $(IMAGE_TAG_LATEST)

push: login
	docker push $(IMAGE_TAG_WITH_VER)

push_latest:
	docker push $(IMAGE_TAG_LATEST)

tag_latest:
	docker tag $(IMAGE_TAG_WITH_VER) $(IMAGE_TAG_LATEST)

docker-squash-exists:
	if [ -z "$$(docker history -q $(DOCKER_SQUASH_IMG))" ]; then \
		docker pull $(DOCKER_SQUASH_IMG); \
	fi

squash:	docker-squash-exists
	export from_image=$$(head -1 Dockerfile | cut -f 2 -d ' ') && \
	$(DOCKER_SQUASH_CMD) -t $(IMAGE_TAG_WITH_VER) \
		-f "$$from_image" \
		$(IMAGE_TAG_WITH_VER)
