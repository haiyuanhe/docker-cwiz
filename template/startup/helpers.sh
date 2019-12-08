#!/bin/bash

RED='\033[0;31m'
LIGHT_GREEN='\033[1;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

hbh=<:install_root:>/hbase
svctl=<:install_root:>/supervisord/altenv/bin/supervisorctl

function trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

function ok_or_abort() {
  if [ $? -ne 0 ]; then
     printf "${red}$1$. abort!${normal}\n"
     exit 1
  fi
}

container_started=false
function is_container_started() {
  existing_dns_file=$1
  host_name=$2
  # Remember to reset this before calling this func.
  container_started=false
  while read line; do
    if [[ -z $line ]] || [[ $line == \#* ]]; then
      continue
    elif [[ $line == *$host_name* ]]; then
      container_started=true
    fi
  done < $existing_dns_file
}

service_added_to_supervisord=false
function is_service_added_to_supervisord() {
  service_name=$1
  # Remember to reset the returned value beforehand.
  service_added_to_supervisord=false
  status=$($svctl status $service_name)
  if [[ $status == *STOPPED* || $status == *RUNNING* ]]; then
    service_added_to_supervisord=true
  fi
}

function wait_for_hbase_ready() {
  tables=$(echo 'list' | exec "$hbh/bin/hbase" shell)
  while [[ $tables == *"TABLE ERROR: Can't get master address from ZooKeeper"* ]]; 
  do
    echo "HBase is not ready! Please wait."
    sleep 5
    tables=$(echo 'list' | exec "$hbh/bin/hbase" shell)
  done
}

# $1: service_name
service_started=false
service_fatal=false
function is_service_running() {
    service_name=$1
    service_started=false
    service_status=$($svctl status ${service_name})
    if [[ $service_status == *RUNNING* ]]; then
       service_started=true
       echo -e "${LIGHT_GREEN}Done: ${local_host_ip}: ${service_status}! ${NC}"
    fi
}

function wait_for_service_running() {
    service_name=$1
    service_started=false
    service_fatal=false
    while [ $service_started == false -a $service_fatal == false ]; do
        service_status=$($svctl status ${service_name})
        if [[ $service_status == *RUNNING* ]]; then
	  service_started=true
          echo -e "${LIGHT_GREEN}Done: ${local_host_ip}: ${service_status}!${NC}"
        elif [[ $service_status == *FATAL* ]]; then
	  service_fatal=true
          echo -e "${RED}Done: ${local_host_ip}: ${service_status}!${NC}"
        else
	  sleep 5
          printf '.'
        fi
    done
}

function loop_check_and_launch_opentsdb() {
    $svctl restart opentsdb
    wait_for_service_running opentsdb
    echo -e "${LIGHT_GREEN}Opentsdb started in supervisor. Still need to check if 4242 port is listened!${NC}"
    
    while [ 1 ]; do

        _status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4242")
        if [ "$_status" -lt "300" ] && [ "$_status" -ge "200" ]; then
            break
        fi

        echo -e "${RED}Opentsdb 4242 port is not listened! Restart it again.${NC}"
        sleep 30
        $svctl restart opentsdb
        wait_for_service_running opentsdb
    done
    echo -e "${LIGHT_GREEN}Opentsdb started in supervisor and 4242 port is listened!${NC}"
}

function loop_check_and_launch_service() {
    serv_name=$1
    $svctl restart $serv_name
    wait_for_service_running $serv_name
    
    while [[ $service_started == false && $service_fatal == true ]]; do
        service_fatal=false # reset it.
        echo -e "${RED}$serv_name not started yet! Restart it again.${NC}"
        sleep 30
        $svctl restart $serv_name
        wait_for_service_running $serv_name
    done
    echo -e "${LIGHT_GREEN}$serv_name started in supervisor!${NC}"
}

function check_and_launch_service() {
   serv_name=$1
   echo -e "${LIGHT_GREEN}--To check and launch ${serv_name}${NC}"
   is_service_added_to_supervisord ${serv_name}
   is_service_running ${serv_name}
   echo -e "--${serv_name} inSupervisord:$service_added_to_supervisord running:$service_started"
   
   if [[ $service_added_to_supervisord == true && $service_started == false ]]; then
      echo -e "${LIGHT_GREEN}--${serv_name} in supervisor.conf and not running. To launch it.${NC}"
      if [[ $serv_name == "opentsdb" ]]; then
         loop_check_and_launch_opentsdb
      else
         loop_check_and_launch_service ${serv_name}
      fi
   fi
}
