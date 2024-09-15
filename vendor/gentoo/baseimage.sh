#!/bin/bash -efu

set -x

export FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"

seup_logs
setup_distfiles
setup_binpkgs

emerge-webrsync -q

emerge \
	${IMAGE_VAR_CACHE_BINPKGS:+--usepkg=y --buildpkg=y --binpkg-respect-use=y --rebuilt-binaries=y} \
	--quiet --ask=n --emptytree --update --newuse \
	@world

# https://wiki.gentoo.org/wiki/Binary_package_guide
[ -z "${IMAGE_VAR_REMOVE_BDEPS-}" ] ||
	emerge --quiet --ask=n --depclean --with-bdeps=n

restore_binpkgs
cleanup_portage /
