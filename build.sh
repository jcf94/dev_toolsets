#!/bin/bash

set -e

FILEPATH=$(cd "$(dirname "$0")"; pwd)

CONDA_INSTALL="${FILEPATH}/shell/miniconda_install.sh"
CONDA_ENV="${FILEPATH}/shell/miniconda/bin/activate"

GCC_BUILD="${FILEPATH}/gcc/build_gcc.sh"
GCC_ENV="${FILEPATH}/gcc/built/env.sh"

LLVM_BUILD="${FILEPATH}/llvm/build_llvm.sh"
LLVM_ENV="${FILEPATH}/llvm/built/env.sh"

# Install Conda

echo "Process Conda ..."

if [[ ! -f ${CONDA_ENV} ]]; then
    bash ${CONDA_INSTALL}
fi

source ${CONDA_ENV}

conda install cmake -y

# Install GCC

echo "Process GCC ..."
if [[ ! -f ${GCC_ENV} ]]; then
    bash ${GCC_BUILD}
fi

source ${GCC_ENV}

# Install LLVM

echo "Process LLVM ..."
if [[ ! -f ${LLVM_ENV} ]]; then
    bash ${LLVM_BUILD}
fi

