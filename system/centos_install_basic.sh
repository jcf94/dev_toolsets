#!/bin/bash

set -xe

if [[ `lsb_release -i -s` != "CentOS" ]]; then
    echo "Currently not in Centos. exit."
    exit -1
fi

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
    "ncdu"
)

for tool in ${TOOL_LIST[*]}; do
    yum install ${tool} -y
    done
