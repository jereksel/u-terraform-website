VERSION?="0.3.44"
MKFILE_PATH=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
DEPLOY_ENV?="development"

build:
ifeq ($(PROVIDER_PATH),)
	@echo 'Please set PROVIDER_PATH'
	exit 1
endif
ifeq ($(PROVIDER_NAME),)
	@echo 'Please set PROVIDER_NAME'
	exit 1
endif
ifeq ($(PROVIDER_SLUG),)
	$(eval PROVIDER_SLUG := $(PROVIDER_NAME))
endif
	-@rm content/source/docs/providers/$(PROVIDER_SLUG)
	-@rm content/source/layouts/$(PROVIDER_SLUG).erb
	@cd content/source/docs/providers && ln -s ../../../../../../ext/providers/$(PROVIDER_SLUG)/website/docs $(PROVIDER_SLUG)
	@cd content/source/layouts && ln -s ../../../ext/providers/$(PROVIDER_SLUG)/website/$(PROVIDER_SLUG).erb $(PROVIDER_SLUG).erb
	@echo "==> Building $(PROVIDER_NAME) provider website in Docker..."
	@docker run \
		--interactive \
		--rm \
		--tty \
		--publish "4567:4567" \
		--publish "35729:35729" \
		--volume "$(PROVIDER_PATH)/website:/website" \
		--volume "$(PROVIDER_PATH)/website:/ext/providers/$(PROVIDER_NAME)/website" \
		--volume "$(shell pwd)/ext:/ext" \
		--volume "$(shell pwd)/content:/terraform-website" \
		--volume "$(shell pwd)/content/source/assets:/website/docs/assets" \
		--volume "$(shell pwd)/content/source/layouts:/website/docs/layouts" \
		--volume "$(shell pwd)/content/build:/website/build" \
		-e "DEPLOY_ENV=${DEPLOY_ENV}" \
		--workdir /terraform-website \
		-e PROVIDER_SLUG=$(PROVIDER_SLUG) \
		hashicorp/middleman-hashicorp:${VERSION} \
		bundle exec middleman build --verbose --clean
	@rm content/source/docs/providers/$(PROVIDER_SLUG)
	@rm content/source/layouts/$(PROVIDER_SLUG).erb

website:
ifeq ($(PROVIDER_PATH),)
	@echo 'Please set PROVIDER_PATH'
	exit 1
endif
ifeq ($(PROVIDER_NAME),)
	@echo 'Please set PROVIDER_NAME'
	exit 1
endif
ifeq ($(PROVIDER_SLUG),)
	$(eval PROVIDER_SLUG := $(PROVIDER_NAME))
endif
	-@rm content/source/docs/providers/$(PROVIDER_SLUG)
	-@rm content/source/layouts/$(PROVIDER_SLUG).erb
	@cd content/source/docs/providers && ln -s ../../../../../../ext/providers/$(PROVIDER_SLUG)/website/docs $(PROVIDER_SLUG)
	@cd content/source/layouts && ln -s ../../../ext/providers/$(PROVIDER_SLUG)/website/$(PROVIDER_SLUG).erb $(PROVIDER_SLUG).erb
	@echo "==> Testing $(PROVIDER_NAME) provider website in Docker..."
	-@docker stop "tf-website-$(PROVIDER_NAME)-temp"
	@echo "==> Starting $(PROVIDER_SLUG) provider website in Docker..."
	@docker run \
		--interactive \
		--rm \
		--tty \
		--name "tf-website-$(PROVIDER_NAME)-temp" \
		--publish "4567:4567" \
		--publish "35729:35729" \
		--volume "$(PROVIDER_PATH)/website:/website" \
		--volume "$(PROVIDER_PATH)/website:/ext/providers/$(PROVIDER_NAME)/website" \
		--volume "$(shell pwd)/ext:/ext" \
		--volume "$(shell pwd)/content:/terraform-website" \
		--volume "$(shell pwd)/content/source/assets:/website/docs/assets" \
		--volume "$(shell pwd)/content/source/layouts:/website/docs/layouts" \
		--workdir /terraform-website \
		-e PROVIDER_SLUG=$(PROVIDER_SLUG) \
		hashicorp/middleman-hashicorp:${VERSION} \
		bundle exec middleman server --verbose --instrument
	@rm content/source/docs/providers/$(PROVIDER_SLUG)
	@rm content/source/layouts/$(PROVIDER_SLUG).erb

grafana:
	@cd ext/terraform-website && git submodule init ext/providers/grafana && git submodule update
	@$(MAKE) website PROVIDER_PATH=$(shell pwd)/ext/terraform-website/ext/providers/grafana PROVIDER_NAME=grafana
	@cd ext/terraform-website && git submodule deinit -f ext/providers/grafana

grafana-build:
	@cd ext/terraform-website && git submodule init ext/providers/grafana && git submodule update
	@$(MAKE) build PROVIDER_PATH=$(shell pwd)/ext/terraform-website/ext/providers/grafana PROVIDER_NAME=grafana
	@cd ext/terraform-website && git submodule deinit -f ext/providers/grafana

sync:
	@echo "==> Syncing repository"
	@git pull
	@echo "==> Syncing submodules for upstream changes"
	@git submodule update --init --remote
	@cd ext/terraform-website && git submodule init ext/terraform && git submodule update

desync:
	@echo "==> Deinitializing submodules"
	@git submodule deinit --all -f


.PHONY: sync grafana
.DEFAULT_GOAL := .PHONY