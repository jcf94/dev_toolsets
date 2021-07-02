#!/bin/bash

set -e

FILEPATH=$(cd "$(dirname "$0")"; pwd)

CONDA_ENV="${FILEPATH}/conda/miniconda/env.sh"
GCC_ENV="${FILEPATH}/gcc/built/env.sh"
LLVM_ENV="${FILEPATH}/llvm/built/env.sh"

# Check Conda

if [[ -f ${CONDA_ENV} ]]; then
    echo "Conda env [found]. Activate."
    source ${CONDA_ENV}
else
    echo "Conda env [not found]."
fi

# Check GCC

if [[ -f ${GCC_ENV} ]]; then
    echo "GCC env   [found]. Activate."
    source ${GCC_ENV}
else
    echo "GCC env   [not found]."
fi

# Check LLVM

if [[ -f ${LLVM_ENV} ]]; then
    echo "LLVM env  [found]. Activate."
    source ${LLVM_ENV}
else
    echo "LLVM env  [not found]."
fi

