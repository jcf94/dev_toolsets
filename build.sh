#!/bin/bash

set -e

FILEPATH=$(cd "$(dirname "$0")"; pwd)

CONDA_ROOT="${FILEPATH}/dev/conda"
CONDA_INSTALL="${CONDA_ROOT}/miniconda_install.sh"
CONDA_ENV="${CONDA_ROOT}/miniconda/env.sh"

GCC_ROOT="${FILEPATH}/dev/gcc"
GCC_BUILD="${GCC_ROOT}/build_gcc.sh"
GCC_ENV="${GCC_ROOT}/built/env.sh"

LLVM_ROOT="${FILEPATH}/dev/llvm"
LLVM_BUILD="${LLVM_ROOT}/build_llvm.sh"
LLVM_ENV="${LLVM_ROOT}/built/env.sh"

ONEDNN_ROOT="${FILEPATH}/dev/onednn"
ONEDNN_BUILD="${ONEDNN_ROOT}/build_onednn.sh"
ONEDNN_ENV="${ONEDNN_ROOT}/built/env.sh"

CUDA_ROOT="${FILEPATH}/dev/cuda"
CUDA_INSTALL="${CUDA_ROOT}/cuda_install.sh"
CUDA_ENV="${CUDA_ROOT}/cuda/env.sh"
CUDA_VERSION="11.4"

CONDA_ON="1"
GCC_ON="1"
LLVM_ON="1"
ONEDNN_ON="0"
CUDA_ON="0"

CONDA_STATUS="SKIP"
GCC_STATUS="SKIP"
LLVM_STATUS="SKIP"
ONEDNN_STATUS="SKIP"
CUDA_STATUS="SKIP"

####################################### Process parameters

function usage() {
    echo "./build.sh    [-h|--help]         Help"
    echo "              [-a|--all]          Build & Install all the dev envs"
    echo "              [-o|--onednn]       Build OneDNN"
    echo "              [-c|--cuda] [11.4]  Install CUDA with specified version. 11.4 by default"
    echo "              [--no-conda]        Do not install Conda."
    echo "              [--no-gcc]          Do not build GCC."
    echo "              [--no-llvm]         Do not build LLVM."
}

options=$(getopt -l "help,all,onednn,cuda:,no-conda,no-gcc,no-llvm" -o "haoc:" -a -- "$@")

echo "$options"

eval set -- "$options"

while true; do
    case "${1}" in
        -h|--help)
            usage
            exit 0
            ;;
        -a|--all)
            CONDA_ON="1"
            GCC_ON="1"
            LLVM_ON="1"
            ONEDNN_ON="1"
            CUDA_ON="1"
            shift
            ;;
        -o|--onednn)
            ONEDNN_ON="1"
            shift
            ;;
        -c|--cuda)
            CUDA_ON="1"
            echo "${2}"
            if [[ "${2}" == -* ]]; then
                shift
            else
                CUDA_VERSION="${2}"
                shift 2
            fi
            ;;
        --no-conda)
            CONDA_ON="0"
            shift
            ;;
        --no-gcc)
            GCC_ON="0"
            shift
            ;;
        --no-llvm)
            LLVM_ON="0"
            shift
            ;;
        --)
            shift
            break;;
    esac
done

####################################### Process build & install

# Install GCC
GCC_START=`date +%s`
if [[ "${GCC_ON}" == "1" ]]; then
    echo "Process GCC ..."

    GCC_STATUS="Already Built"

    if [[ ! -f ${GCC_ENV} ]]; then
        pushd ${GCC_ROOT}
        . ${GCC_BUILD}
        popd
        GCC_STATUS="Success"
    fi

    source ${GCC_ENV}
else
    echo "Skip GCC."
fi
GCC_END=`date +%s`

# Install Conda
CONDA_START=`date +%s`
if [[ "${CONDA_ON}" == "1" ]]; then
    echo "Process Conda ..."

    CONDA_STATUS="Installed"

    if [[ ! -f ${CONDA_ENV} ]]; then
        pushd ${CONDA_ROOT}
        . ${CONDA_INSTALL}
        popd
        CONDA_STATUS="Success"
    fi

    source ${CONDA_ENV}

    conda install cmake -y
else
    echo "Skip Conda."
fi
CONDA_END=`date +%s`

# Install LLVM
LLVM_START=`date +%s`
if [[ "${LLVM_ON}" == "1" ]]; then
    echo "Process LLVM ..."

    LLVM_STATUS="Already Built"    

    if [[ ! -f ${LLVM_ENV} ]]; then
        pushd ${LLVM_ROOT}
        . ${LLVM_BUILD}
        popd
        LLVM_STATUS="Success"
    fi

else
    echo "Skip LLVM."
fi
LLVM_END=`date +%s`



####################################### Print Results

set +x

echo -e "Conda\t[${CONDA_STATUS}]\tCosts: $((CONDA_END-CONDA_START)) s"
echo -e "GCC\t[${GCC_STATUS}]\tCosts: $((GCC_END-GCC_START)) s"
echo -e "LLVM\t[${LLVM_STATUS}]\tCosts: $((LLVM_END-LLVM_START)) s"
