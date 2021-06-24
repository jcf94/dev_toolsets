#!/bin/bash

set -xe

if [[ -d ~/.fzf ]]; then
    echo "Dir exist, check if fzf has already been installed."
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    echo "Install success!"
fi
