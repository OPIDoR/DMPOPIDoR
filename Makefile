SHELL := /bin/bash
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null || echo "docker compose")
COMPOSE_FILE_PROD := docker-compose.yml
COMPOSE_FILE_DEV := docker-compose-dev.yml
COMPOSE_FILE := $(if $(filter prod,$(env)),$(COMPOSE_FILE_PROD),$(if $(filter dev,$(env)),$(COMPOSE_FILE_PROD) -f $(COMPOSE_FILE_DEV)))

help: ## Command help
	@echo "Usage: make [COMMAND] [OPTIONS]"
	@echo ""
	@echo "Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Options:"
	@echo "  env                            Application environment: prod or dev (e.g env=prod)"
	@echo "  adapter                        Database adapter: postgres or mysql (e.g adapter=postgres)"

check_env:
ifndef env
	$(error Please specify an environment (prod or dev) (eg: make build env=prod))
endif
ifeq (,$(filter $(env),prod dev))
	$(error Invalid environment specified. Please use 'prod' or 'dev'.)
endif

check_adapter:
ifndef adapter
	$(error Please specify an adapter (postgres or mysql) (eg: make setup env=prod adapter=postgres))
endif
ifeq (,$(filter $(adapter),postgres mysql))
	$(error Invalid adapter specified. Please use 'postgres' or 'mysql'.)
endif

check_docker_compose:
ifeq ($(strip $(DOCKER_COMPOSE)),)
	$(error 'docker-compose' or 'docker compose' command not found. Please make sure Docker Compose is installed.)
endif

define docker_action
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) $(1)
endef

setup: check_env check_adapter check_docker_compose ## Setup DMPOPIDoR configuration (env: prod or dev, adapter: postgres or mysql)
	$(call docker_action,run --rm dmpopidor sh -c 'ruby bin/docker $(adapter)')
	$(call docker_action,run --rm dmpopidor sh -c 'ruby bin/docker db:setup')

build: check_env check_docker_compose ## Build docker image (env: prod or dev)
	$(call docker_action,build dmpopidor)

run: check_env check_docker_compose ## Run services (env: prod or dev)
	$(call docker_action,up -d)

stop: check_env check_docker_compose ## Stop services (env: prod or dev)
	$(call docker_action,stop)

directus_setup: check_env check_docker_compose ## Setup Directus database
	$(call docker_action,up -d postgres)
	$(call docker_action,exec -it postgres sh -c "psql -U $${DB_USERNAME:-postgres} -c 'drop database $${DIRECTUS_DATABASE:-directus};'")
	$(call docker_action,exec -it postgres sh -c "psql -U $${DB_USERNAME:-postgres} -c 'create database $${DIRECTUS_DATABASE:-directus};'")
	$(call docker_action,cp ./directus/dump.sql postgres:/directus.sql)
	$(call docker_action,exec -it postgres sh -c "psql -U $${DB_USERNAME:-postgres} $${DIRECTUS_DATABASE:-directus} < directus.sql")

push_translations: check_env check_docker_compose ## Push translations onto transaltion.io
	$(call docker_action,exec -it dmpopidor sh -c "DOMAIN=client rails translation:sync_and_show_purgeable")

pull_translations: check_env check_docker_compose ## Pull translations from transaltion.io
	$(call docker_action,exec -it dmpopidor sh -c "DOMAIN=client rails translation:sync_and_purge")

.PHONY: help check_env check_adapter check_docker_compose setup build run stop
