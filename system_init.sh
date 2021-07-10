#!/bin/bash

set -xe

FILEPATH=$(cd "$(dirname "$0")"; pwd)

SYS_NAME="centos"
SYS_BASIC="${FILEPATH}/system/${SYS_NAME}_install_basic.sh"

SHELL_DIR="${FILEPATH}/shell"
SHELL_ZSH="${SHELL_DIR}/ohmyzsh_install.sh"
SHELL_FZF="${SHELL_DIR}/fzf_install.sh"

# System basic requirements

. ${SYS_BASIC}

# Shell

. ${SHELL_ZSH}

. ${SHELL_FZF}
