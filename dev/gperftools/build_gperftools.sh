#!/bin/bash

set -xe

GPREFTOOLS_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

GPREFTOOLS_VERSION="2.10"
GPREFTOOLS_DIR="gperftools-${GPREFTOOLS_VERSION}"
GPREFTOOLS_TAR="${GPREFTOOLS_DIR}.tar.gz"
GPREFTOOLS_URL="https://github.com/gperftools/gperftools/releases/download/${GPREFTOOLS_DIR}/${GPREFTOOLS_TAR}"

BUILT_ROOT="${GPREFTOOLS_ROOT_PATH}/built"

BUILT_GPREFTOOLS="${BUILT_ROOT}/gperftools"
BUILT_ENV="${BUILT_ROOT}/env.sh"

NUM_CORES=6 #`grep -c ^processor /proc/cpuinfo`
NUM_CORES=$((NUM_CORES / 2))

####################################### Prepare src files

pushd ${GPREFTOOLS_ROOT_PATH}

echo "Download GPREFTOOLS..."
if [[ ! -f ${GPREFTOOLS_TAR} ]]; then
    curl -L -o ${GPREFTOOLS_TAR} ${GPREFTOOLS_URL}
fi
echo "Uncompress GPREFTOOLS..."
if [[ ! -d ${GPREFTOOLS_DIR} ]]; then
    tar xf ${GPREFTOOLS_TAR}
fi

####################################### Build

if [[ -d ${BUILT_ROOT} ]]; then
    pushd ${BUILT_ROOT}
    rm -rf *
    popd
else
    mkdir ${BUILT_ROOT}
fi

# Build Cmake

pushd ${GPREFTOOLS_DIR}
./configure --prefix=${BUILT_GPREFTOOLS}
make -j ${NUM_CORES}
make install
popd

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export C_INCLUDE_PATH=${BUILT_GPREFTOOLS}/include:\${C_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export CPLUS_INCLUDE_PATH=${BUILT_GPREFTOOLS}/include:\${CPLUS_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${BUILT_GPREFTOOLS}/lib:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_GPREFTOOLS}/lib:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${BUILT_GPREFTOOLS}/bin:\${PATH}" >> ${BUILT_ENV}

echo "Build success!"
