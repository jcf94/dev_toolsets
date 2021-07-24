#!/bin/bash

set -e

CUDA_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

CUDA_VERSION="11.4.0"
DRIVER_VERSION="470.42.01"

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
                    ;;
                "11.2")
                    CUDA_VERSION="11.2.2"
                    DRIVER_VERSION="460.32.03"
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
    else
        echo "CUDA already installed in ${BUILT_ROOT}, set -f to override it."
    fi
else
    OVERRIDE_BUILT="1"
fi

if [[ ${OVERRIDE_BUILT} == "1" ]]; then
    echo "Extracting and installing CUDA files ..."
    ./${CUDA_SH} --installpath="${BUILT_ROOT}" --silent --toolkit --override
fi

####################################### Export env source file

if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_ROOT}/lib64:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${BUILT_ROOT}/lib64:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${BUILT_ROOT}/bin:\${PATH}" >> ${BUILT_ENV}

popd

echo "Install CUDA success!"
