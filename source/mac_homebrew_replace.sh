#!/bin/bash

set -e

SOURCE="tuna"
BREW_TAPS="$(brew tap)"
BREW_BASE=""
BREW_LIST=""
BREW_ROOT=""

####################################### Process parameters

function usage() {
    echo "./mac_homebrew_replace.sh     [-h]            Help"
    echo "                              [-s tuna|ustc]  Set source"
}

while getopts "hs:" arg
do
    case "${arg}" in
        s)
            SOURCE="$2"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

if [[ "${SOURCE}" == "tuna" ]]; then
    BREW_BASE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    BREW_LIST="core cask cask-fonts cask-drivers cask-versions"
    BREW_ROOT="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew"
elif [[ "${SOURCE}" == "ustc" ]]; then
    BREW_BASE="https://mirrors.ustc.edu.cn/brew.git"
    BREW_LIST="core cask cask-versions"
    BREW_ROOT="https://mirrors.ustc.edu.cn/homebrew"
else
    echo "Unsupported source: ${SOURCE}"
    exit 1
fi

####################################### Update source

echo "Homebrew source update to \"${SOURCE}\""

git -C "$(brew --repo)" remote set-url origin ${BREW_BASE}

for tap in ${BREW_LIST}; do
    if echo "${BREW_TAPS}" | grep -qE "^homebrew/${tap}\$"; then
        git -C "$(brew --repo homebrew/${tap})" remote set-url origin "${BREW_ROOT}-${tap}.git"
        git -C "$(brew --repo homebrew/${tap})" config homebrew.forceautoupdate true
    else
        brew tap --force-auto-update homebrew/${tap} "${BREW_ROOT}-${tap}.git"
    fi
done

brew update-reset

echo "Homebrew source update to \"${SOURCE}\" success!"
