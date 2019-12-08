#!/bin/bash

# Returns:
#   0 if $1 == $2
#   1 if $1 < $2
#   2 if $1 > $2
function cmp_versions()
{
    if [ $# -ne 2 ]; then
        echo "Wrong number of arguments to cmp_versions(). Abort!"
        exit 1
    fi

    if [ "$1" = "$2" ]; then
        return 0
    fi

    # less?
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" == "$1"
    if [ $? -eq 0 ]; then
        return 1
    fi

    # must be greater
    return 2
}

# Returns true (0) if glibc version is greater or equal to the argument;
# Returns false (1) if it is smaller;
function cmp_glibc_version()
{
    local LINE=$(ldd --version | head -1)
    local REGEX="ldd \(.*\) (.*)"

    if [[ $LINE =~ $REGEX ]]; then
        VER=${BASH_REMATCH[1]}
        cmp_versions $VER $1
        RES=$?
    else
        echo "Unable to get GLIBC version, assuming less than $1"
        RES=1
    fi

    if [ "$RES" = "0" -o "$RES" = "2" ]; then
        return 0
    else
        return 1
    fi
}

if [ -z "$1" ]; then
    cmp_glibc_version "2.14"
    status=$?
elif [ "$1" = "2.12" ]; then
    status=1
else
    status=0
fi

if [ $status -eq 0 ]; then
    ln -s <:install_root:>/hadoop/lib/native/glibc-2.14/libgplcompression.so.0.0.0 <:install_root:>/hadoop/lib/native/libgplcompression.so
    ln -s <:install_root:>/hadoop/lib/native/glibc-2.14/liblzo2.so.2.0.0 <:install_root:>/hadoop/lib/native/liblzo2.so
    ln -s <:install_root:>/hadoop/lib/native/glibc-2.14/liblzo2.so.2.0.0 <:install_root:>/hadoop/lib/native/liblzo2.so.2
else
    ln -s <:install_root:>/hadoop/lib/native/glibc/libgplcompression.so.0.0.0 <:install_root:>/hadoop/lib/native/libgplcompression.so
    ln -s <:install_root:>/hadoop/lib/native/glibc/liblzo2.so.2.0.0 <:install_root:>/hadoop/lib/native/liblzo2.so
    ln -s <:install_root:>/hadoop/lib/native/glibc/liblzo2.so.2.0.0 <:install_root:>/hadoop/lib/native/liblzo2.so.2
fi
