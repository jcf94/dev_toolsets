#!/bin/bash

set -xe

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Change the Theme to ys
sed 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' ~/.zshrc -i

