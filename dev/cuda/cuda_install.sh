#!/bin/bash

set -e

CUDA_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

CUDA_VERSION="11.4.0"
DRIVER_VERSION="470.42.01"
CUDNN_TAR=""
TRT_DIR=""
TRT_TAR=""

BUILT_ROOT="${CUDA_ROOT_PATH}/cuda"
BUILT_ENV="${BUILT_ROOT}/env.sh"

OVERRIDE_BUILT="0"

####################################### Process parameters

function usage() {
    echo "./cuda_install.sh [-h]                                    Help"
    echo "                  [-f]                                    Force install and override"
    echo "                  [-v 11.4|11.3|11.2|11.1|11.0|10.2]      Set source"
}

while getopts "hv:f" arg
do
    case "${arg}" in
        v)
            case "$2" in
                "11.4")
                    CUDA_VERSION="11.4.0"
                    DRIVER_VERSION="470.42.01"
                    ;;
                "11.3")
                    CUDA_VERSION="11.3.1"
                    DRIVER_VERSION="465.19.01"
                    # CUDNN 8.2.1
                    # TRT 8.0.1.6
                    CUDNN_TAR="cudnn-11.3-linux-x64-v8.2.1.32.tgz"
                    TRT_DIR="TensorRT-8.0.1.6"
                    TRT_TAR="${TRT_DIR}.Linux.x86_64-gnu.cuda-11.3.cudnn8.2.tar.gz"
                    ;;
                "11.2")
                    CUDA_VERSION="11.2.2"
                    DRIVER_VERSION="460.32.03"
                    # CUDNN 8.2.1
                    # TRT 8.2.2.1
                    CUDNN_TAR="cudnn-11.3-linux-x64-v8.2.1.32.tgz"
                    TRT_DIR="TensorRT-8.2.2.1"
                    TRT_TAR="${TRT_DIR}.Linux.x86_64-gnu.cuda-11.4.cudnn8.2.tar.gz"
                    ;;
                "11.1")
                    CUDA_VERSION="11.1.1"
                    DRIVER_VERSION="455.32.00"
                    ;;
                "11.0")
                    CUDA_VERSION="11.0.2"
                    DRIVER_VERSION="450.51.05"
                    ;;
                "10.2")
                    CUDA_VERSION="10.2.89"
                    DRIVER_VERSION="440.33.01"
                    ;;
                *)
                    echo "Cuda version not supported: ${2}"
                    exit 1
                    ;;
            esac
            ;;
        f)
            OVERRIDE_BUILT="1"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

BUILT_ROOT_LN="${BUILT_ROOT}_${CUDA_VERSION}"

echo "Install CUDA with version: ${CUDA_VERSION} driver: ${DRIVER_VERSION}"

####################################### Download and prepare resources

pushd ${CUDA_ROOT_PATH}

CUDA_SH="cuda_${CUDA_VERSION}_${DRIVER_VERSION}_linux.run"
CUDA_URL="https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/${CUDA_SH}"

if [[ ! -f ${CUDA_SH} ]]; then
    echo "Downloading CUDA install package ..."
    curl -L -o ${CUDA_SH} ${CUDA_URL}
fi

chmod +x ${CUDA_SH}

if [[ -d ${BUILT_ROOT} ]]; then
    if [[ ${OVERRIDE_BUILT} == "1" ]]; then
        rm -rf ${BUILT_ROOT}
        rm -rf ${BUILT_ROOT_LN}
    else
        echo "CUDA already installed in ${BUILT_ROOT}, set -f to override it."
    fi
else
    OVERRIDE_BUILT="1"
fi

if [[ ${OVERRIDE_BUILT} == "1" ]]; then
    echo "Extracting and installing CUDA files ..."
    ./${CUDA_SH} --installpath="${BUILT_ROOT}" --silent --toolkit --override

    if [[ ${CUDNN_TAR} != "" && -f ${CUDNN_TAR} ]]; then
        echo "CUDNN_TAR: ${CUDNN_TAR} find. Extracting ..."
        # extract to ./cuda (auto merged to ${BUILT_ROOT})
        tar xzvf ${CUDNN_TAR}
    else
        echo "No CUDNN_TAR set/find in dir, skip cuDNN."
    fi

    if [[ ${TRT_TAR} != "" && -f ${TRT_TAR} ]]; then
        echo "TRT_TAR: ${TRT_TAR} find. Extracting ..."
        # Extract to ${BUILT_ROOT}/${TRT_DIR}
        tar xzvf ${TRT_TAR} -C ${BUILT_ROOT}
    else
        echo "No TRT_TAR set/find in dir, skip TensorRT."
    fi
fi

####################################### Export env source file

# Add cuda version to cuda root dir & make a soft link to it
mv "${BUILT_ROOT}" "${BUILT_ROOT_LN}"
ln -s -f "${BUILT_ROOT_LN}" "${BUILT_ROOT}"

NEW_PATH="${BUILT_ROOT}/bin"
NEW_LIBRARY_PATH="${BUILT_ROOT}/lib64"
NEW_LD_LIBRARY_PATH="${BUILT_ROOT}/lib64"

if [[ ${TRT_TAR} != "" ]]; then
    NEW_PATH="${BUILT_ROOT}/${TRT_DIR}/bin:${NEW_PATH}"
    NEW_LIBRARY_PATH="${BUILT_ROOT}/${TRT_DIR}/lib:${NEW_LIBRARY_PATH}"
    NEW_LD_LIBRARY_PATH="${BUILT_ROOT}/${TRT_DIR}/lib:${NEW_LD_LIBRARY_PATH}"
fi

if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${NEW_LD_LIBRARY_PATH}:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${NEW_LIBRARY_PATH}:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${NEW_PATH}:\${PATH}" >> ${BUILT_ENV}

popd

echo "Install CUDA success!"
