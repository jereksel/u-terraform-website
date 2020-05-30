# μ-terraform-website

[Upstream](https://github.com/hashicorp/terraform-website/) compatible builder for terraform provider websites.

## Differences between upstream

- Only builds provider websites
- Automatic redirect from `/` to provider website
- Much smaller and simpler to debug (I couldn't get upstream to work due to https://github.com/hashicorp/terraform-website/issues/3)

## How to use

Add following lines to provider's GNUMakefile/Makefile

```make
U_WEBSITE_REPO=github.com/jereksel/u-terraform-website

website:
ifeq (,$(wildcard $(GOPATH)/src/$(U_WEBSITE_REPO)))
	echo "$(U_WEBSITE_REPO) not found in your GOPATH (necessary for layouts and assets), get-ting..."
	git clone https://$(U_WEBSITE_REPO) $(GOPATH)/src/$(U_WEBSITE_REPO)
endif
	@$(MAKE) -C $(GOPATH)/src/$(WEBSITE_REPO) website PROVIDER_PATH=$(shell pwd) PROVIDER_NAME=$(PKG_NAME)

website-build:
ifeq (,$(wildcard $(GOPATH)/src/$(U_WEBSITE_REPO)))
	echo "$(U_WEBSITE_REPO) not found in your GOPATH (necessary for layouts and assets), get-ting..."
	git clone https://$(U_WEBSITE_REPO) $(GOPATH)/src/$(U_WEBSITE_REPO)
endif
	@$(MAKE) -C $(GOPATH)/src/$(U_WEBSITE_REPO) build PROVIDER_PATH=$(shell pwd) PROVIDER_NAME=$(PKG_NAME)
```