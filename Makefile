# Date : 25/09/21
# Edited by Arthur Djikpo

.DEFAULT_GOAL := help

.PHONY: help ## Generate list of targets with descriptions
help:
	@grep '##' Makefile \
	| grep -v 'grep\|sed' \
	| sed 's/^\.PHONY: \(.*\) ##[\s|\S]*\(.*\)/\1:\t\2/' \
	| sed 's/\(^##\)//' \
	| sed 's/\(##\)/\t/' \
	| expand -t14

.PHONY: env ## Create environment files & SSH keys
env:
	#cp .env.example .env
	ssh-keygen -f githosting_rsa
	echo "Please fill environment files, then use make vagrant"

.PHONY: vagrant ## Run the vm
vagrant:
	vagrant up --provision

.PHONY: reload ## Reload the vm
reload:
	vagrant reload --provision

.PHONY: stop ## Stop the vm
stop:
	vagrant halt