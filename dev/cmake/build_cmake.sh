#!/bin/bash

set -xe

CMAKE_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

CMAKE_VERSION="3.21.3"
CMAKE_DIR="cmake-${CMAKE_VERSION}"
CMAKE_TAR="${CMAKE_DIR}.tar.gz"
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_TAR}"

BUILT_ROOT="${CMAKE_ROOT_PATH}/built"

BUILT_CMAKE="${BUILT_ROOT}/cmake"
BUILT_ENV="${BUILT_ROOT}/env.sh"

NUM_CORES=`grep -c ^processor /proc/cpuinfo`
NUM_CORES=$((NUM_CORES / 2))

####################################### Prepare src files

pushd ${CMAKE_ROOT_PATH}

echo "Download CMAKE..."
if [[ ! -f ${CMAKE_TAR} ]]; then
    curl -L -o ${CMAKE_TAR} ${CMAKE_URL}
fi
echo "Uncompress CMAKE..."
if [[ ! -d ${CMAKE_DIR} ]]; then
    tar xf ${CMAKE_TAR}
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

pushd ${CMAKE_DIR}
./configure --prefix=${BUILT_CMAKE}
make -j ${NUM_CORES}
make install
popd

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export PATH=${BUILT_CMAKE}/bin:\${PATH}" >> ${BUILT_ENV}

echo "Build success!"
