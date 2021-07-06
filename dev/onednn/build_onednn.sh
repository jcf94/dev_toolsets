#!/bin/bash

set -xe

ONEDNN_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

ONEDNN_GIT_URL="https://github.com/oneapi-src/oneDNN.git"
ONEDNN_GIT_TAG="v2.3"
ONEDNN_SRC_DIR="${ONEDNN_ROOT_PATH}/oneDNN"

BUILT_ROOT="${ONEDNN_ROOT_PATH}/built"

BUILT_ONEDNN="${BUILT_ROOT}/onednn"
BUILT_ENV="${BUILT_ROOT}/env.sh"

NUM_CORES=`grep -c ^processor /proc/cpuinfo`
NUM_CORES=$((NUM_CORES / 2))

####################################### Prepare src files

pushd ${ONEDNN_ROOT_PATH}

echo "Download OneDNN..."
if [[ ! -d ${ONEDNN_SRC_DIR} ]]; then
    git clone ${ONEDNN_GIT_URL} ${ONEDNN_SRC_DIR}
    pushd ${ONEDNN_SRC_DIR}
    git checkout ${ONEDNN_GIT_TAG}
    git submodule update --init --recursive
    popd
fi

####################################### Build

if [[ -d ${BUILT_ROOT} ]]; then
    pushd ${BUILT_ROOT}
    rm -rf *
    popd
else
    mkdir ${BUILT_ROOT}
fi

# Build OneDNN
pushd ${ONEDNN_SRC_DIR}

ONEDNN_BUILD_DIR="${ONEDNN_SRC_DIR}/build"
if [[ ! -d ${ONEDNN_BUILD_DIR} ]]; then
    mkdir ${ONEDNN_BUILD_DIR}
fi

pushd ${ONEDNN_BUILD_DIR}

CC=gcc CXX=g++ cmake -DCMAKE_BUILD_TYPE=Release ..

make -j ${NUM_CORES}

cmake -DCMAKE_INSTALL_PREFIX=${BUILT_ONEDNN} -P cmake_install.cmake

popd
popd

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export C_INCLUDE_PATH=${BUILT_ONEDNN}/include:\${C_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export CPLUS_INCLUDE_PATH=${BUILT_ONEDNN}/include:\${CPLUS_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${BUILT_ONEDNN}/lib:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_ONEDNN}/lib:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}

popd

echo "Build success!"
