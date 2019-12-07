# Accepted parameters:
#
# $AGENT_URL = http://download.cloudwiz.cn/agent
# $ALERTD_SERVER = http://192.168.1.204:5001
# $CLIENT_ID = 2
# $INSTALL_ROOT = C:\opt\cloudwiz-agent
# $LOG_SERVER = 192.168.1.204:9906
# $METRIC_SERVER = 192.168.1.204:4242
# $ONLINE = [0|1]
# $ORG_TOKEN = ...
# $OS_VERSION = windows
# $SSL = [0|1]
# $SYSTEM_ID = 2
# $UPDATE = [0|1]

$filebeat_service="cloudwiz-agent:filebeat"
$collector_service="cloudwiz-agent:collector"
$winlogbeat_service="winlogbeat"
$install_dir='C:\opt\cloudwiz-agent'
$online_dir='C:\tmp\online'
$online_zip="${online_dir}\cloudwiz-agent-amd64.zip"
$offline_dir='C:\tmp\publish\windows'
$offline_zip="$offline_dir\cloudwiz-agent-amd64.zip"
$today = get-date
$current_time =$today.ToString('yyyy-MM-dd_HH_mm_ss')
$trash_dir = "C:\tmp\trash"
$trash_dir_tmp = "${trash_dir}\cloudwiz-agent_${current_time}"
$ssl_enabled = 0
$python_alter = "$install_dir\altenv\bin\python.exe"
$time_sleep = 3

$agent_main_conf = ""
$pythonservice_conf = ""
$log_server_port = ""
$collector_dir = ""
$logfile = ""
$pidfile = ""


function collect_cmdline_args()
{
    if ("$INSTALL_ROOT" -ne "")
    {
        $global:install_dir = "$INSTALL_ROOT"
    }

    if ("$SSL" -ne "")
    {
        $global:ssl_enabled = "$SSL"
    }

    $default_port = "9906"
    if ("$LOG_SERVER" -ne "")
    {
        $global:log_server_port = "${LOG_SERVER}"
    }
    else
    {
        $global:log_server_port = ${METRIC_SERVER}.Split(":")[0]
        $global:log_server_port = "${global:log_server_port}:$default_port"
    }

    $global:agent_main_conf=$global:install_dir+"\agent\agent_main.conf"
    $global:collector_dir=$global:install_dir+"\agent\collectors"
    $global:logfile=$global:install_dir+"\altenv\var\log\collector.log"
    $global:pidfile=$global:install_dir+"\altenv\var\run\collector.pid"
    $global:pythonservice_conf=$global:install_dir+"\agent\PythonService.conf"
}

function first_stop_service()
{
    if ( Test-Path $global:install_dir )
    {
        echo "$global:install_dir exists."

        # Stop services
        stop_and_delete_service $filebeat_service
        stop_and_delete_service $collector_service
        stop_and_delete_service $winlogbeat_service

        if (!(test-path $trash_dir_tmp))
        {
            log_info "creating tmp directory $trash_dir_tmp"
            new-item -path $trash_dir_tmp -name tmp -type directory | out-null
        }

        try
        {
            log_info "save $global:install_dir to ${trash_dir_tmp}"
            move-item ${global:install_dir} ${trash_dir_tmp} -force -ErrorAction Stop | out-null
        }
        catch
        {
            log_console "${global:install_dir} Directory is in use!"
            exit
        }
    }
}

function online_install()
{
    $client = new-object System.Net.WebClient;
    if (!(test-path $online_dir))
    {
        new-item -path $online_dir -name tmp -type directory
    }

    $url = "${AGENT_URL}/${OS_VERSION}/cloudwiz-agent-amd64.zip"
    log_info "Downloading from $url"
    $client.DownloadFile("$url", $online_zip)

    install $online_zip
}

function offline_install()
{
    install $offline_zip
}

function stop_and_delete_service($service_name)
{
    if (Get-Service $service_name -ErrorAction SilentlyContinue)
    {
        $service = Get-WmiObject -Class Win32_Service -Filter "name='$service_name'"
        $service.StopService() | out-null

        if ($service_name -eq $filebeat_service)
        {
            sc_delete $service_name
        }
        elseif ($service_name -eq $winlogbeat_service)
        {
            sc_delete $service_name
        }
        else
        {
            sc_delete $service_name
        }


    }
}

function sc_delete($service)
{
    cmd /c "sc delete $service"
    log_info "$service is deleted!!"
    Start-Sleep $time_sleep
}

function install($src_zip)
{
    log_info "starting unzip from $src_zip to $global:install_dir"
    unzip $src_zip $global:install_dir | out-null

    generate_agent_main_conf
    generate_pythonservice_conf

    log_info "starting install collector sercice"
    install_collector_service
    log_info "success!!"

    log_info "starting install filebeat sercice"
    install_filebeat_service
    log_info "success!!"

    log_info "starting install filebeat sercice"
    install_winlogbeat_service
    log_info "success!!"

}

function UnzipFile([string]$souceFile, [string]$targetFolder)
{
    if (!(Test-Path $targetFolder))
    {
        mkdir $targetFolder
    }

    $shellApp = New-Object -ComObject Shell.Application
    $files = $shellApp.NameSpace($souceFile).Items()

    $files|%{if (Test-Path ("$targetFolder/{0}" -f  $_.name )){Remove-Item ("$targetFolder/{0}" -f  $_.name) -Force -Recurse}}
    $shellApp.NameSpace($targetFolder).CopyHere($files)
}

function isExist([string]$dir){
    if ( !(Test-Path $dir)){
    new-item -path c:\  -name $dir -type directory;
    }
}

function log_info($log)
{
    echo "$log `r"
}

function log_console($log)
{
    $host.UI.WriteErrorLine("$log")
}

function run_cmd($dir,$cmd)
{
    $cmd_str="pushd $dir & $cmd & popd"
    log_info("executed $cmd_str")
    cmd /c $cmd_str
}

Function unzip($zip_path, $install_dir)
{
    UnzipFile $zip_path $install_dir

    Get-ChildItem $install_dir | ForEach-Object -Process{
        if($_ -is [System.IO.DirectoryInfo])
        {
            $original_name=$_.Name
            if (($original_name -like "filebeat*") -or ($original_name -like "winlogbeat*"))
            {
                $component=$original_name -Split "-"
                $component=$component[0]

                if (!(Test-Path "$global:install_dir\$component"))
                {
                    if ( ${OS_VERSION}.StartsWith("windows2003"))
                    {

                        rename-item -path "$global:install_dir\$original_name" -Newname "$global:install_dir\$component"
                    }
                    else
                    {
                        #run_cmd $install_dir "mklink /d filebeat filebeat-5.4.2-windows-x86_64"
                        run_cmd $install_dir "mklink /d $component $original_name"
                    }
                }
            }

        }

    }

}

function install_collector_service()
{
    $collector_dir="$global:install_dir\agent"
    $install_collector="$python_alter PythonService.py --startup auto install"
    run_cmd $collector_dir $install_collector
}

function install_filebeat_service()
{
    $workdir="$global:install_dir\filebeat"
    New-Service -name $filebeat_service `
    -displayName $filebeat_service `
    -binaryPathName "`"$workdir\\filebeat.exe`" -c `"$workdir\\filebeat.yml`" -path.home `"$workdir`" -path.data `"C:\\ProgramData\\filebeat`""

    update_filebeat_yml
}

function install_winlogbeat_service()
{
    $workdir="$global:install_dir\winlogbeat"
#    New-Service -name $winlogbeat_service `
#    -displayName $winlogbeat_service `
#    -binaryPathName "`"$workdir\\winlogbeat.exe`" -c `"$workdir\\winlogbeat.yml`" -path.home `"$workdir`" -path.data `"C:\\ProgramData\\winlogbeat`""
    log_info "installing winlogbeat as a system service!"

    & "$workdir\install-service-winlogbeat.ps1"

    log_info "success!!"

    update_winlogbeat_yml
}

function update_filebeat_yml()
{
    replace_in_file $global:install_dir\filebeat\filebeat.yml '<agent_root>' $global:install_dir
    replace_in_file $global:install_dir\filebeat\filebeat.yml '<orgid>' $CLIENT_ID
    replace_in_file $global:install_dir\filebeat\filebeat.yml '<sysid>' $SYSTEM_ID
    replace_in_file $global:install_dir\filebeat\filebeat.yml '<token>' $ORG_TOKEN
    replace_in_file $global:install_dir\filebeat\filebeat.yml '<log-server-host-port>' "${global:log_server_port}"

    if ($global:ssl_enabled -eq 0)
    {
        replace_in_file $global:install_dir\filebeat\filebeat.yml '<ssl_enabled>' "false"
    }
    else
    {
        replace_in_file $global:install_dir\filebeat\filebeat.yml '<ssl_enabled>' "true"
    }
}

function update_winlogbeat_yml()
{
#    replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<:agent_root:>' $global:install_dir
    replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<orgid>' $CLIENT_ID
    replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<sysid>' $SYSTEM_ID
    replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<token>' $ORG_TOKEN
    replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<log-server-host-port>' "${global:log_server_port}"
    if ($global:ssl_enabled -eq 0)
    {
        replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<ssl_enabled>' "false"
    }
    else
    {
        replace_in_file $global:install_dir\winlogbeat\winlogbeat.yml '<ssl_enabled>' "true"
    }
}

function close_winlogbeat_eventlog()
{
    (Get-Content $global:install_dir\winlogbeat\winlogbeat.yml) -replace 'logging.to_eventlog: true', 'logging.to_eventlog: false' | Set-Content $global:install_dir\winlogbeat\winlogbeat.yml
}

function start_collector_service()
{
    $collector_dir="$global:install_dir\agent"
    $start_collector="$python_alter PythonService.py start"
    run_cmd $collector_dir $start_collector
}

function start_filebeat_service()
{
    $collector_dir="$global:install_dir\agent"
    $start_filebeat="sc start $filebeat_service"
    run_cmd $collector_dir $start_filebeat
}

function start_winlogbeat_service()
{
    log_info "Starting service winlogbeat."
    Start-Service $winlogbeat_service
    log_info "Done!!"
}



function update()
{
    Copy-Item $trash_dir_tmp\cloudwiz-agent\agent\collectors\conf\* $global:install_dir\agent\collectors\conf -force
    Copy-Item $trash_dir_tmp\cloudwiz-agent\filebeat\filebeat.yml $global:install_dir\filebeat -force
    Copy-Item $trash_dir_tmp\cloudwiz-agent\winlogbeat\winlogbeat.yml $global:install_dir\winlogbeat -force

    update_filebeat_yml
    update_winlogbeat_yml
    close_winlogbeat_eventlog
}

function main()
{
    collect_cmdline_args
    set_env_paths

    first_stop_service

    if ($ONLINE)
    {
        log_info "online install"
        online_install
    }
    else
    {
        log_info "offline_install"
        offline_install
    }

    if ($UPDATE)
    {
        update
    }
    else
    {
        enable_collectors
    }
    log_info "Done!"

    start_collector_service
    start_filebeat_service
    start_winlogbeat_service

}

function append_config([string]$file, [string]$key, [string]$value)
{
    if ($value)
    {
        echo "${key}: $value" | Out-File -Append -Encoding "ASCII" $file
    }
    else
    {
        echo "$key" | Out-File -Append -Encoding "ASCII" $file
    }
}

function add_env_path
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Name,

        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    if ($Container -ne 'Session')
    {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable($Name, $containerType) -split ';'
        if ($persistedPaths -notcontains $Path)
        {
            $persistedPaths = $persistedPaths + $Path | where { $_ }
            [Environment]::SetEnvironmentVariable($Name, $persistedPaths -join ';', $containerType)
        }
    }

    if (Test-Path -Path env:$Name)
    {
        $paths = (Get-Item -Path env:$Name).Value
    }
    else
    {
        $paths = ""
    }

    $envPaths = $paths -split ';'

    if ($envPaths -notcontains $Path)
    {
        $envPaths = $envPaths + $Path | where { $_ }
        $value = $envPaths -join ';'
        Set-Item -Path env:$Name -Value $value
    }
}

# generate PythonService.conf
function generate_pythonservice_conf()
{
    if (Test-Path $global:pythonservice_conf)
    {
        Remove-Item $global:pythonservice_conf
    }

    $tmp1 = ${METRIC_SERVER}.Split(":")
    $metric_host = $tmp1[0]

    $tmp2 = @()
    $metric_port = "80"

    if ($global:ssl_enabled -ne 0)
    {
        $metric_port = "443"
    }

    if ($tmp1.length -gt 1)
    {
        $tmp2 = $tmp1[1].Split("/")
        $metric_port = $tmp2[0]
    }
    else
    {
        $tmp2 = ${METRIC_SERVER}.Split("/")
    }

    append_config $global:pythonservice_conf "[base]"
    append_config $global:pythonservice_conf "install-root" $global:install_dir
    append_config $global:pythonservice_conf "collector-dir" $global:collector_dir
    append_config $global:pythonservice_conf "host" $metric_host
    append_config $global:pythonservice_conf "port" $metric_port
    append_config $global:pythonservice_conf "ssl" $global:ssl_enabled
    append_config $global:pythonservice_conf "logfile" $global:logfile
    append_config $global:pythonservice_conf "pidfile" $global:pidfile
    append_config $global:pythonservice_conf "dedup-interval" "0"

    if ($tmp2.length -gt 1)
    {
        append_config $global:pythonservice_conf "resource" $tmp2[1]
    }
}

function generate_agent_main_conf()
{
    append_config $global:agent_main_conf "token" $ORG_TOKEN
    append_config $global:agent_main_conf "host" ${METRIC_SERVER}.Split(":")[0]
    append_config $global:agent_main_conf "alertd_server_and_port" $ALERTD_SERVER

    if ("$PROXY_HOST" -ne "" -and "$PROXY_PORT" -ne "")
    {
        append_config $global:agent_main_conf "proxy_host" $PROXY_HOST
        append_config $global:agent_main_conf "proxy_port" $PROXY_PORT
    }
}

function set_env_paths()
{
    # Add the following directories to PATH
    #   $global:install_dir\altenv\bin
    #   $global:install_dir\altenv\bin\DLLs
    #   $global:install_dir\altenv\bin\Lib\site-packages\pywin32_system32
    #   $global:install_dir\altenv\bin\Lib\site-packages\win32
    #   $global:install_dir\altenv\bin\Lib\site-packages\win32\libs
    #   $global:install_dir\altenv\bin\libs
    add_env_path "Path" "$global:install_dir\altenv\bin\" "Machine"
    add_env_path "Path" "$global:install_dir\altenv\bin\DLLs\" "Machine"
    add_env_path "Path" "$global:install_dir\altenv\bin\Lib\site-packages\pywin32_system32\" "Machine"
    add_env_path "Path" "$global:install_dir\altenv\bin\Lib\site-packages\win32\" "Machine"
    add_env_path "Path" "$global:install_dir\altenv\bin\Lib\site-packages\win32\libs\" "Machine"
    add_env_path "Path" "$global:install_dir\altenv\bin\libs\" "Machine"

    # Add the following directories to PYTHONPATH
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\agent" "Machine"
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\altenv\bin" "Machine"
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\altenv\bin\DLLs" "Machine"
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\altenv\bin\Lib" "Machine"
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\altenv\bin\Lib\site-packages\pkg_resources\_vendor" "Machine"
    add_env_path "CWIZ_PYTHONPATH" "$global:install_dir\altenv\bin\libs" "Machine"
}

function replace_in_file()
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $filename,

        [Parameter(Mandatory=$true)]
        [string] $oldstring,

        [Parameter(Mandatory=$true)]
        [string] $newstring
    )

    if (Test-Path $filename)
    {
        (Get-Content $filename) -replace "$oldstring", "$newstring" | Set-Content $filename
    }
}

function enable_collectors()
{
    $collector_dir="$global:install_dir\agent"
    $enable_collector="$python_alter collector_mgr.py disable all"
    run_cmd $collector_dir $enable_collector

    $collector_conf = @("machine_summary.conf", "host_topn.conf", "win32_host_scan.conf", "win32_cpustats.conf", "win32_dfstats.conf", "win32_iostats.conf", "win32_memstats.conf", "win32_netstats.conf", "win32_procstats.conf")

    foreach ($collector in $collector_conf)
    {
        replace_in_file $global:install_dir\agent\collectors\conf\$collector "enabled = False" "enabled = True"
    }
    $show_collector="$python_alter collector_mgr.py list"
    run_cmd $collector_dir $show_collector
}

main
