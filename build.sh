#!/bin/bash

set -e

FILEPATH=$(cd "$(dirname "$0")"; pwd)

CONDA_ROOT="${FILEPATH}/conda"
CONDA_INSTALL="${CONDA_ROOT}/miniconda_install.sh"
CONDA_ENV="${CONDA_ROOT}/miniconda/env.sh"

GCC_ROOT="${FILEPATH}/gcc"
GCC_BUILD="${GCC_ROOT}/build_gcc.sh"
GCC_ENV="${GCC_ROOT}/built/env.sh"

LLVM_ROOT="${FILEPATH}/llvm"
LLVM_BUILD="${LLVM_ROOT}/build_llvm.sh"
LLVM_ENV="${LLVM_ROOT}/built/env.sh"

# Install Conda

echo "Process Conda ..."

if [[ ! -f ${CONDA_ENV} ]]; then
    pushd ${CONDA_ROOT}
    . ${CONDA_INSTALL}
    popd
fi

source ${CONDA_ENV}

conda install cmake -y

# Install GCC

echo "Process GCC ..."
if [[ ! -f ${GCC_ENV} ]]; then
    pushd ${GCC_ROOT}
    . ${GCC_BUILD}
    popd
fi

source ${GCC_ENV}

# Install LLVM

echo "Process LLVM ..."
if [[ ! -f ${LLVM_ENV} ]]; then
    pushd "${FILEPATH}/llvm"
    . ${LLVM_BUILD}
    popd
fi
