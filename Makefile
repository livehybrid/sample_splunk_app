SHELL := /bin/bash
pwd := ${PWD}
dirname := $(notdir $(patsubst %/,%,$(CURDIR)))
SPLUNK_HOST ?= localhost
.DEFAULT_GOAL := list

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

APP_ID:
 APP_ID:= $(shell poetry run crudini --get package/default/app.conf package id)

list: help

help: ## Show this help message.
	@echo 'usage: make [target] ...'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' $(MAKEFILE_LIST) | column -t -c 2 -s ':#' | sed 's/^/  /'

tmp/:
	mkdir -p ./tmp

clean-tests: ## Remove any previous test files/logs
	@rm -rf ./tmp/reports || true
	@rm -rf ./tmp/events.pickle || true
	@rm -f *_events.lock || true
	@rm -f *_events || true
	@rm -f helmut.log || true
	@rm -f generator.lock || true
	@rm -f pytest_splunk_addon.log || true
	@rm -rf ./assets || true
	@rm -rf ./.pytest_cache || true
	@rm -rf .tokenized_events

clean-build: ## Remove any previous app build/packaging/dist output
	@rm -rf ./build || true
	@rm -rf ./dist || true
	@rm -rf ./output || true

clean: ## Remove local build (clean-build), test (clean-tests), docker (clean-docker) + result data
clean: clean-tests clean
	@rm -rf ./tmp || true

clean-venv: ## Remove the Python virtualenv
	@rm -rf ./.venv || true

clean-docker: ## Remove unused docker volumes (use with care)
	poetry run docker volume prune -f

clean-all: ## Deep clean! (venv/docker/build/test/output)
clean-all: clean-venv clean clean-docker

reinstall: ## Perform a Deep clean (clean-all) followed by an install
reinstall: clean-all install

git-init-submodules: ## Initialise the submodules configured in .gitmodules
	mkdir -p ./_submodules || true
	git submodule sync
	git submodule update --init

splunk-btool: ## Generate a btool output from the current running splunk docker container
	# No response with exit code = 0 is Good.
	docker-compose exec splunk /bin/sh -c 'sudo /opt/splunk/bin/splunk btool check'

splunk-restart: ## Restart the splunk process in the current running splunk docker container
	docker-compose exec splunk /bin/sh -c 'sudo /opt/splunk/bin/splunk restart'

install: ## Run repo installation (Poetry install)
	poetry install

update: ## Update poetry as per local config
	poetry update

docker-build: ## Build Splunk docker container ready for side-loading of application and testing
	@\
	COMPOSE_DOCKER_CLI_BUILD=1 \
	DOCKER_BUILDKIT=1 \
	BUILDKIT_PROGRESS=plain \
	poetry run docker-compose build \
		--build-arg HOST_UID="$$(id -u)" \
		--build-arg HOST_GID="$$(id -g)" \
		--pull

down: ## Shutdown and remove docker containers assosicated with this app/repo
	poetry run docker-compose down --remove-orphans

up: ## Start docker containers associated with this app/folder as defined in docker-compose.yml
up: APP_ID
	APP_ID=${APP_ID} poetry run docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d
	poetry run scripts/wait-for-log-line.sh splunk 'Ansible playbook complete'

up-ci: ## Start docker containers (CI Only)
	poetry run scripts/ci-up.sh $(APP_ID)

#up-ci:
#	poetry run docker-compose up -d
#	docker network connect $(docker inspect $(docker-compose ps -q splunk) -f '{{json .NetworkSettings.Networks }}' | jq -r 'keys[]' | head -n 1 ) $(grep -o -P -m1 'docker.*\K[0-9a-f]{64,}' /proc/self/cgroup)
##	scripts/wait-for-log-line.sh splunk 'Ansible playbook complete'

test: ## Run PyTest against the Splunk application
test: tmp/ clean-tests splunk-ports-output
	poetry run pytest --splunk-host=$(SPLUNK_HOST) --splunk-port=$(PORTSPLUNKREST) --splunk-hec-port=$(PORTSPLUNKHEC) --splunkweb-port=$(PORTSPLUNKWEB)

build: ## Determine if UCC/Basic application and create app output
build: clean-build APP_ID
	@echo "building"
	@# If it is a UCC app then use ucc-gen else run custom build code
	[ -f ./globalConfig.json ] && poetry run ucc-gen || poetry run scripts/build.sh
	mv output/$(APP_ID) output/app

release: ## Create application release
release: dist APP_ID

dist: build
	mv output/app output/$(APP_ID)
	@echo "packaging"
	mkdir -p tmp/reports
	poetry run scripts/package.sh
	mv output/$(APP_ID) output/app

splunk-ports:
	@$(eval PORTSPLUNKWEB=$(shell poetry run docker-compose port splunk 8000 2>/dev/null | cut -d":" -f 2))
	@$(eval PORTSPLUNKREST=$(shell poetry run docker-compose port splunk 8089 2>/dev/null | cut -d":" -f 2))
	@$(eval PORTSPLUNKHEC=$(shell poetry run docker-compose port splunk 8088 2>/dev/null | cut -d":" -f 2))

splunk-ports-output: ## Print dynamic docker Splunk ports (Web/REST/HEC) to stdout
splunk-ports-output: splunk-ports
	@echo Splunk Web is running at http://localhost:$(PORTSPLUNKWEB)
	@echo Splunk REST is running at https://localhost:$(PORTSPLUNKREST)
	@echo Splunk HEC is running at https://localhost:$(PORTSPLUNKHEC)

splunk-cloud-upload: ## Upload application to SplunkCloud - Requires stack=<stackName>
splunk-cloud-upload: guard-stack
	@echo "Upload to SplunkCloud"
	@echo $(stack)
	poetry run ./scripts/doUpload.sh $(stack)
