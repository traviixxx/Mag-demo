RELEASE=pruning-molly
LOCAL_YAML=temp/local.yml
LOCAL_YAML_S3=temp/s3-local.yml

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

values: ## Show generated yaml resources and values.
	helm install --dry-run --debug -f $(LOCAL_YAML) \
	 --generate-name .

clean: ## Clean up environment.
	helm del $(RELEASE)

clean-pvc: ## Clean disks (PVCs) too.
	kubectl get persistentvolumeclaims -l 'release=$(RELEASE)' -o json | kubectl delete -f -

gen-doc: ## Generate docs. Install helm-docs for this to work (https://github.com/norwoodj/helm-docs).
	helm-docs --template-files=docs/README.md.gotmpl

install-local: ## Install helm chart on k8s.
	helm upgrade --install $(RELEASE) . -f $(LOCAL_YAML)

install-local-s3: ## Install helm chart on k8s.
	helm upgrade --install $(RELEASE) . -f $(LOCAL_YAML_S3)

install-remote: check-env ## Install helm chart on k8s.
	helm install $(RELEASE) . -f $(REMOTE_YAML)

upgrade-local: ## Upgrade locally deployed release.
	helm upgrade $(RELEASE) . --reuse-values -f $(LOCAL_YAML)

upgrade-remote: ## Upgrade remotely deployed release.
	helm upgrade $(RELEASE) . --reuse-values -f $(REMOTE_YAML)

release: ## Release helm repo to chartmuseum
	helm dep build
	helm package .
	find . -name "magnolia-helm-*.tgz" | xargs -I {} curl -u "$CHARTMUSEUM_USER:$CHARTMUSEUM_PASS" --data-binary @$i https://charts.mirohost.ch/api/charts

test: ## Start helm tests.
	helm test --logs $(RELEASE)

template: ## Template out, do not send to k8s.
	helm template .

template-local: ## Template out, do not send to k8s.
	helm template -f $(LOCAL_YAML) .

check-env:
ifndef REMOTE_YAML
	$(error REMOTE_YAML env var is undefined)
endif
