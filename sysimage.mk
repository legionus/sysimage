.EXPORT_ALL_VARIABLES:

VERBOSE =
WORKNAME = .work

PROJECTDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TOOLSDIR  = $(PROJECTDIR)/tools
VENDORDIR = $(PROJECTDIR)/vendor

ifdef VERBOSE
  verbose = -v
  Q =
  V = @
else
  verbose =
  Q = @
  V = @\#
endif

# Current work directory
WORKDIR := $(CURDIR)/$(WORKNAME)
HOSTDIR := $(WORKDIR)/host
HOMEDIR := $(WORKDIR)/home

ifeq "$(VENDOR)" ""
  $(info variable VENDOR required)
endif

# run-scripts
IMAGE_SCRIPTDIR ?= $(CURDIR)/image-scripts.d

# pack-sysimage
COMPRESS  ?= raw
IMAGEFILE ?= $(CURDIR)/sysimage.tar

# Vendor-specific configuration
include $(VENDORDIR)/$(VENDOR)/config.mk

CHROOTABLE_VARIABLES = VENDOR INSTALL_LANGS EXCLUDE_DOCS \
		       verbose

IMAGE_BASEIMAGE = localhost/$(VENDOR)-baseimage:latest
IMAGE_SYSIMAGE  = localhost/$(VENDOR)-image:latest

# Rules
help:
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

build-image: build-baseimage
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

run-scripts: build-image
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

pack-image: build-image
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@
	@echo ""
	@echo "Image is saved as $(IMAGEFILE)"
	@echo ""

run:
	$(Q)source $(HOMEDIR)/env && podman container run --rm -ti "$(IMAGE)" /bin/bash
