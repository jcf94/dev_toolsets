#!/bin/bash

set -xe

GCC_ROOT_PATH=$(cd "$(dirname "$0")"; pwd)

####################################### Version Def & Path Def

GMP_DIR="gmp-6.2.1"
MPFR_DIR="mpfr-4.1.0"
MPC_DIR="mpc-1.2.1"
GCC_DIR="gcc-7.5.0"

BUILT_ROOT="${GCC_ROOT_PATH}/built"
GCC_TARGET="c,c++,fortran"
# GCC_TARGET="c,c++,fortran,go"

GMP_TAR="${GMP_DIR}.tar.xz"
GMP_URL="https://ftp.gnu.org/gnu/gmp/${GMP_TAR}"

MPFR_TAR="${MPFR_DIR}.tar.xz"
MPFR_URL="https://ftp.gnu.org/gnu/mpfr/${MPFR_TAR}"

MPC_TAR="${MPC_DIR}.tar.gz"
MPC_URL="https://ftp.gnu.org/gnu/mpc/${MPC_TAR}"

GCC_TAR="${GCC_DIR}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/${GCC_DIR}/${GCC_TAR}"

BUILT_GMP="${BUILT_ROOT}/gmp"
BUILT_MPFR="${BUILT_ROOT}/mpfr"
BUILT_MPC="${BUILT_ROOT}/mpc"
BUILT_GCC="${BUILT_ROOT}/gcc"
BUILT_ENV="${BUILT_ROOT}/env.sh"

####################################### Prepare src files

pushd ${GCC_ROOT_PATH}

echo "Download GMP..."
if [[ ! -f ${GMP_TAR} ]]; then
    curl -L -o ${GMP_TAR} ${GMP_URL}
fi
echo "Uncompress GMP..."
if [[ ! -d ${GMP_DIR} ]]; then
    tar xf ${GMP_TAR}
fi

echo "Download MPFR..."
if [[ ! -f ${MPFR_TAR} ]]; then
    curl -L -o ${MPFR_TAR} ${MPFR_URL}
fi
echo "Uncompress MPFR..."
if [[ ! -d ${MPFR_DIR} ]]; then
    tar xf ${MPFR_TAR}
fi

echo "Download MPC..."
if [[ ! -f ${MPC_TAR} ]]; then
    curl -L -o ${MPC_TAR} ${MPC_URL}
fi
echo "Uncompress MPC..."
if [[ ! -d ${MPC_DIR} ]]; then
    tar zxf ${MPC_TAR}
fi

echo "Download GCC..."
if [[ ! -f ${GCC_TAR} ]]; then
    curl -L -o ${GCC_TAR} ${GCC_URL}
fi
echo "Uncompress GCC..."
if [[ ! -d ${GCC_DIR} ]]; then
    tar xf ${GCC_TAR}
fi

####################################### Build

if [[ -d ${BUILT_ROOT} ]]; then
    pushd ${BUILT_ROOT}
    rm -rf *
    popd
else
    mkdir ${BUILT_ROOT}
fi

EXTRA_LIB_PATH=""

# Build GMP
pushd ${GMP_DIR}
./configure --prefix=${BUILT_GMP}
make -j && make install
popd
EXTRA_LIB_PATH+="${BUILT_GMP}/lib:"

# Build MPFR
pushd ${MPFR_DIR}
./configure --prefix=${BUILT_MPFR} --with-gmp=${BUILT_GMP}
LD_LIBRARY_PATH=${EXTRA_LIB_PATH}:${LD_LIBRARY_PATH} LD_RUN_PATH=${EXTRA_LIB_PATH}:${LD_RUN_PATH} make -j && make install
popd
EXTRA_LIB_PATH+="${BUILT_MPFR}/lib:"

# Build MPC
pushd ${MPC_DIR}
./configure --prefix=${BUILT_MPC} --with-gmp=${BUILT_GMP} --with-mpfr=${BUILT_MPFR}
LD_LIBRARY_PATH=${EXTRA_LIB_PATH}:${LD_LIBRARY_PATH} LD_RUN_PATH=${EXTRA_LIB_PATH}:${LD_RUN_PATH} make -j && make install
popd
EXTRA_LIB_PATH+="${BUILT_MPC}/lib:"

# Build GCC
pushd ${GCC_DIR}
./configure --prefix=${BUILT_GCC} --with-gmp=${BUILT_GMP} --with-mpfr=${BUILT_MPFR} --with-mpc=${BUILT_MPC} --disable-multilib --enable-languages=${GCC_TARGET}
LD_LIBRARY_PATH=${EXTRA_LIB_PATH}:${LD_LIBRARY_PATH} LD_RUN_PATH=${EXTRA_LIB_PATH}:${LD_RUN_PATH} make -j && make install
popd

####################################### Export env source file
if [[ -f ${BUILT_ENV} ]]; then
    rm -rf ${BUILT_ENV}
fi
echo "" > ${BUILT_ENV}
echo "export C_INCLUDE_PATH=${BUILT_GCC}/include:\${C_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export CPLUS_INCLUDE_PATH=${BUILT_GCC}/include:\${CPLUS_INCLUDE_PATH}" >> ${BUILT_ENV}
echo "export LIBRARY_PATH=${BUILT_GCC}/lib:${BUILT_GCC}/lib64:\${LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export LD_LIBRARY_PATH=${BUILT_GCC}/lib:${BUILT_GCC}/lib64:\${LD_LIBRARY_PATH}" >> ${BUILT_ENV}
echo "export PATH=${BUILT_GCC}/bin:\${PATH}" >> ${BUILT_ENV}
echo "export CC=gcc" >> ${BUILT_ENV}
echo "export CXX=g++" >> ${BUILT_ENV}

popd

echo "Build success!"
