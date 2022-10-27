#!/bin/bash

set -eo pipefail

path="$1"

if [[ ! -d "$path" ]]; then
    echo "::error ::Invalid path: [$path]"
    exit 1
fi

outputwarning() {
    local warnings="$1"
    if [[ -n "$warnings" ]]; then
        warnings="${warnings//'%'/'%25'}"
        warnings="${warnings//$'\n'/'%0A'}"
        warnings="${warnings//$'\r'/'%0D'}"
        echo "::warning::$warnings"
    fi
}

abspath="$(realpath "$path")"

echo "::group::Move files to $HOME"
HOME=/home/build
cd "$HOME"
cp -r "$abspath" .
cd "$(basename "$abspath")"
echo "::endgroup::"

echo "::group::Source PKGBUILD"
source PKGBUILD
echo "::endgroup::"

echo "::group::Install depends"
paru -Syu --removemake --needed --noconfirm "${depends[@]}" "${makedepends[@]}"
echo "::endgroup::"

echo "::group::Remove paru and git"
sudo pacman -Rns --noconfirm paru-bin git || true
echo "::endgroup::"

echo "::group::List all installed packages"
pacman -Q
echo "::endgroup::"

echo "::group::Make package"
logfile=$(mktemp)
makepkg -s --noconfirm 2>&1 | tee "$logfile"
warn="$(grep WARNING "$logfile" || true)"
outputwarning "$warn"
echo "::endgroup::"

echo "::group::Show package info"
source /etc/makepkg.conf # get PKGEXT
files=("${pkgname}-"*"${PKGEXT}")
pkgfile="${files[0]}"
echo "pkgfile=${pkgfile}" >> "$GITHUB_OUTPUT"
pacman -Qip "${pkgfile}"
pacman -Qlp "${pkgfile}"
echo "::endgroup::"

echo "::group::Install namcap"
sudo pacman -S --needed --noconfirm namcap
echo "::endgroup::"

echo "::group::Run namcap checks"
outputwarning "$(namcap PKGBUILD)"
outputwarning "$(namcap "${pkgfile}")"
echo "::endgroup::"

sudo mv "$pkgfile" /github/workspace

echo "::group::Generate .SRCINFO"
makepkg --printsrcinfo > .SRCINFO
sudo mv .SRCINFO "$abspath"
echo "::endgroup::"
