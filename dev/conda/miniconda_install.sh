#!/bin/bash

set -e

MINICONDA_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

BUILT_ROOT="${MINICONDA_ROOT_PATH}/miniconda"
BUILT_ENV="${BUILT_ROOT}/env.sh"

pushd ${MINICONDA_ROOT_PATH}

OS=`uname -s`
if [[ "${OS}" == "Linux" ]]; then
    MINICONDA_SH="Miniconda3-latest-Linux-x86_64.sh"
elif [[ "${OS}" == "Darwin" ]]; then
    MINICONDA_SH="Miniconda3-latest-MacOSX-x86_64.sh"
else
    echo "Not supported system."
    uanme -a
    exit -1
fi
MINICONDA_URL="https://repo.anaconda.com/miniconda/${MINICONDA_SH}"

if [[ ! -f ${MINICONDA_SH} ]]; then
    curl -L -o ${MINICONDA_SH} ${MINICONDA_URL}
fi

chmod +x ${MINICONDA_SH}

./${MINICONDA_SH} -b -f -p "${BUILT_ROOT}"

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "source ${BUILT_ROOT}/bin/activate" >> ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${BUILT_ROOT}/lib:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${BUILT_ROOT}/bin:\${PATH}" >> ${BUILT_ENV}

popd

echo "Install Miniconda success!"
