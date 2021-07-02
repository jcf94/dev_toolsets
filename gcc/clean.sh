#!/bin/bash

FILEPATH=$(cd "$(dirname "$0")"; pwd)

LIST=("${FILEPATH}/built")

function usage() {
    echo "./clean.sh    [-h]    Help"
    echo "              [-a]    Clean all extra files"
}

while getopts "ha" arg
do
    case "${arg}" in
        a)
            LIST=(
                "${FILEPATH}/built"
                "${FILEPATH}/gcc-*"
                "${FILEPATH}/gmp-*"
		"${FILEPATH}/mpfr-*"
		"${FILEPATH}/mpc-*"
            )
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


for i in ${LIST[*]}; do
    if [[ -d ${i} || -f ${i} ]]; then
        echo "Cleaning ${i} ..."
        rm -rf ${i}
    fi
done
