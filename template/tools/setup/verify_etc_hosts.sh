#!/bin/bash

_ALL_HOSTS=(<:all_hosts:>)
_NGINX_IP=<:nginx_ip:>
_NGINX_PORT=<:nginx_port:>
_HOST_IP=<:host_ip:>
_HOSTNAME=<:hostname:>
_MAX_TIME_DIFF_SECS=30

_MYSQL_USERNAME=<:mysql_username:>
_MYSQL_PASSWORD=<:mysql_password:>

if [ $# -gt 0 ]; then
    _MAX_TIME_DIFF_SECS=$1
fi

_HOST_CNT=${#_ALL_HOSTS[@]}

# for single host install, do nothing
if [ $_HOST_CNT -le 1 ]; then
    echo "Single host install, do nothing"
    exit 0
fi

function add_timestamp()
{
    local _file=$1
    local _tstamp=$(date +%s)

    if [[ `grep timestamp $_file` ]]; then
        sed -i -E "s/timestamp = [0-9]+/timestamp = $_tstamp/" $_file
    else
        echo "timestamp = $_tstamp;" >> $_file
    fi
}

function del_timestamp()
{
    local _file=$1
    sed -i -E "/timestamp = [0-9]+;/d" $_file
}

function chk_timestamp()
{
    local _file=$1

    if [[ ! `grep timestamp $_file` ]]; then
        return 0
    fi

    local _remote=$(grep timestamp $_file | while read k e v; do [[ $e == '=' ]] && echo ${v/;/}; done)
    local _local=$(date +%s -r $_file)

    if (( _remote > _local )); then
        if (( _remote - _local > _MAX_TIME_DIFF_SECS )); then
            echo "_local = $_local, _remote = $_remote;"
            return 1
        fi
    else
        if (( _local - _remote > _MAX_TIME_DIFF_SECS )); then
            echo "_local = $_local, _remote = $_remote;"
            return 2
        fi
    fi

    return 0
}

# generate hosts file
_TEMP=$(mktemp)
echo "Generating file ${_TEMP}..."
for host in ${_ALL_HOSTS[@]}; do
    _ENT=$(getent hosts $host)
    echo "$_ENT" >> $_TEMP
done

echo "mysql_username = $_MYSQL_USERNAME;" >> $_TEMP
echo "mysql_password = $_MYSQL_PASSWORD;" >> $_TEMP
add_timestamp $_TEMP

# upload hosts file
echo "Uploading file ${_TEMP}..."
_UPLOADED=0
for i in {1..20}; do
    curl -k --fail --max-time 5 --upload-file $_TEMP <:nginx_protocol:>://$_NGINX_IP:8000/etc/$_HOST_IP/hosts 2>/dev/null
    if [ $? -eq 0 ]; then
        echo
        _UPLOADED=1
        break
    fi
    sleep 10
    printf '.'
    add_timestamp $_TEMP
done

if [ $_UPLOADED -eq 0 ]; then
    echo "Cannot upload /etc/hosts. Verification not performed."
    exit 0
fi

# verify hosts file
if [ "$_HOST_IP" = "$_NGINX_IP" ]; then
    echo "Verifying /etc/hosts..."
    # make sure all the files are uploaded
    for i in {1..40}; do
        _READY=0
        for host in ${_ALL_HOSTS[@]}; do
            _HERS=<:install_root:>/nginx/upload/etc/$host/hosts
            if [ -f $_HERS ]; then
                _READY=$(( _READY+1 ))
            fi
        done
        if [ $_READY -eq $_HOST_CNT ]; then
            echo
            break
        fi
        sleep 10
        printf '.'
    done

    if [ $_READY -lt $_HOST_CNT ]; then
        echo
        echo "Not all hosts uploaded their /etc/hosts. Verification not performed!"
        exit 0
    fi

    _MINE=<:install_root:>/nginx/upload/etc/$_HOST_IP/hosts
    del_timestamp $_MINE
    _ERR=0

    for host in ${_ALL_HOSTS[@]}; do
        _HERS=<:install_root:>/nginx/upload/etc/$host/hosts
        if ! chk_timestamp $_HERS ; then
            _ERR=1
            echo "[ERROR] Time different between $_HOST_IP and $host is too large!"
        fi
        del_timestamp $_HERS
        diff $_MINE $_HERS
        if [ $? -ne 0 ]; then
            _ERR=1
            echo "[ERROR] /etc/hosts (etc.) different between these hosts: $_HOST_IP, $host"
        fi
    done

    if [ $_ERR -eq 0 ]; then
        echo "/etc/hosts (etc.) on all hosts are good!"
    else
        rm -f $_TEMP
        exit 1  # failed!!!
    fi
fi

rm -f $_TEMP

exit 0
