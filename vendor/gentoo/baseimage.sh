#!/bin/bash -efu

set -x

export FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"

emerge_common=( ${IMAGE_VAR_EMERGE_QUIET:+-q} --ask=n --verbose-conflicts )
emerge_automask=( --autounmask=y --autounmask-write=y --autounmask-use=y --autounmask-continue=y )
emerge_changed_use=( --newuse --changed-use --changed-slot --changed-deps )
emerge_binpkgs=( --usepkg=y --buildpkg=y --binpkg-respect-use=y --rebuilt-binaries=y )
emerge_parallel=(
	${IMAGE_VAR_EMERGE_JOBS:+--jobs="$IMAGE_VAR_EMERGE_JOBS"}
	${IMAGE_VAR_EMERGE_LOAD_AVERAGE:+--load-average="$IMAGE_VAR_EMERGE_LOAD_AVERAGE"}
)

set -- "${emerge_common[@]}" "${emerge_automask[@]}" "${emrege_changed_use[@]}" "${emerge_parallel[@]}"
[ -z "${IMAGE_VAR_CACHE_BINPKGS-}" ] || set -- "$@" "${emerge_binpkgs[@]}"

seup_logs
setup_distfiles
setup_binpkgs

emerge-webrsync -q

run_with_message "rebuild baseimage ..." \
emerge "$@" --emptytree --update @world

# https://wiki.gentoo.org/wiki/Binary_package_guide
[ -z "${IMAGE_VAR_REMOVE_BDEPS-}" ] ||
	run_with_message "remove build deps ..." \
	emerge --quiet --ask=n --depclean --with-bdeps=n

remove_binpkgs_conf
cleanup_portage /
