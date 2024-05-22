#!/bin/bash -efu

set -x

export PKGDIR=/.host/cache/binpkgs
export DISTDIR=/.host/cache/distfiles
export FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"

emerge-webrsync -q

[ ! -d "$PKGDIR" ] ||
	emaint binhost --fix

emerge \
	--quiet --ask=n --emptytree \
	--update --usepkg=y --buildpkg=y \
	--newuse --rebuilt-binaries=y --binpkg-respect-use=y \
	@world

# https://wiki.gentoo.org/wiki/Binary_package_guide
[ -z "${IMAGE_VAR_REMOVE_BDEPS-}" ] ||
	emerge --quiet --ask=n --depclean --with-bdeps=n
