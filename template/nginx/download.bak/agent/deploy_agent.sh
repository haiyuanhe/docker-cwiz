#!/bin/bash

color_red=$(TERM=xterm-256color tput setaf 1)
color_normal=$(TERM=xterm-256color tput sgr0)
color_blue=$(TERM=xterm-256color tput setaf 4)

agent_startup_scripts="cloudwiz-agent"
download_source=${AGENT_URL:-"file:///tmp/publish"}
working_folder="/tmp"
agent_install_folder="${INSTALL_DIR}/cloudwiz-agent"
altenv_folder="${agent_install_folder}/altenv"
agent_install_escaped=""

attr=$(echo ${agent_install_folder} | awk -F '/' '{str="";for(i=1;i<=NF;i++){str=str" "$i};print str}')
for i in $attr;do
    agent_install_escaped=$agent_install_escaped"\/"$i
done

altenv_etc_folder="${altenv_folder}/etc"
altenv_var_folder="${altenv_folder}/var"
altenv_cache_folder="${altenv_var_folder}/cache"


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

function _md5() {
  if does_cmd_exist md5sum; then
    md5sum "$1" | awk '{ print $1 }'
    echo >&2 "switch md5sum to publish md5 key"
  else
    md5 -q "$1"
    echo >&2 "switch md5 to publish md5 key"
  fi
}

function abort_if_failed() {
  if [ $? -ne 0 ]; then
    printf "${color_red}$1. abort!${color_normal}\n"
    exit 1
  fi
}

function log_info() {
  printf "${color_blue}$1${color_normal}\n"
}

function fix_python_recursively() {
  if [ "$agent_install_escaped" = "\/opt\/cloudwiz-agent" ]; then
    return
  fi

  for i in "$1"/*; do
    if [ -d "$i" ];then
      fix_python_recursively "$i"
    else
      if [ ! -L "$i" ] && [[ $i != *"python"* ]] && [[ $i != *"filebeat"* ]]; then
        sed -i "/${agent_install_escaped}/b; s/\/opt\/cloudwiz-agent/${agent_install_escaped}/g" "$i"
      fi
    fi
  done
}

function get_os() {
	# OS/Distro Detection
	# Try lsb_release, fallback with /etc/issue then uname command
	known_distribution="(Debian|Ubuntu|RedHat|CentOS|openSUSE|SUSE|Amazon)"
	distribution=$(lsb_release -d 2>/dev/null | grep -Eo $known_distribution  || grep -Eo $known_distribution /etc/issue 2>/dev/null || uname -s)
	if [ $distribution = "Darwin" ]; then
			OS="Darwin"
	elif [ -f /etc/debian_version -a "$distribution" == "Debian" ]; then
			OS="Debian"
	elif [ -f /etc/debian_version -a "$distribution" == "Ubuntu" ]; then
			OS="Ubuntu"
    elif [ -f /etc/redhat-release -o "$distribution" == "RedHat" -o "$distribution" == "CentOS" -o "$distribution" == "openSUSE" -o "$distribution" == "SUSE" -o "$distribution" == "Amazon" ]; then
			OS="RedHat"
	# Some newer distros like Amazon may not have a redhat-release file
	elif [ -f /etc/system-release -o "$distribution" == "Amazon" ]; then
			OS="RedHat"
	fi

	echo $OS
}

# find host IP and change localhost to host IP
function update_localhost() {
    local conf=$1
    local hostip=$(hostname -I)

    if [ -z "$hostip" ]; then
        hostip=$(hostname --ip-address)
    fi

    if [ -z "$hostip" ]; then
        return 1
    fi

    hostip=${hostip//[[:space:]]/}
    sed -i "s/localhost/$hostip/g" $conf
}

function usage() {
  printf "sudo ORG_TOKEN=<token> CLIENT_ID=<id> INSTALL_DIR=<dir> [AGENT_URL=<agent-tarball_url> METRIC_SERVER_HOST=<server> ALERTD_SERVER=<alert_server:port> PROXY_HOST=<proxy_host_address> PROXY_PORT=<proxy_port>] deploy_agent_self_defined_dir.sh [-h] [-snmp] [-update]\n"
}

function save_old_agent(){
    log_info "copy $1/agent/collectors/conf into /tmp"
    yes | cp -fr $1/agent/collectors/conf ${working_folder}
    log_info "backup old tcollector"
    yes | cp -fr $1 "${working_folder}/cloudwiz-agent-bk-${current_time}"
}


if [ "$#" -gt 0 ]; then
  if [ "$1" == "-h" ]; then
    usage
    exit 0
  elif [ "$1" == "-update" ]; then
    #countinue
    printf "redeploy tcollector"
  elif [ "$1" == "-snmp" ]; then
    snmp=true
  else
    printf "unrecognized option\n"
    usage
    exit 1
  fi
fi

OS=$(get_os)


if [ -z "${ORG_TOKEN// }" ]; then
  echo "ORG_TOKEN env variable is not set or empty"
  usage
  exit 1
fi

if [ -z "${CLIENT_ID// }" ]; then
  echo "CLIENT_ID env variable is not set or empty"
  usage
  exit 1
fi

if [ -z "${SYSTEM_ID// }" ]; then
  echo "SYSTEM_ID env variable is not set or empty"
  usage
  exit 1
fi
if [ -z "${INSTALL_DIR// }" ]; then
  echo "INSTALL_DIR env variable is not set or empty"
  usage
  exit 1
fi


# stop all
if  does_cmd_exist ${agent_install_folder}/cloudwiz-agent; then
    log_info "stop the tcollector"
    ${agent_install_folder}/cloudwiz-agent stop
    abort_if_failed "failed stop the collector"
fi

if [ "$1" == "-update" ]; then
    current_time=$(date "+%Y.%m.%d-%H.%M.%S")
    save_old_agent ${agent_install_folder}
fi

agent_ip=$(echo -n "$download_source" | cut -d '/' -f3 | sed -e 's/:[0-9]*$//')

if is_ipv6 "$agent_ip"; then
    curl_opt="-6gskLo"
else
    curl_opt="-skLo"
fi

log_info "downloading agent tarball ${download_source}/${OS}/agent.tar.gz ${working_folder} and extract it"
curl $curl_opt ${working_folder}/agent.tar.gz "${download_source}/${OS}/agent.tar.gz"
abort_if_failed "failed to download tarball or source tarball isn't exit "

## should check sum by md5
log_info "downloading agent md5 hash file"
curl $curl_opt ${working_folder}/agent.tar.gz.md5 "${download_source}/${OS}/agent.tar.gz.md5"
abort_if_failed "failed to download md5 file or source file isn't exit"

MD5=$(_md5 "${working_folder}/agent.tar.gz")
MD5_check=$(cat "${working_folder}/agent.tar.gz.md5")

if [ $MD5 != $MD5_check ] ; then
   printf "${color_red} MD5 value isn't same as tarball. abort!${color_normal}\n"
   exit 1
fi

if [ -n "${INSTALL_DIR// }" ];then
    echo "INSTALL_DIR is ${INSTALL_DIR}"
    rm -rf ${INSTALL_DIR}/cloudwiz-agent
    tar -xzf "${working_folder}/agent.tar.gz" -C ${INSTALL_DIR}/
else
    echo "INSTALL_DIR is null !"
    exit 1
fi
abort_if_failed "failed to extract agent tarball"

sed -i "/^token *= */c\token=$ORG_TOKEN" ${agent_install_folder}/agent/agent_main.conf
abort_if_failed "failed to set ORG_TOKEN value in agent_main.conf file"

sed -i "/^org_id *= */c\org_id = $CLIENT_ID" ${agent_install_folder}/uagent/uagent.conf
abort_if_failed "failed to set org_id value in ${agent_install_folder}/uagent/uagent.conf"
sed -i "/^sys_id *= */c\sys_id = $SYSTEM_ID" ${agent_install_folder}/uagent/uagent.conf
abort_if_failed "failed to set sys_id value in ${agent_install_folder}/uagent/uagent.conf"
sed -i "s/%PLATFORM%/$OS/g" ${agent_install_folder}/uagent/uagent.conf
abort_if_failed "failed to update PLATFORM in uagent/uagent.conf"

sed -i "s/%PLATFORM%/$OS/g" ${agent_install_folder}/version.json
abort_if_failed "failed to update PLATFORM in version.json"

log_info "set filebeat home by default"

sed -i "s/<token>/\"${ORG_TOKEN}\"/" ${agent_install_folder}/filebeat/common.conf
sed -i "s/<orgid>/${CLIENT_ID}/" ${agent_install_folder}/filebeat/common.conf
sed -i "s/<sysid>/${SYSTEM_ID}/" ${agent_install_folder}/filebeat/common.conf
sed -i "s/<sysid>/${SYSTEM_ID}/" ${agent_install_folder}/filebeat/filebeat.yml
sed -i "s/<orgid>/${CLIENT_ID}/" ${agent_install_folder}/filebeat/filebeat.yml
sed -i "s/<token>/${ORG_TOKEN}/" ${agent_install_folder}/filebeat/filebeat.yml
sed -i "s/<log-server-host-port>/\"${METRIC_SERVER_HOST}:5044\"/" ${agent_install_folder}/filebeat/filebeat.yml
sed -i "s/<agent_install_folder>/${agent_install_folder//\//\\/}/" ${agent_install_folder}/filebeat/filebeat.yml

USER=$(whoami)
if [ ! -z "$USER" ]; then
    chown $USER:$USER ${agent_install_folder}/filebeat/filebeat.yml
    chmod 600 ${agent_install_folder}/filebeat/filebeat.yml
fi

fix_python_recursively "${agent_install_folder}/startup_scripts/${OS}"
log_info "copy cloudwiz scripts to ${agent_install_folder}"
mv -f "${agent_install_folder}/startup_scripts/${OS}/${agent_startup_scripts}" ${agent_install_folder}/
log_info "config agent"
fix_python_recursively "${agent_install_folder}/agent"
log_info "config uagent"
fix_python_recursively "${agent_install_folder}/uagent"
log_info "config filebeat"
fix_python_recursively "${agent_install_folder}/filebeat"
log_info "config altenv"
fix_python_recursively "${agent_install_folder}/altenv"
# install snmp, if needed
if [[ "$snmp" = true ]]; then
  # install
  if does_cmd_exist snmpget; then
    echo "snmp already installed, skipping..."
  else
    echo "If you run into conflicts when installing snmp rpms, consider downloading/installing a different version of these rpms."
    rpm -ivh ${agent_install_folder}/snmp/*.rpm
    abort_if_failed "failed to install ${agent_install_folder}/snmp/*.rpm"
  fi
fi

if [ -z "${METRIC_SERVER_HOST// }" ]; then
  echo "METRIC_SERVER_HOST env variable is not set or empty, default to localhost"
else
  echo "set metric server host to $METRIC_SERVER_HOST"
  sed -i "s/-H .* /-H $METRIC_SERVER_HOST /g" ${agent_install_folder}/agent/run
  ## TODO probably should need the port or add the new parameter
  echo -e "host=$METRIC_SERVER_HOST" >> ${agent_install_folder}/agent/agent_main.conf
  result=$(echo ${ALERTD_SERVER} | grep "https" )
  if [ "${result}_" = "_" ];then
      sed -i "/^ssl_enable*=*/c\ssl_enable=" ${agent_install_folder}/agent/run
      if [ "${PORT}_" != "_" ];then
      sed -i "/^ssl_port*=*/c\ssl_port=${PORT}" ${agent_install_folder}/agent/run
      fi
  fi
fi

if [ -z "${ALERTD_SERVER// }" ]; then
  echo "ALERTD_SERVER env variable is not set or empty, default to localhost:5001"
else
  echo "set alertd server host to $ALERTD_SERVER"
  echo -e "alertd_server_and_port=$ALERTD_SERVER" >> ${agent_install_folder}/agent/agent_main.conf
fi

if [ -z "${PROXY_HOST// }" ]; then
  echo "PROXY_HOST variable is not set or empty, default to empty"
else
  echo "set proxy server host s/-H .* /-H $PROXY_HOST /g"
  echo -e "proxy_host=$PROXY_HOST" >> ${agent_install_folder}/agent/agent_main.conf
fi

if [ -z "${PROXY_PORT// }" ]; then
  echo "PROXY_PORT variable is not set or empty, default to empty"
else
  echo "set proxy server host s/-H .* /-H $PROXY_PORT /g"
  echo -e "proxy_port=$PROXY_PORT" >> ${agent_install_folder}/agent/agent_main.conf
fi

if [ "<:ssl_verify:>" = false ]; then
  echo -e "verify_ssl_cert=false" >> ${agent_install_folder}/agent/agent_main.conf
fi

mkdir -p "${altenv_cache_folder}"

log_info "creating download folder"
mkdir -p ${agent_install_folder}/download/unpack
abort_if_failed "failed to create ${agent_install_folder}/download/unpack"
log_info "finish creating download folder"


if [ "$1" == "-update" ]; then
    log_info "override ${agent_install_folder}/agent/collectors/conf use by before"
    yes | cp -rf ${working_folder}/conf ${agent_install_folder}/agent/collectors
    yes | rm -rf ${working_folder}/conf
    yes | cp -f  ${working_folder}/cloudwiz-agent-bk-${current_time}/agent/run ${agent_install_folder}/agent/
    #yes | cp -f  ${working_folder}/cloudwiz-agent-bk-${current_time}/filebeat/filebeat.yml ${agent_install_folder}/filebeat
#    yes | cp -f  ${working_folder}/cloudwiz-agent-bk-${current_time}/filebeat/user.conf ${agent_install_folder}/filebeat
#    if [ "$?" != "0" ];then
#       yes | cp -f  ${working_folder}/cloudwiz-agent-bk-${current_time}/filebeat-5.4.2-linux-x86_64/user.conf ${agent_install_folder}/filebeat
#    fi
else
    chown -R $USER:$USER ${agent_install_folder}

    update_localhost ${agent_install_folder}/agent/collectors/conf/elasticsearchstat.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/flume.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/hbase_regionserver_info.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/map_reduce.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/mongo3.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/nginx.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/postgresql.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/rabbit_mq.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/spark.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/ssdb_state.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/storm.conf
    update_localhost ${agent_install_folder}/agent/collectors/conf/yarn.conf
fi

if [ "${HOST_NAME}_" != "_" ] ;then
      sed -i "/hostname=/c\ " ${agent_install_folder}/agent/collectors/conf/linux_host_scan.conf
      sed -i '/^ *$/d' ${agent_install_folder}/agent/collectors/conf/linux_host_scan.conf
      sed -i '$a hostname='${HOST_NAME} ${agent_install_folder}/agent/collectors/conf/linux_host_scan.conf
fi

#get ip as hostname (just for weibo)
#add "IP_AS_HOSTNAME=True" in the install command line to use ip as hostname
export PYTHONPATH=${agent_install_folder}/agent
export LD_LIBRARY_PATH=${agent_install_folder}/agent/collectors/lib
if [ ! -z ${IP_AS_HOSTNAME} ] && [[ ${IP_AS_HOSTNAME} == "True" ]]; then
    ${agent_install_folder}/altenv/bin/python ${agent_install_folder}/agent/collectors/builtin/get_host_ip.py
fi

# chown -hR "$agent_user" "${agent_install_folder}"
# abort_if_failed "failed to change ownership of ${agent_install_folder}/download to $agent_user"

# Start the agent
<:agent_root:>/cloudwiz-agent/cloudwiz-agent start

# Setup agent to auto start on reboot
_done=false

if is_systemd_running; then
    cp <:agent_root:>/cloudwiz-agent/cloudwiz-agent.service /etc/systemd/system/
    if [ $? -eq 0 ]; then
        systemctl enable cloudwiz-agent.service
        if [ $? -eq 0 ]; then
            _done=true
        fi
    else
        log_info "Unable to write to /etc/systemd/system"
    fi
fi

if ! $_done && grep_for_process init >/dev/null; then
    cp <:agent_root:>/cloudwiz-agent/cloudwiz-agent /etc/init.d/
    if [ $? -eq 0 ]; then
        chkconfig --add cloudwiz-agent
        chkconfig --level 2345 cloudwiz-agent on
        if [ $? -eq 0 ]; then
            _done=true
        fi
    else
        log_info "Unable to write to /etc/init.d"
    fi
fi

if ! $_done; then
    # add a cron job to auto start agent on reboot
    crontab -l | grep 'reboot' | grep 'cloudwiz-agent'

    if [ $? -ne 0 ]; then
        (crontab -l 2>/dev/null; echo -e "@reboot <:agent_root:>/cloudwiz-agent/cloudwiz-agent start\n6 * * * * <:agent_root:>/cloudwiz-agent/agent_watcher.sh") | crontab -
    fi
fi

log_info 'Done!'
