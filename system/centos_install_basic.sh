#!/bin/bash

set -xe

# Install basic dev tools
yum groupinstall "Development Tools" -y

# Other tools
TOOL_LIST=(
    "epel-release"
    "htop"
    "tmux"
    "vim"
    "git"
    "zsh"
    "cmake"
)

for tool in ${TOOL_LIST[*]}; do
    yum install ${tool} -y
    done

