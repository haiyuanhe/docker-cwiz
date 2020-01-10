#!/bin/bash


# Global Variables
_AS_ROOT=0
_DEBUG=0
_STEP=0
_DATA=../data

COLORS=$(tput colors 2> /dev/null)
if [ $? -eq 0 ] && [ $COLORS -gt 2 ]; then
    _color_red=$(TERM=xterm-256color tput setaf 1)
    _color_normal=$(TERM=xterm-256color tput sgr0)
    _color_blue=$(TERM=xterm-256color tput setaf 4)
    _color_green=$(TERM=xterm-256color tput setaf 2)
    _color_yellow=$(TERM=xterm-256color tput setaf 3)
else
    _color_red=
    _color_normal=
    _color_blue=
    _color_green=
    _color_yellow=
fi


function log_error()
{
    printf "${_color_red}$1${_color_normal}\n"
    sleep 1
    return 0
}

function log_info()
{
    printf "$1\n"
    return 0
}

function log_crit()
{
    log_error "$1"
    exit 1
}

function log_debug()
{
    if [ $_DEBUG -eq 1 ]; then
        log_info "$1"
    fi
}

function log_important()
{
    printf "${_color_yellow}$1${_color_normal}\n"
    return 0
}

function abort_if_failed()
{
    if [ $? -ne 0 ]; then
        log_crit "$1. Abort!"
    fi
    return 0
}

function abort_if_not_root()
{
    if [ "_$USER" != "_root" ]; then
        log_crit "Please run as root, or use sudo!"
    fi
    return 0
}

function one_arg_required()
{
    if [ $# -lt 1 ]; then
        log_crit "Required argument missing: $1"
    fi
    return 0
}

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

function next_step()
{
    (( _STEP++ ))
    log_important "[STEP $_STEP] $1"
    return 0
}

function run_as_root()
{
    local cmd=$1
    local SUDO=""

    if [ "_$USER" != "_root" -a "$_AS_ROOT" -ne 0 ]; then
        SUDO="sudo "
    fi

    eval "$SUDO$cmd"
    abort_if_failed "Cmd failed: $SUDO$cmd"
}

function guess_host_ip()
{
    local IPS=$(hostname -I)

    if [ -z "$IPS" ]; then
        IPS=$(hostname --ip-address)
    fi

    if [ -z "$IPS" ]; then
        log_crit "Cannot get host IP; Please set it in install.ini"
    fi

    # In case there are multiple IPs, settle for the 1st one.
    for ip in $IPS
    do
        echo $ip
        break
    done
}

function get_hostname()
{
    hostname=$(get_tag 'hostname')

    if [ -z "$hostname" ]; then
        hostname=$(hostname)
    fi

    if [ -z "$hostname" ]; then
        hostname=$(guess_host_ip)
    fi

    echo $hostname
}

# tag defined in [global] section of the config file checked first
# environment variable checked second
function get_tag()
{
    local tag=$1
    local TAG=${tag^^}      # upper case
    if [ ! -z "${!tag}" ]; then
        echo "${!tag}"
    else
        echo "${!TAG}"
    fi
}

# Unpack package to specified location
function unpack_package()
{
    local pkg=$1          # package to unpack
    local dst=$2          # directory to unpack into

    # Return install root locations
    local __rootvar=$3

    if [ ! -r $pkg ]; then
        log_crit "Package $pkg does not exist"
    fi

    if [ ! -d $dst ]; then
        log_crit "Destination directory $dst does not exist"
    fi

    local tarfile=$(basename "$pkg")

    # Unpack the package
    if [[ "$tarfile" == *.tar.gz || "$tarfile" == *.tgz ]]; then
        taropt1="tzf"
        taropt2="xzf"
    elif [[ "$tarfile" == *.tar.bz2 ]]; then
        taropt1="tjf"
        taropt2="xjf"
    else
        log_crit "Unknown tar file extension: $tarfile"
    fi
    local ver="$(tar $taropt1 $pkg | head -1 | sed -e 's/\/.*//')"
    [ "_$ver" != "_" ] || { log_crit "Malformatted: $tarfile"; }
    local root="$dst/$ver"
    run_as_root "rm -rf $root"
    [ -e $pkg ] && (tar $taropt2 $pkg -C $dst)
    abort_if_failed "Failed to unpack $pkg into $dst"

    # Return root
    eval $__rootvar="'$root'"

    return 0
}

# Download and unpack package to specified location
function download_package()
{
    local pkg=$1          # package to download (URL)
    local dst=$2          # directory to download and unpack into
    local install_root=$3 # directory to eventually install the package into

    # Return src and install root locations
    local __srcvar=$4
    local __rootvar=$5

    # Download the package
    local tarfile=$(basename "$pkg")
    if [ ! -r $dst/$tarfile ]; then
        wget --directory-prefix=$dst $pkg
        abort_if_failed "Failed to download $pkg into $dst"
    fi

    # Unpack the package
    if [[ "$tarfile" == *.tar.gz || "$tarfile" == *.tgz ]]; then
        taropt1="tzf"
        taropt2="xzf"
    elif [[ "$tarfile" == *.tar.bz2 ]]; then
        taropt1="tjf"
        taropt2="xjf"
    else
        log_crit "Unknown tar file extension: $tarfile"
    fi
    local ver="$(tar $taropt1 $dst/$tarfile | head -1 | sed -e 's/\/.*//')"
    [ "_$ver" != "_" ] || { log_crit "Malformatted: $tarfile"; }
    local src="$dst/$ver"
    local root="$install_root/$ver"
    run_as_root "rm -rf $src"
    [ -e $dst/$tarfile ] && (tar $taropt2 $dst/$tarfile -C $dst)
    abort_if_failed "Failed to unpack $dst/$tarfile into $dst"

    # Return src and root
    eval $__srcvar="'$src'"
    eval $__rootvar="'$root'"

    return 0
}

# Create a nologin user, if not exists
function create_nologin_user()
{
    local usr=$1

    if [ -x /usr/sbin/nologin ]; then
        nologin=/usr/sbin/nologin
    elif [ -x /sbin/nologin ]; then
        nologin=/sbin/nologin
    else
        nologin=/bin/false
    fi
    log_info "nologin=$nologin"

    getent passwd $usr
    if [ $? -ne 0 ]; then
        run_as_root "useradd $usr -M -U -s $nologin"
    fi
    return 0
}

# Usage: cfg.parser <config-file>
#        cfg.section.<section-name>  # set shell variables
#        echo $<variable>            # reference shell variables
#
# BUG: this function does not work for the follow input:
#
# [y]
# t=m
#
# Changing 'y' to 'm' won't fix anything.
# Changing 'y' to anything other than 'm' and it works. :)
function cfg.parser()
{
    local ini=()

    if [ $# -ne 1 ]; then
        error "cfg.parser: missing config file argument"
        return 1
    fi

    cfg_file=$(cat $1 | sed 's/ = /=/g')     # fix ' = ' to be '='
    IFS_OLD=$IFS
    IFS=$'\n' && ini=( $cfg_file )           # convert to line-array
    IFS=$IFS_OLD
    ini=( ${ini[*]//;*/} )                   # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%]/ \(} )                 # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                 # convert item to array
    ini=( ${ini[*]/%/ \)} )                  # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
    ini[0]=''                                # remove first element
    ini[${#ini[*]} + 1]='}'                  # add the last brace
    log_debug "${ini[*]}"
    eval "$(echo "${ini[*]}")"               # eval the result
    return 0
}

# Usage: cfg.parser2 <config-file>
#        cfg.section.<section-name>  # set shell variables
#        echo $<variable>            # reference shell variables
function cfg.parser2()
{
    local ini=()

    if [ $# -ne 1 ]; then
        error "cfg.parser2: missing config file argument"
        return 1
    fi

    cfg_file=$(cat $1 | sed 's/ = /=/g')     # fix ' = ' to be '='
    IFS_OLD=$IFS
    IFS=$'\n' && ini=( $cfg_file )           # convert to line-array
    IFS=$IFS_OLD
    ini=( ${ini[*]//;*/} )                   # remove comments
    ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
    log_debug "${ini[*]}"
    eval "$(echo "${ini[*]}")"               # eval the result
    return 0
}

# After calling cfg.parser(), use this function
# to check if a particular section exist or not
function cfg_sec_must_exist()
{
    if [ -n "$(type -t cfg.section.$1)" ] && [ "$(type -t cfg.section.$1)" = function ]; then
        return 0    # exists
    else
        log_crit "Missing section [$1] in config"
    fi
}

function does_cfg_sec_exist()
{
    if [ -n "$(type -t cfg.section.$1)" ] && [ "$(type -t cfg.section.$1)" = function ]; then
        return 0    # exists
    else
        return 1    # does not exist
    fi
}

function cfg_var_must_exist()
{
    if [ -z "$3" ]; then
        log_crit "Missing config $2 in [$1]"
    fi
    return 0
}

function replace_tag_in_file()
{
    local file="$1"
    local tag="$2"
    local value="$3"

    if [ ! -w "$file" ]; then
        log_crit "File $file does not exist or not writable"
    fi

    sed -i "s/${tag//\//\\/}/${value//\//\\/}/g" "$file"

    return 0
}

function replace_tags_in_file()
{
    local file="$1"
    local tags=$(grep -oE '<:[_a-z]+:>' "$file")

    for tag in ${tags[@]}
    do
        # remove angle brackets
        tag=${tag//</}
        tag=${tag//>/}
        tag=${tag//:/}

        # get tag value
        local value=$(get_tag $tag)
        replace_tag_in_file "$file" "<:$tag:>" "$value"
    done
}

function make_dir()
{
    run_as_root "mkdir -p $1"
    return 0
}

function is_dir_empty()
{
    if [ -z "$(ls -A $1)" ]; then
        return 0    # empty
    else
        return 1    # not empty
    fi
}

# copy files from src directory to dst directory
# replacing tags as we go
function copy_and_replace()
{
    local src=$1
    local dst=$2

    for file in "$src"/*
    do
        local base=$(basename "$file")
        if [ -d "$file" ]; then
            copy_and_replace "$file" "$dst/$base"
        else
            run_as_root "mkdir -p $dst"             # make sure dir exists
            run_as_root "cp -fp \"$file\" \"$dst/$base\""   # copy file
            log_debug "cp -fp \"$file\" \"$dst/$base\""

            if is_text_file "$dst/$base"; then
                replace_tags_in_file "$dst/$base"
            else
                log_debug "copy_and_replace: not replacing tags in binary file $dst/$base"
            fi
        fi
    done
}

function array_contains()
{
    eval 'local arr=("${'$1'[@]}")'
    local _elem=$2

    for _e in ${arr[@]}
    do
        if [ "$_e" == "$_elem" ]; then
            return 0
        fi
    done

    return 1
}

function index_in_array()
{
    eval 'local arr=("${'$1'[@]}")'
    local _elem=$2
    local _index=0

    for _e in ${arr[@]}
    do
        if [ "$_e" == "$_elem" ]; then
            return $_index
        fi
        (( _index++ ))
    done

    # should never be here
    return 255
}

function copy_file_with_backup()
{
    local src=$1
    local dst=$2
    local ts=$(date +%Y.%m.%d.%H.%M.%S)

    # save dst as backup
    run_as_root "mv $dst ${dst}.$ts"

    # now copy
    run_as_root "cp $src $dst"
}

function ask_mysql_credential()
{
    # Ask for MySQL credentials
    read -p "Please enter MySQL username: " _username

    if [ -z "$_username" ]; then
        log_info "Empty username entered. It will not be used."
    else
        MYSQL_USERNAME=$_username
    fi

}

# check if first argument is parent directory
# of second argument
function is_parent_child()
{
    local parent=$1
    local child=$2

    if [[ $child/ = $parent/* ]]; then
        return 0
    else
        return 1
    fi
}

function get_ulimit()
{
    ulimit -a | grep "$1" | awk '{print $NF}'
}

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

# Returns:
#   0 if $1 == $2
#   1 if $1 < $2
#   2 if $1 > $2
function cmp_numbers()
{
    if [ $# -ne 2 ]; then
        log_crit "Wrong number of arguments to cmp_numbers(). Abort!"
    fi

    # equals?
    RES=$(echo "$1 == $2" | bc -l)
    if [ $RES = "1" ]; then
        return 0
    fi

    # less?
    RES=$(echo "$1 < $2" | bc -l)
    if [ $RES = "1" ]; then
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
        log_error "Unable to get GLIBC version, assuming less than $1"
        RES=1
    fi

    if [ "$RES" = "0" -o "$RES" = "2" ]; then
        return 0
    else
        return 1
    fi
}

# Turns a comma separated string into array
# Usage: css_to_array "a, b, c" arr
function css_to_array()
{
    local __arr=$2
    eval $__arr='( ${1//,/ } )'
    return 0
}

# Turns a comma separated string into array
# Usage: idx_to_array dst "2, 3, 7" "${src[@]}"
# WARNING: Items in src cannot contain spaces!
function idx_to_array()
{
    local __ret=$1
    local idx_str="$2"

    shift
    shift

    local src=("${@}")
    local dst=()

    css_to_array "$idx_str" idx_arr

    for i in "${idx_arr[@]}"
    do
        dst+=(${src[$i]})
    done

    eval $__ret='( ${dst[@]} )'

    return 0
}

function is_ipv4()
{
    local regex="^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$"

    if [[ $1 =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}

function is_ipv6()
{
    local regex1="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
    local regex2="^\[(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))\]$"

    if [[ $1 =~ $regex1 || $1 =~ $regex2 ]]; then
        return 0
    else
        return 1
    fi
}

function grep_for_process()
{
    local _pids=
    local _code=

    if which pgrep > /dev/null; then
        _pids=$(pgrep "$1")
    else
        _pids=$(ps -ef | grep "$1" | grep -v grep)
    fi

    _code=$?

    if [ ! -z "$_pids" ]; then
        echo $_pids
    fi

    return $_code
}

# 0:  port is open
# 1:  port is closed (no listener, but not blocked by firewall)
# >1: port is filtered (blocked by firewall)
function is_tcp_port_open()
{
    local _host=$1
    local _port=$2

    timeout 2 bash -c "(echo > /dev/tcp/$_host/$_port) >/dev/null 2>&1"
    return $?
}

function does_cmd_exist()
{
    local _cmd=$1

    which $_cmd >/dev/null 2>&1
    return $?
}

function get_user()
{
    if does_cmd_exist whoami; then
        USER=$(whoami)
    fi

    echo $USER
}

function is_systemd_running()
{
    if ! does_cmd_exist systemctl; then
        return 1
    fi

    local status=$(systemctl is-system-running)

    if [ "_$status" = "_running" ]; then
        return 0
    else
        return 1
    fi
}

# example input: cloudwiz-agent.service
function remove_systemd_service()
{
    local svc=$1

    systemctl --no-ask-password stop $svc
    systemctl --no-ask-password disable $svc
    rm -f /etc/systemd/system/$svc
    if [ -h /etc/systemd/system/multi-user.target.wants/$svc ]; then
        unlink /etc/systemd/system/multi-user.target.wants/$svc
    fi
    systemctl --no-ask-password daemon-reload
    systemctl --no-ask-password reset-failed
}

# record svc version
function record_svc_version()
{
    local service_name=${1}
    local package_dir=${2}
    local record_file=${3}/services.txt

    file_path=$(ls ${package_dir}/${service_name}*)
    file_name=${file_path##*/}
    echo "${service_name} ---> ${file_name}" >> $record_file
}

#install_java_for_encrypt
function install_java()
{
    if [ ! -d "${install_root}/encrypt" ]; then
       mkdir -p ${install_root}/encrypt
    fi

    if [ ! -f "${local_pkg_dir}/${local_java_pkg}" ]; then
       log_crit "Package ${local_pkg_dir}/${local_java_pkg} does not exist"
    else
        log_info "Unpacking ${local_pkg_dir}/${local_java_pkg}... "
        tar -xf ${local_pkg_dir}/${local_java_pkg} -C ${install_root}/encrypt
        mv ${install_root}/encrypt/jdk8* ${install_root}/encrypt/jdk
    fi

    if [ ! -f "${local_pkg_dir}/${local_encrypt_jar}" ]; then
       log_crit "Package ${local_pkg_dir}/${local_encrypt_jar} does not exist"
    else
        log_info "Moving ${local_pkg_dir}/${local_encrypt_jar} to ${install_root}/encrypt... "
        cp -a ${local_pkg_dir}/${local_encrypt_jar} ${install_root}/encrypt
    fi
}

#encrypt MySQL password
function encrypt_MySQLPass()
{
    local java_path="${install_root}/encrypt/jdk/bin/java"
    local crypt_jar="${install_root}/encrypt/${local_encrypt_jar}"
    local java_class="com.cloudwiz.crypt.AesCrypt"

    export mysql_base_password=$(echo -n ${mysql_password} | base64)
    encrypt_pass=$(${java_path} -cp ${crypt_jar} ${java_class} ${secret_key} encrypt ${mysql_password})
    export mysql_password=${encrypt_pass}
}

#encrypt SSL password
function encrypt_SSLPass()
{
    local java_path="${install_root}/encrypt/jdk/bin/java"
    local crypt_jar="${install_root}/encrypt/${local_encrypt_jar}"
    local java_class="com.cloudwiz.crypt.AesCrypt"

    export kafka_ssl_password=${ssl_password}
    encrypt_pass=$(${java_path} -cp ${crypt_jar} ${java_class} ${secret_key} encrypt ${ssl_password})
    export ssl_password=${encrypt_pass}
}

#use_nginx_ssl_conf
function use_nginx_ssl_conf()
{
    mv -f ${install_root}/nginx/conf/nginx_ssl.conf ${install_root}/nginx/conf/nginx.conf 
}

#check mysql_pass encrypt
function check_mysql_pass_encrypt()
{
    # mysql_pass ssl_pass encrypt
    if [ "$ssl_enable" == "true" ]; then
        log_info "install java for encrypt..."
        install_java
        log_info "MySQL_Pass encrypt..."
        encrypt_MySQLPass
        encrypt_SSLPass
    fi
}

#change nginx_conf if ssl is enabled
function check_nginx_ssl()
{
    if [ "$ssl_enable" == "true" ]; then
        log_info "ssl is enabled , use nginx.ssl.conf..."
        use_nginx_ssl_conf
    fi
}

function install_es_plugin()
{
    log_info "Unpacking ${local_pkg_dir}/${local_es_plugin}... "
    mkdir -p ${install_root}/elasticsearch/plugins/
    tar -xf ${local_pkg_dir}/${local_es_plugin} -C ${install_root}/elasticsearch/plugins/

    #log_info "Unpacking ${_DATA}/elasticsearch.tar.gz"
    #mkdir -p ${install_root}/data/
    #tar -xf ${_DATA}/elasticsearch.tar.gz -C ${install_root}/data/

    log_info "chmod elasticsearch.yml"
    chmod 666 ${install_root}/elasticsearch/config/elasticsearch.yml
}