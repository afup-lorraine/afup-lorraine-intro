.DEFAULT_GOAL := help
PORT ?= 8000

.PHONY: help new serve test

help: ## Affiche cette aide
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

new: ## Crée le deck d'un nouveau mois (questions posées dans le terminal)
	@./bin/new-deck.sh

serve: ## Sert le dépôt en HTTP (port 8000, modifiable avec PORT=...)
	@echo "Decks disponibles sur http://localhost:$(PORT)/"
	@python3 -m http.server $(PORT)

test: ## Vérifie les scripts (shellcheck) et rejoue les scénarios du générateur
	@shellcheck bin/*.sh
	@./bin/test-new-deck.sh
