#!/bin/bash

set -xe

FILEPATH=$(cd "$(dirname "$0")"; pwd)

if [[ -d ~/.condarc ]]; then
    cp ~/.condarc ~/.condarc.back
fi

cat ${FILEPATH}/condarc >> ~/.condarc

echo "Conda source update success!"
