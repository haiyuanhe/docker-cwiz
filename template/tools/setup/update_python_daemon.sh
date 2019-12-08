#!/bin/bash

_SRC1="/opt/cloudwiz-python-daemon/"
_DST1="<:install_root:>/python-daemon/"

_SRC2="/usr/bin/env python"
_DST2="<:install_root:>/python-daemon/pythondenv/bin/python3"

# Note that it will consider empty file a binary file.
function is_text_file()
{
    local p1="text/"
    local p2="charset=us-ascii"
    local p3="charset=utf-8"

    local out=$(file --mime "$1")

    if [[ "${out/$p1}" != "$out" ]] || [[ "${out/$p2}" != "$out" ]] || [[ "${out/$p3}" != "$out" ]]; then
        return 0
    else
        return 1
    fi
}

function replace_in_file_recursively()
{
    local file_or_dir=$1

    if [ -d "$file_or_dir" ]; then
        for fd in "$file_or_dir"/*; do
            replace_in_file_recursively "$fd"
        done
    elif ! is_text_file "$file_or_dir"; then
        return 0
    elif [ -f "$file_or_dir" -a "$file_or_dir" != *.pyc -a "$file_or_dir" != *.so -a "$file_or_dir" != *.a ]; then
        sed -i "s/${_SRC1//\//\\/}/${_DST1//\//\\/}/g" "$file_or_dir"
        sed -i "s/${_SRC2//\//\\/}/${_DST2//\//\\/}/g" "$file_or_dir"
    fi

    return 0
}

replace_in_file_recursively <:install_root:>/python-daemon
