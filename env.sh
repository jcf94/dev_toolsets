#!/bin/bash

FILEPATH=$(cd "$(dirname "$0")"; pwd)

GCC_ENV="${FILEPATH}/dev/gcc/built/env.sh"
CONDA_ENV="${FILEPATH}/dev/conda/miniconda/env.sh"
LLVM_ENV="${FILEPATH}/dev/llvm/built/env.sh"
ONEDNN_ENV="${FILEPATH}/dev/onednn/built/env.sh"
CUDA_ENV="${FILEPATH}/dev/cuda/cuda/env.sh"
GPERFTOOLS_ENV="${FILEPATH}/dev/gperftools/built/env.sh"

# Check GCC

if [[ -f ${GCC_ENV} ]]; then
    echo "GCC env           [found]. Activate."
    source ${GCC_ENV}
else
    echo "GCC env           [not found]."
fi

# Check Conda

if [[ -f ${CONDA_ENV} ]]; then
    echo "Conda env         [found]. Activate."
    source ${CONDA_ENV}
else
    echo "Conda env         [not found]."
fi

# Check LLVM

if [[ -f ${LLVM_ENV} ]]; then
    echo "LLVM env          [found]. Activate."
    source ${LLVM_ENV}
else
    echo "LLVM env          [not found]."
fi

# Check OneDNN

if [[ -f ${ONEDNN_ENV} ]]; then
    echo "OneDNN env        [found]. Activate."
    source ${ONEDNN_ENV}
else
    echo "OneDNN env        [not found]."
fi

# Check CUDA

if [[ -f ${CUDA_ENV} ]]; then
    echo "CUDA env          [found]. Activate."
    source ${CUDA_ENV}
else
    echo "CUDA env          [not found]."
fi

# Check GPerfTools

if [[ -f ${GPERFTOOLS_ENV} ]]; then
    echo "GPerfTools env    [found]. Activate."
    source ${GPERFTOOLS_ENV}
else
    echo "GPerfTools env    [not found]."
fi
