RELEASES=$(shell helm list -q)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

values: ## Show generated yaml resources and values.
	helm install --dry-run --debug .

clean: ## Clean up environment.
	helm del --purge $(RELEASES)

install: ## Install helm chart on k8s.
	helm install --name schni .