#!<:install_root:>/supervisord/altenv/bin/python2.7

import ast
import ConfigParser
import gnupg
import json
import os
import requests
import shutil
import stat
import sys
import tarfile
import time

#from datetime import datetime, timedelta
from subprocess import call
from uagent import calc_checksum


config = ConfigParser.SafeConfigParser()
config.read(os.path.join('<:install_root:>/umanager/config/umanager.conf'))

INSTALL_CONF = config.get('files', 'install_conf')
INSTALL_FILE = config.get('files', 'install_script')
PACKAGE_FILE = config.get('files', 'package_file')
PACKAGE_FILE_SIG = config.get('files', 'package_file_sig')
VERSION_JSON = config.get('files', 'version_file')
VERSION_JSON_SIG = config.get('files', 'version_file_sig')
TMP_DIR = config.get('dirs', 'tmp_dir')
TOKEN_FILE = config.get('dirs', 'tokens')
NGINX_DIR = config.get('dirs', 'nginx_dir')
INTERVAL = config.get('runtime', 'interval')
SIGNING_KEY = config.get('runtime', 'signing_key')
ALERTD_URL = config.get('urls', 'alertd') + "?token="
CMDB_URL = config.get('urls', 'cmdb')
GNUPG_HOME = config.get('dirs', 'gnupg_home')

PROSPECTOR_FIELDS = ["input_type", "document_type", "fields.client", "fields.orgid", "fields.sysid", "fields.token", "fields_under_root", "close_\*", "tail_files", "multiline.pattern", "multiline.negate", "multiline.match"]

# Remember versions and platforms of all hosts
VERSIONS = {}
PLATFORMS = {}
TOKENS = []


def read_tokens():
    global TOKENS
    with open(TOKEN_FILE, "r") as f:
        TOKENS = f.readlines()

def sign_file(filename):
    gpg = gnupg.GPG(gnupghome=GNUPG_HOME)
    with open(filename, "rb") as fh:
        signed_data = gpg.sign_file(fh, keyid=SIGNING_KEY, detach=True, output=filename+".sig")

def make_targz(output_filename, source_dir):
    tar = tarfile.open(output_filename, "w:gz")
    for root, dir, files in os.walk(source_dir):
        for file in files:
            fullpath = os.path.join(root, file)
            tar.add(fullpath, arcname=file)
    tar.close()

def check_and_clear(dir_path):
    if os.path.isdir(dir_path):
        shutil.rmtree(dir_path)
    os.makedirs(dir_path)

def generate_key(org, sys, hostname):
    return str(org) + '_' + str(sys) + '_' + str(hostname)

def getUpdatedConfig(fromTime, toTime):
    global TOKENS
    configs = []
    read_tokens()
    for token in TOKENS:
        url = ALERTD_URL + token.strip() + "&fromTime=" + str(fromTime) + "&toTime=" + str(toTime)
        with requests.get(url, timeout=10) as r:
            try:
                configs += json.loads(r.text)
            except Exception as ex:
                pass
    return configs

def get_current_version():
    global CMDB_URL

    # major
    r = requests.get(CMDB_URL+"major", timeout=10)
    if r.status_code != requests.codes.ok:
        raise ValueError('Failed to retrieve current version of the agent')
    major = int(r.content)

    # minor
    r = requests.get(CMDB_URL+"minor", timeout=10)
    if r.status_code != requests.codes.ok:
        raise ValueError('Failed to retrieve current version of the agent')
    minor = int(r.content)

    # patch
    r = requests.get(CMDB_URL+"patch", timeout=10)
    if r.status_code != requests.codes.ok:
        raise ValueError('Failed to retrieve current version of the agent')
    patch = int(r.content)

    return "{0}.{1}.{2}".format(major, minor, patch)


# Core update file managing class
class UpdateManager:
    def __init__(self, logger):
        self._logger = NullableLogger(logger)
        check_and_clear(TMP_DIR)

    def config_to_str(self, config):
        msg = ""

        if 'orgId' in config:
            msg += " org=" + str(config['orgId'])
        else:
            msg += " org=null"

        if 'sysId' in config:
            msg += " sys=" + str(config['sysId'])
        else:
            msg += " sys=null"

        if 'hostname' in config:
            msg += " host=" + str(config['hostname'])
        else:
            msg += " host=null"

        if 'serviceName' in config:
            msg += " service=" + str(config['serviceName'])
        else:
            msg += " service=null"

        if 'configName' in config:
            msg += " conf=" + str(config['configName'])
        else:
            msg += " conf=null"

        if 'platform' in config:
            msg += " platform=" + str(config['platform'])
        else:
            msg += " platform=null"

        return msg

    def cleanup(self, host_dir):
        for f in list(os.listdir(host_dir)):
            if (f != PACKAGE_FILE) and (f != PACKAGE_FILE_SIG) and (f != VERSION_JSON) and (f != VERSION_JSON_SIG):
                os.remove(os.path.join(host_dir, f))

    # Packaging updated file for each host
    def packager(self):
        global VERSIONS
        global PLATFORMS

        for org in list(os.listdir(TMP_DIR)):
            for sys in list(os.listdir(os.path.join(TMP_DIR, org))):
                for host in list(os.listdir(os.path.join(TMP_DIR, org, sys))):
                    try:
                        self._logger.log_info("Packaging config: org=%s, sys=%s, host=%s", str(org), str(sys), str(host))
                        host_dir = os.path.join(TMP_DIR, org, sys, host)

                        # update install.conf
                        self._logger.log_info("Generating install.conf")
                        with open(os.path.join(host_dir, INSTALL_CONF), "a") as f:
                            f.write("\n")
                            f.write("[uagent]\n")
                            f.write("logfile: <:agent_root:>/cloudwiz-agent/altenv/var/log/uagent.log\n")

                            # Needs to restart filebeat after changing its config
                            # NOTE: We assume filebeat config file is named: filebeat.yml
                            if os.path.exists(os.path.join(host_dir, "filebeat.yml")):
                                f.write("\n")
                                f.write("[commands]\n")
                                f.write("cmd0: <:agent_root:>/cloudwiz-agent/altenv/bin/supervisorctl restart cloudwiz-agent:filebeat\n")

                        # include the install.py script
                        shutil.copy2("<:install_root:>/umanager/scripts/copy_configs.py", os.path.join(host_dir, INSTALL_FILE))

                        # create agent.tar.gz
                        packageFile = os.path.join(host_dir, PACKAGE_FILE)
                        self._logger.log_info("Creating %s", str(packageFile))
                        make_targz(packageFile, host_dir)

                        # calculate checksum of the package file
                        checksum = calc_checksum(packageFile)

                        # generate version.json
                        self._logger.log_info("Generating version.json")
                        curr_version = get_current_version()
                        key = generate_key(org, sys, host)
                        version = VERSIONS[key]
                        platform = PLATFORMS[key]
                        with open(os.path.join(host_dir, VERSION_JSON), "w") as f:
                            f.write('{\n')
                            f.write('    "version": "%s.%d",\n' % (curr_version, long(version)))
                            f.write('    "platform": "%s",\n' % platform)
                            f.write('    "checksum": "%s",\n' % checksum)
                            f.write('    "upgradeFrom": "1.0.0.0-%s.%d",\n' % (curr_version, long(version)))
                            f.write('    "packageFile": "%s"\n' % PACKAGE_FILE)
                            f.write('}\n')

                        # sign files
                        self._logger.log_info("Signing %s...", packageFile)
                        sign_file(packageFile)
                        sign_file(os.path.join(host_dir, VERSION_JSON))

                        # cleanup
                        self.cleanup(host_dir)
                    except:
                        self._logger.log_error("Failed to package config: org=%s, sys=%s, host=%s", str(org), str(sys), str(host))

    def install_conf(self, host_dir, config):
        if not os.path.exists(host_dir):
            check_and_clear(host_dir)
        configFile = config['fullPath'].split("/")[-1]
        installConf = os.path.join(host_dir, INSTALL_CONF)
        installConfExist = True

        if not os.path.exists(installConf):
            installConfExist = False

        # generate config file for the python script to copy these files to where they should go
        with open(os.path.join(host_dir, INSTALL_CONF), "a") as f:
            if not installConfExist:
                f.write("[copy]\n")
            f.write("%s: %s\n" % (configFile, config['fullPath']))

    def collector(self, host_dir, config):
        self._logger.log_info("Processing collector config: %s", host_dir)
        configFile = config['fullPath'].split("/")[-1]
        configFile = os.path.join(host_dir, configFile)

        # generate the config file itself
        content = config['content']
        with open(configFile, "w") as f:
            for section in content:
                f.write("[%s]\n" % section['name'])
                props = section['props']
                for prop in props:
                    f.write("%s: %s\n" % (prop['name'], prop['value']))
        self._logger.log_info("Success!")

    def filebeat(self, host_dir, config):
        self._logger.log_info("Processing filebeat config: %s", host_dir)
        configFile = config['fullPath'].split("/")[-1]
        configFile = os.path.join(host_dir, configFile)

        # generate the config file itself
        content = config['content']
        with open(configFile, "w") as f:
            prospectors = content['filebeat.prospectors']
            f.write("filebeat.prospectors:\n\n")
            for prospector in prospectors:
                f.write("-\n")
                if 'paths' in prospector:
                    paths = prospector['paths']
                    f.write("  paths:\n")
                    for path in paths:
                        f.write("    - " + path + "\n")
                for field in PROSPECTOR_FIELDS:
                    if field in prospector:
                        f.write("  " + str(field) + ": " + str(prospector[field]) + "\n")
                for field in prospector:
                    if field in PROSPECTOR_FIELDS:
                        pass
                    elif field != "paths":
                        f.write("  " + str(field) + ": " + str(prospector[field]) + "\n")

            output = content['output.logstash']
            f.write("\n\noutput.logstash:\n")
            if 'hosts' in output:
                f.write("  hosts: [")
                hosts = output['hosts']
                first = True
                for host in hosts:
                    if not first:
                        f.write(", ")
                    f.write('"' + str(host) + '"')
                    first = False
                f.write("]\n")
            if 'version' in output:
                f.write('  version: "' + str(output["version"]) + '"\n')
            for field in output:
                if field != "hosts" and field != "version":
                    f.write("  " + str(field) + ": " + str(output[field]) + "\n")

            logging = content['logging']
            f.write("\n\nlogging:\n")
            files = logging['files']
            f.write("  files:\n")
            for ff in files:
                f.write("    " + str(ff) + ": " + str(files[ff]) + "\n")
            for field in logging:
                if field != "files" and field != "version":
                    f.write("  " + str(field) + ": " + str(logging[field]) + "\n")
        # If the following line gives you trouble, turn off SELinux ACL by
        # changing SELINUX=enforcing to SELINUX=permissive in /etc/sysconfig/selinux
        try:
            os.chown(configFile, 0, 0)
            os.chmod(configFile, stat.S_IREAD)
        except:
            pass
        self._logger.log_info("Success!")

    def fetcher(self, fromTime, toTime):
        global VERSIONS
        global PLATFORMS

        check_and_clear(TMP_DIR)

        # Get Modified Configs
        items = getUpdatedConfig(fromTime, toTime)

        for item in items:
            try:
                self._logger.log_info("Processing config:%s", self.config_to_str(item))

                host_dir = os.path.join(TMP_DIR, str(item['orgId']), str(item['sysId']), str(item['hostname']))
                self.install_conf(host_dir, item)

                key = generate_key(item['orgId'], item['sysId'], item['hostname'])

                version = item["configVersion"]
                if key in VERSIONS:
                    if int(VERSIONS[key]) < int(version):
                        VERSIONS[key] = version
                else:
                    VERSIONS[key] = version

                platform = item['platform']
                if key in PLATFORMS:
                    if PLATFORMS[key] != platform:
                        self._logger.log_error("Inconsistent platform for host %s", item['hostname'])
                else:
                    PLATFORMS[key] = platform

                if item["serviceName"] == "filebeat":
                    self.filebeat(host_dir, item)
                elif item["serviceName"] == "collector":
                    self.collector(host_dir, item)
                else:
                    self._logger.log_error("Unknown service: %s", item["serviceName"])
            except Exception as ex:
                self._logger.log_error("Failed: %s", ex.message)

    def deployer(self):
        # copy everything under TMP_DIR to NGINX_DIR
        try:
            for org in list(os.listdir(TMP_DIR)):
                cmd = "/bin/cp -rf " + os.path.join(TMP_DIR,org) + " " + NGINX_DIR
                self._logger.log_info(cmd)
                call(cmd.split(" "))
        except Exception as ex:
            self._logger.log_error("Command failed: %s, Exception: %s", cmd, ex.message)

    def run(self, fromTime, toTime):
        self._logger.log_info("Starting UpdateManager")
        self.fetcher(fromTime, toTime)
        self.packager()
        self.deployer()
        self._logger.log_info("Finished UpdateManager")
        return 0


class NullableLogger:
    def __init__(self, logger):
        self._logger_writter = logger

    def log_info(self, msg, *args, **kwargs):
        if self._logger_writter:
            self._logger_writter.info(msg, *args, **kwargs)
        else:
            sys.stdout.write(("INFO: " + msg + "\n") % args)

    def log_error(self, msg, *args, **kwargs):
        if self._logger_writter:
            self._logger_writter.error(msg, *args, **kwargs)
        else:
            sys.stderr.write(("ERROR: " + msg + "\n") % args)

    def log_exception(self, msg, *args, **kwargs):
        if self._logger_writter:
            self._logger_writter.exception(msg, *args, **kwargs)
        else:
            sys.stderr.write(("ERROR: " + msg + "\n") % args)


if __name__ == '__main__':
    um = UpdateManager(None)
    um.run("2000-01-01 00:00:00", "2020-01-01 00:00:00")
