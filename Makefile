.EXPORT_ALL_VARIABLES:

VERBOSE =
WORKNAME = .work

WORKDIR  = $(CURDIR)/$(WORKNAME)
HOSTDIR  = $(WORKDIR)/host
HOMEDIR  = $(WORKDIR)/home
TEMPDIR  = $(WORKDIR)/tmp

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

CHROOTABLE_VARIABLES = VENDOR PKG_INIT_LIST INSTALL_LANGS EXCLUDE_DOCS \
		       verbose

IMAGE_BASEIMAGE = localhost/$(VENDOR):baseimage
IMAGE_BOOTSTRAP = localhost/$(VENDOR):bootstrap
IMAGE_SYSTEM    = localhost/$(VENDOR):system
IMAGE_SYSIMAGE  = localhost/$(VENDOR):sysimage

# Rules
all:
	@echo "This makefile is designed to generate an image of the root filesystem of"
	@echo "a specific Linux distribution vendor."
	@echo ""
	@echo "Report bugs to authors."
	@echo ""

prepare:
	@mkdir -p -- "$(HOSTDIR)" "$(TEMPDIR)"
	@$(TOOLSDIR)/generate-podman-storage-conf

clean:
	$(Q)$(TOOLSDIR)/podman image rm -a -f
	$(Q)$(TOOLSDIR)/podman system prune -a -f
	$(Q)rm -rf -- "$(WORKDIR)"

clean-image:
	$(Q)$(TOOLSDIR)/podman image rm -f "$(IMAGE)"

list-images: prepare
	$(Q)$(TOOLSDIR)/podman images

build-baseimage: prepare
	@$(TOOLSDIR)/$@

build-bootstrap: build-baseimage
	@$(TOOLSDIR)/$@

build-sysimage: build-bootstrap
	@$(TOOLSDIR)/$@

pack-sysimage: build-sysimage
	@$(TOOLSDIR)/$@
	@echo ""
	@echo "Image is saved as $(IMAGEFILE)"
	@echo ""

run:
	$(Q)$(TOOLSDIR)/podman container run --rm -ti "$(IMAGE)" /bin/bash

