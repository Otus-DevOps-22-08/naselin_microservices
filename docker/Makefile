TARGETS := comment post ui prometheus
USER_NAME ?= naselin

.PHONY : build-all push-all build-comment build-post build-ui build-prometheus push-one start restart

build-all:
	$(foreach TARGET,$(TARGETS),$(MAKE) build-$(TARGET);)

push-all:
	$(foreach TARGET,$(TARGETS),$(MAKE) push-one target=$(TARGET);)

build-comment:
	docker build -f ../src/comment/Dockerfile -t $(USER_NAME)/comment ../src/comment

build-post:
	docker build -f ../src/post-py/Dockerfile -t $(USER_NAME)/post ../src/post-py

build-ui:
	docker build -f ../src/ui/Dockerfile -t $(USER_NAME)/ui ../src/ui

build-prometheus:
	docker build -f ../monitoring/prometheus/Dockerfile -t $(USER_NAME)/prometheus ../monitoring/prometheus

push-one:
	docker push $(USER_NAME)/$(target)

start:
	docker-compose up -d

restart:
	docker-compose down
	docker-compose up -d
