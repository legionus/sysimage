# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023  Alexey Gladkov <gladkov.alexey@gmail.com>

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
CACHEDIR ?= $(WORKDIR)/cache
OUTDIR ?= $(CURDIR)/result

ifeq "$(VENDOR)" ""
  $(info variable VENDOR required)
endif

include $(VENDORDIR)/$(VENDOR)/vendor.mk

# build-instrumental
INSTRUMENTAL_FILES ?=
INSTRUMENTAL_PACKAGES ?=
INSTRUMENTAL_PACKAGES2 ?=

# copy-tree
COPY_TREE ?= $(CURDIR)/files

# apply-patches
IMAGE_PATCHES ?= $(CURDIR)/image-patches.d

# run-scripts
IMAGE_SCRIPTDIR ?= $(CURDIR)/image-scripts.d

# pack-sysimage
USE_SQUASHFS ?=
SQUASHFS_ARGS ?=
COMPRESS ?=
IMAGENAME ?= sysimage.tar

IMAGE_INSTRUMENTAL = localhost/$(VENDOR)-instrumental
IMAGE_BASEIMAGE = localhost/$(VENDOR)-baseimage
IMAGE_SYSIMAGE  = localhost/$(VENDOR)-image

SYSIMAGE_TAG_PREFIX ?=

# Rules
help:
	@echo "This makefile is designed to generate an image of the root filesystem of"
	@echo "a specific Linux distribution vendor."
	@echo ""
	@echo "Report bugs to authors."
	@echo ""

prepare:
	@mkdir -p -- "$(HOSTDIR)" "$(CACHEDIR)/$(VENDOR)"
	@$(TOOLSDIR)/generate-podman-storage-conf

clean:
	$(Q)if [ -f "$(HOMEDIR)/env" ]; then \
	  source $(HOMEDIR)/env && \
	  podman image rm -a -f && \
	  podman system prune -a -f; \
	fi
	$(Q)[ ! -d "$(WORKDIR)" ] || \
	  ! chmod -R u+rwx "$(WORKDIR)" || \
	  rm -rf -- "$(WORKDIR)"

clean-image:
	$(Q)source $(HOMEDIR)/env && podman image rm -f "$(IMAGE)"

reset-image:
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

list-images: prepare
	$(Q)source $(HOMEDIR)/env && podman images

list-tree: prepare
	$(Q)source $(HOMEDIR)/env && podman image tree "$(IMAGE_SYSIMAGE)"

build-instrumental: prepare
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

import-image: build-instrumental
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

# Create baseimage if needed. When importing an image, we create data in a
# directory and pack it. At this stage we perform actions within this image. For
# some vendors this step is not needed.
build-baseimage: build-instrumental import-image
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

# This stage should be named as install-packages
build-image: import-image build-baseimage
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

copy-tree: build-baseimage
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

run-scripts: build-baseimage
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

apply-patches: build-baseimage
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

pack-image: build-baseimage
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

run-image:
	$(V)echo "processing $@ ..."
	@env PATH="$(TOOLSDIR):$$PATH" $(TOOLSDIR)/$@

run:
	$(Q)source $(HOMEDIR)/env && podman container run --rm -ti "$(IMAGE)" /bin/bash

