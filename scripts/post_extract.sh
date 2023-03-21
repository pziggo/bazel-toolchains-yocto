#!/bin/bash --norc

SYSROOT=$1
FILE=$2

file_type=$(file -0 "${SYSROOT}${FILE}" | cut -d $'\0' -f2)
if [[ $file_type == *text* ]]; then
    sed 's/ \// =\//g' "${SYSROOT}${FILE}"
fi
