VENDOR = altlinux
IMAGE_PACKAGES = $(CURDIR)/packages

INFO_DATE        = $(shell date +%Y%m%d)
INFO_DIST_VENDOR = ALT
INFO_DIST_REPO   = Sisyphus

COPY_TREE = $(CURDIR)/files

all: build-image copy-tree run-scripts pack-image

include $(CURDIR)/../sysimage.mk
