#!/bin/bash

set -eo pipefail

path="$1"

if [[ ! -d "$path" ]]; then
    echo "::error ::Invalid path: [$path]"
    exit 1
fi

abspath="$(realpath "$path")"

HOME=/home/build
echo "::group::Move files to $HOME"
cd "$HOME"
cp -r "$abspath" .
cd "$(basename "$abspath")"
echo "::endgroup::"

echo "::group::Check PKGBUILD"
warnings=$(namcap PKGBUILD)
if [[ -n "$warnings" ]]; then
    warnings="${warnings//'%'/'%25'}"
    warnings="${warnings//$'\n'/'%0A'}"
    warnings="${warnings//$'\r'/'%0D'}"
    echo "::warning file=$path/PKGBUILD::$warnings"
fi
source PKGBUILD
echo "::endgroup::"

echo "::group::Install depends"
paru -Syu --needed --noconfirm "${depends[@]}" "${makedepends[@]}"
echo "::endgroup::"

echo "::group::Remove paru and git"
sudo pacman -Rns --noconfirm paru-bin git || true
echo "::endgroup::"

echo "::group::List all installed packages"
pacman -Q
echo "::endgroup::"

echo "::group::Make the package"
makepkg -s --noconfirm
source /etc/makepkg.conf # get PKGEXT
files=("${pkgname}-"*"${PKGEXT}")
pkgfile="${files[0]}"
echo "::set-output name=pkgfile::${pkgfile}"
echo "::endgroup::"

echo "::group::Check the package"
warnings=$(namcap "${pkgfile}")
if [[ -n "$warnings" ]]; then
    warnings="${warnings//'%'/'%25'}"
    warnings="${warnings//$'\n'/'%0A'}"
    warnings="${warnings//$'\r'/'%0D'}"
    echo "::warning::$warnings"
fi
pacman -Qip "${pkgfile}"
pacman -Qlp "${pkgfile}"
sudo mv "$pkgfile" /github/workspace
echo "::endgroup::"

echo "::group::Generate .SRCINFO"
makepkg --printsrcinfo > .SRCINFO
sudo mv .SRCINFO "$abspath"
echo "::endgroup::"
