RELEASE=billowing-shrimp
LOCAL_YAML=temp/local.yml

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

values: ## Show generated yaml resources and values.
	helm install --dry-run --debug . -f $(LOCAL_YAML)

clean: ## Clean up environment.
	helm del --purge $(RELEASE)

clean-pvc: ## Clean disks (PVCs) too.
	kubectl get persistentvolumeclaims -l 'release=$(RELEASE)' -o json | kubectl delete -f -

install-local: ## Install helm chart on k8s.
	helm install --name $(RELEASE) . -f $(LOCAL_YAML)

upgrade-local: ## Upgrade locally deplyed release.
	helm upgrade $(RELEASE) . -f $(LOCAL_YAML)