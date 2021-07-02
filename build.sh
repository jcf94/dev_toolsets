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

CONDA_STATUS="Installed"
CONDA_START=`date +%s`

if [[ ! -f ${CONDA_ENV} ]]; then
    pushd ${CONDA_ROOT}
    . ${CONDA_INSTALL}
    popd
    CONDA_STATUS="Success"
fi

CONDA_END=`date +%s`

source ${CONDA_ENV}

conda install cmake -y

# Install GCC

echo "Process GCC ..."

GCC_STATUS="Built"
GCC_START=`date +%s`

if [[ ! -f ${GCC_ENV} ]]; then
    pushd ${GCC_ROOT}
    . ${GCC_BUILD}
    popd
    GCC_STATUS="Success"
fi

GCC_END=`date +%s`

source ${GCC_ENV}

# Install LLVM

echo "Process LLVM ..."

LLVM_STATUS="Built"
LLVM_START=`date +%s`

if [[ ! -f ${LLVM_ENV} ]]; then
    pushd ${LLVM_ROOT}
    . ${LLVM_BUILD}
    popd
    LLVM_STATUS="Success"
fi

LLVM_END=`date +%s`

# Print Results

echo "Conda\t[${CONDA_STATUS}]\tCosts: $((CONDA_END-CONDA_START)) s"
echo "GCC\t[${GCC_STATUS}]\tCosts: $((GCC_END-GCC_START)) s"
echo "LLVM\t[${LLVM_STATUS}\tCosts: $((LLVM_END-LLVM_START)) s"

