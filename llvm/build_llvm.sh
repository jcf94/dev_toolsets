#!/bin/bash

set -ex

FILEPATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

LLVM_PROJECT_DIR="llvm-project-12.0.0.src"
LLVM_PROJECT_TAR="${LLVM_PROJECT_DIR}.tar.xz"
LLVM_PROJECT_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/${LLVM_PROJECT_TAR}"

BUILT_ROOT="${FILEPATH}/built"
LLVM_ENABLE_PROJECTS="clang"

BUILT_LLVM="${BUILT_ROOT}/llvm"
BUILT_ENV="${BUILT_ROOT}/env.sh"

####################################### Prepare src files

pushd ${FILEPATH}

echo "Download LLVM..."
if [[ ! -f ${LLVM_PROJECT_TAR} ]]; then
    curl -L -o ${LLVM_PROJECT_TAR} ${LLVM_PROJECT_URL}
fi
echo "Uncompress LLVM..."
if [[ ! -d ${LLVM_PROJECT_DIR} ]]; then
    tar xf ${LLVM_PROJECT_TAR}
fi

####################################### Build

if [[ -d ${BUILT_ROOT} ]]; then
    pushd ${BUILT_ROOT}
    rm -rf *
    popd
else
    mkdir ${BUILT_ROOT}
fi

# Build LLVM
pushd ${LLVM_PROJECT_DIR}
LLVM_DIR="`pwd`/llvm"

pushd ${LLVM_DIR}
LLVM_BUILD_DIR="${LLVM_DIR}/build"
if [[ ! -d ${LLVM_BUILD_DIR} ]]; then
    mkdir ${LLVM_BUILD_DIR}
fi

pushd ${LLVM_BUILD_DIR}
CC=gcc CXX=g++ cmake -DLLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS} -DCMAKE_BUILD_TYPE=Release .. && make -j && cmake -DCMAKE_INSTALL_PREFIX=${BUILT_LLVM} -P cmake_install.cmake

popd
popd
popd

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_LLVM}/lib:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${BUILT_LLVM}/bin:\${PATH}" >> ${BUILT_ENV}

popd

echo "Build success!"
