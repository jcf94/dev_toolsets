#!/bin/bash

set -xe

FILEPATH=$(cd "$(dirname "$0")"; pwd)

pushd ${FILEPATH}

MINICONDA_SH="Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_URL="https://repo.anaconda.com/miniconda/${MINICONDA_SH}"

if [[ ! -f ${MINICONDA_SH} ]]; then
    curl -L -o ${MINICONDA_SH} ${MINICONDA_URL}
fi

chmod +x ${MINICONDA_SH}

./${MINICONDA_SH} -b -f -p `pwd`/miniconda

popd

echo "Install success!"
