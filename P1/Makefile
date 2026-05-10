# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: student <student@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/05/10                              #+#    #+#              #
#                                                                              #
# **************************************************************************** #

COMPOSE = docker compose
PROJECT = inception-network

# Colors
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
RESET  = \033[0m

all: build up

# -----------------------------------------------------------------------------#
# Docker
# -----------------------------------------------------------------------------#

build:
	@echo "$(YELLOW)Building docker images...$(RESET)"
	$(COMPOSE) build

up:
	@echo "$(GREEN)Starting containers...$(RESET)"
	$(COMPOSE) up -d

down:
	@echo "$(RED)Stopping containers...$(RESET)"
	$(COMPOSE) down

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

# -----------------------------------------------------------------------------#
# Router helpers
# -----------------------------------------------------------------------------#

router-shell:
	docker exec -it router1 sh

basic-shell:
	docker exec -it basic-container sh

router-ps:
	docker exec -it router1 ps aux

router-vtysh:
	docker exec -it router1 vtysh

# -----------------------------------------------------------------------------#
# Network helpers
# -----------------------------------------------------------------------------#

network-inspect:
	docker network inspect project_net1

router-ip:
	docker exec -it router1 ip addr

# -----------------------------------------------------------------------------#
# Cleanup
# -----------------------------------------------------------------------------#

clean:
	@echo "$(RED)Removing containers...$(RESET)"
	$(COMPOSE) down -v

fclean: clean
	@echo "$(RED)Removing images...$(RESET)"
	docker rmi -f basic-image || true
	docker rmi -f router-image || true

re: fclean all

# -----------------------------------------------------------------------------#
# Vagrant
# -----------------------------------------------------------------------------#

vagrant-up:
	vagrant up

vagrant-ssh:
	vagrant ssh

vagrant-halt:
	vagrant halt

vagrant-destroy:
	vagrant destroy -f

# -----------------------------------------------------------------------------#
# Status
# -----------------------------------------------------------------------------#

status:
	@echo "$(GREEN)===== DOCKER CONTAINERS =====$(RESET)"
	@docker ps
	@echo ""
	@echo "$(GREEN)===== DOCKER NETWORKS =====$(RESET)"
	@docker network ls