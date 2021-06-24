#!/bin/bash

set -xe

pip install pip -U

pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

echo "Pypi source update success!"
