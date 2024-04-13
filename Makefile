# Docker containers
PHP_CONTAINER = frankenphp_symfo_7

# Executables (local)
DOCKER = docker
DOCKER_COMP = docker-compose
DOCKER_EXEC = docker exec
PHP_EXEC = $(DOCKER_EXEC) $(PHP_CONTAINER)

# Executables
PHP      = $(PHP_EXEC) php
COMPOSER = $(PHP_EXEC) composer
SYMFONY  = $(PHP_EXEC) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down logs sh composer vendor sf cc

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

init: down init-network up install-vendors ## Build and start the containers

reset: down up install-vendors ## Reset the project by installing or updating the php/js vendors

init-network: ## Create project docker network if not exists
	@$(DOCKER) network create symfony_7 || echo "Don't worry! We can continue..."

up: ## Start the docker's containers
	@$(DOCKER_COMP) up -d --build

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

php: ## Enter PHP container as root
	@echo "Entering PHP container..."
	$(DOCKER_EXEC) -it $(PHP_CONTAINER) /bin/bash

install-vendors:
	@$(PHP_EXEC) /usr/local/bin/install-vendors.sh

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf