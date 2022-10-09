#!/bin/bash --norc

SYSROOT=$1

FILES=("/usr/lib/libc.so" "/usr/lib/libm.so" "/usr/lib/libpthread.so")

for file in ${FILES[@]}; do
    file_type=$(file -0 "${SYSROOT}${file}" | cut -d $'\0' -f2)
    if [[ $file_type == *text* ]]; then
        sed -i 's/ \// =\//g' "${SYSROOT}${file}"
    fi
done
