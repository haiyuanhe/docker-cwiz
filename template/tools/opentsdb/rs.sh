#!/bin/bash

regexRegionServer='^[[:blank:]]{4}([0-9A-Za-z\.]+:[0-9]+ [0-9]+)'
regexTable='^[[:blank:]]{8}"([^,]+),([^,]*),([^.]+).([^.]+).'

regions=()
tables=()
_dry_run=0

# process command line arguments
while [[ $# -gt 0 ]]
do
    key=$1

    case $key in
        --dry-run)
        _dry_run=1
        ;;
        *)
        echo "Unknown option $key"
        exit 1
        ;;
    esac
    shift
done

if [ "$_dry_run" = "1" ]; then
    cmd="tee"
    echo "Dry run. Will NOT update hbase"
else
    cmd="<:install_root:>/hbase/bin/hbase shell 2>/dev/null"
    echo "For real!!! HBase will be updated..."
    sleep 2
fi


function index()
{
    if [ -z "$1" ]; then
        echo "1"
    elif [[ $1 = '\002\'* ]]; then
        echo "2"
    elif [[ $1 = '\004\'* ]]; then
        echo "3"
    elif [[ $1 = '\006\'* ]]; then
        echo "4"
    elif [[ $1 = '\b\'* ]]; then
        echo "5"
    elif [[ $1 = '\n\'* ]]; then
        echo "6"
    elif [[ $1 = '\f\'* ]]; then
        echo "7"
    elif [[ $1 = '\016\'* ]]; then
        echo "8"
    elif [[ $1 = '\020\'* ]]; then
        echo "9"
    elif [[ $1 = '\022\'* ]]; then
        echo "10"
    elif [[ $1 = '\024\'* ]]; then
        echo "11"
    elif [[ $1 = '\026\'* ]]; then
        echo "12"
    elif [[ $1 = '\030\'* ]]; then
        echo "13"
    elif [[ $1 = '\032\'* ]]; then
        echo "14"
    elif [[ $1 = '\034\'* ]]; then
        echo "15"
    elif [[ $1 = '\036\'* ]]; then
        echo "16"
    else
        echo "255"
    fi
}

OUTPUT=$(echo "status 'detailed'" | <:install_root:>/hbase/bin/hbase shell 2>/dev/null)

declare -A current

IFS_OLD=$IFS
IFS=''
while read -r line
do
    if [[ $line =~ $regexRegionServer ]]; then
        region=${BASH_REMATCH[1]/ /,}
        table=
        _region=${region/:/,}
        regions+=("$_region")
    elif [[ $line =~ $regexTable ]]; then
        table=${BASH_REMATCH[1]}
        start=${BASH_REMATCH[2]}
        region=${BASH_REMATCH[4]}
        if [ "_$table" = "_tsdb" ]; then
            idx=$(index $start)
            tables[$idx]="$region"
            current[$region]="$_region"
        fi
    fi
done <<< "$OUTPUT"

rc=${#regions[@]}
r=0

for t in "${tables[@]}"; do
    if [ "${regions[$r]}" != "${current[$t]}" ]; then
        echo "move '$t', '${regions[$r]}'"
    fi
    r=$(( (r+1) % rc ))
    sleep 30
done | eval $cmd

exit 0
