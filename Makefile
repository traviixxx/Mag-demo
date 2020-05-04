RELEASE=pruning-molly
LOCAL_YAML=temp/local.yml

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

values: ## Show generated yaml resources and values.
	openssl genrsa -out temp/key.pem 1024 && openssl rsa -in temp/key.pem -pubout -out temp/pubkey.pem

	helm install --dry-run --debug -f $(LOCAL_YAML) \
	 --set magnoliaAuthor.activation.privateKey=`cat temp/key.pem | hexdump -e '"%X"'` \
	 --set magnoliaAuthor.activation.publicKey=`cat temp/pubkey.pem | hexdump -e '"%X"'` \
	 --generate-name .

clean: ## Clean up environment.
	helm del $(RELEASE)

clean-pvc: ## Clean disks (PVCs) too.
	kubectl get persistentvolumeclaims -l 'release=$(RELEASE)' -o json | kubectl delete -f -

install-local: ## Install helm chart on k8s.
	openssl genrsa -out temp/privkey.pem 1024
	openssl rsa -in temp/privkey.pem -pubout -outform DER -out temp/pubkey.der
	openssl pkcs8 -topk8 -nocrypt -in temp/privkey.pem -outform DER -out temp/privkey.der

	helm install $(RELEASE) \
	 --set magnoliaAuthor.activation.privateKey=`cat temp/privkey.der | hexdump -e '"%X"'` \
	 --set magnoliaAuthor.activation.publicKey=`cat temp/pubkey.der | hexdump -e '"%X"'` \
	 . -f $(LOCAL_YAML)

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


check-env:
ifndef REMOTE_YAML
	$(error REMOTE_YAML env var is undefined)
endif
