#!/bin/bash

set -e

SOURCE="tuna"
SOURCE_URL=""

####################################### Process parameters

function usage() {
    echo "./pypi_replace.sh [-h]                Help"
    echo "                  [-s tuna|aliyun]    Set source"
}

while getopts "hs:" arg
do
    case "${arg}" in
        s)
            SOURCE="$2"
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

####################################### Update source

if [[ "${SOURCE}" == "tuna" ]]; then
    SOURCE_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
elif [[ "${SOURCE}" == "aliyun" ]]; then
    SOURCE_URL="http://mirrors.cloud.aliyuncs.com/pypi/simple/"
else
    echo "Unsupported source: ${SOURCE}"
    exit 1
fi


pip install pip -U

pip config set global.index-url ${SOURCE_URL}

echo "Pypi source update to ${SOURCE} success!"
