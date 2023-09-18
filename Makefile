.EXPORT_ALL_VARIABLES:

VERBOSE =
WORKNAME = .work

WORKDIR  = $(CURDIR)/$(WORKNAME)
HOSTDIR  = $(WORKDIR)/host
HOMEDIR  = $(WORKDIR)/home

TOOLSDIR  = $(CURDIR)/tools
VENDORDIR = $(CURDIR)/vendor

ifdef VERBOSE
  verbose = -v
  Q =
  V = @
else
  verbose =
  Q = @
  V = @\#
endif

COMPRESS = raw
IMAGEFILE = $(CURDIR)/sysimage.tar

# Configuration
include $(CURDIR)/profile.mk
include $(CURDIR)/vendor/$(VENDOR)/config.mk

CHROOTABLE_VARIABLES = VENDOR INSTALL_LANGS EXCLUDE_DOCS \
		       verbose

IMAGE_BASEIMAGE = localhost/$(VENDOR)-baseimage:latest
IMAGE_SYSIMAGE  = localhost/$(VENDOR)-sysimage:latest

# Rules
all:
	@echo "This makefile is designed to generate an image of the root filesystem of"
	@echo "a specific Linux distribution vendor."
	@echo ""
	@echo "Report bugs to authors."
	@echo ""

prepare:
	@mkdir -p -- "$(HOSTDIR)"
	@$(TOOLSDIR)/generate-podman-storage-conf

clean:
	$(Q)source $(HOMEDIR)/env && podman image rm -a -f
	$(Q)source $(HOMEDIR)/env && podman system prune -a -f
	$(Q)rm -rf -- "$(WORKDIR)"

clean-image:
	$(Q)source $(HOMEDIR)/env && podman image rm -f "$(IMAGE)"

list-images: prepare
	$(Q)source $(HOMEDIR)/env && podman images

build-baseimage: prepare
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

build-sysimage: build-baseimage
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

pack-sysimage: build-sysimage
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@
	@echo ""
	@echo "Image is saved as $(IMAGEFILE)"
	@echo ""

run:
	$(Q)source $(HOMEDIR)/env && podman container run --rm -ti "$(IMAGE)" /bin/bash

