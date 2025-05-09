IMAGE_VAR_INIT_PACKAGES = setup filesystem rpm apt apt-https ca-certificates
IMAGE_VAR_CACHE_REPOS ?= 1

ifneq ($(IMAGE_VAR_CACHE_REPOS),)
  EXTRA_VOLUMES += -v $(CACHEDIR)/$(VENDOR):/.host/cache:z
endif
