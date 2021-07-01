#!/bin/bash

FILEPATH=$(cd "$(dirname "$0")"; pwd)

list=(
    "${FILEPATH}/built"
    "${FILEPATH}/*.src"
    "${FILEPATH}/*.tar.xz"
)

for i in ${list[*]}; do
    echo "Cleaning ${i} ..."
    rm -rf ${i}
done

