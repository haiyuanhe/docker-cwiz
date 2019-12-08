#!/usr/bin/python

import os
import time
import re
import subprocess
import utils
from jolokia import JolokiaCollector


class JolokiaAgentCollectorBase(JolokiaCollector):
    JOLOKIA_JAR = "jolokia-jvm-1.3.5-agent.jar"

    def __init__(self, config, logger, readq, jmx_request_json, parsers, processname,check_pid_interval, port):
        protocol = "http"
        self.port = port
        super(JolokiaAgentCollectorBase, self).__init__(config, logger, readq, protocol, self.port, jmx_request_json, parsers)
        workingdir = os.path.dirname(os.path.abspath(__file__))
        self.log_info("working dir is %s", workingdir)
        self.jolokia_file_path = os.path.join(workingdir, '../../lib', JolokiaAgentCollectorBase.JOLOKIA_JAR)
        if not os.path.isfile(self.jolokia_file_path):
            raise IOError("failed to find jolokia jar at %s" % self.jolokia_file_path)
        self.process_name = processname
        self.java_home = self.get_config(config, "java_home", "")
        self.check_pid_interval = check_pid_interval
        self.checkpid_time = 0
        self.process_pid = -1
        self.jolokia_process = None

    def __call__(self):
        curr_time = time.time()
        if curr_time - self.checkpid_time >= self.check_pid_interval:
            self.checkpid_time = curr_time
            pid, puser = utils.get_pid_and_user_by_pname(self.process_name)
            self.log_warn("print %s" % self.process_name)
            if pid is None and puser is None:
                raise Exception("failed to find %s process, One of the (pid, puser) pair is None (%s, %s)" % (self.process_name, str(pid), str(puser)))
            if self.process_pid != pid:
                self.log_info("found %s pid %s, puser %s", self.process_name, pid, puser)
                if self.jolokia_process is not None:
                    self.log_info("stop jolokia agent bound to old %s pid %s", self.process_name, self.process_pid)
                    self.stop_subprocess(self.jolokia_process, "jolokia JVM Agent")
                self.process_pid = pid
                self.log_info("jolokia agent binds to %s", pid)
                if self.java_home:
                    cmdstr = "su -c '%s/bin/java -jar %s --port %s start %s' %s" % (self.java_home, self.jolokia_file_path, self.port, pid, puser)
                else:
                    cmdstr = "su -c 'java -jar %s --port %s start %s' %s" % (self.jolokia_file_path, self.port, pid, puser)
                self.log_info("start jolokia agent %s", cmdstr)
                self.jolokia_process = subprocess.Popen(cmdstr, stdout=subprocess.PIPE, shell=True)
                self.log_info("jolokia process %s", self.jolokia_process.pid)
        super(JolokiaAgentCollectorBase, self).__call__()

    def cleanup(self):
        if self.jolokia_process is not None:
            self.log_info('stop subprocess %s', self.jolokia_process.pid)
            self.stop_subprocess(self.jolokia_process, __name__)

    def process_name(self):
        return self.process_name

    @staticmethod
    def get_config(config, key, default=None, section='base'):
        if config.has_option(section, key):
            return config.get(section, key)
        else:
            return default
