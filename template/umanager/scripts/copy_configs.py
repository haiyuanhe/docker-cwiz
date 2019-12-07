#!<:agent_root:>/cloudwiz-agent/altenv/bin/python

import ConfigParser
import datetime
import os
import shutil
import sys
import subprocess

# read config from file
configFile = "install.conf"
currentDir = os.path.dirname(os.path.abspath(__file__))
config = ConfigParser.SafeConfigParser()
config.read(os.path.join(currentDir, configFile))

logFile = None

if config.has_option("uagent", "logfile"):
    logFile = config.get("uagent", "logfile")

def logSuccess(src, dst):
    try:
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S,%f')[:-3]
        with open(logFile, "a") as log:
            log.write("%s copy[configs] INFO successfully copied from %s to %s\n" % (ts, src, dst))
    except Exception as ex:
        pass

def logFailure(src, dst, msg):
    try:
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S,%f')[:-3]
        with open(logFile, "a") as log:
            log.write("%s copy[configs] ERROR failed to copied from %s to %s: %s\n" % (ts, src, dst, msg))
    except:
        pass

# copy files
exitcode = 0

if config.has_section("copy"):
    for src, dst in config.items("copy"):
        try:
            shutil.copy2(os.path.join(currentDir,src), dst)
            logSuccess(src, dst)
        except Exception as ex:
            exitcode = 1
            logFailure(src, dst, ex.message)

if config.has_section("commands"):
    for key, cmd in config.items("commands"):
        try:
            subprocess.call(cmd.split(" "))
            logSuccess(src, cmd)
        except Exception as ex:
            exitcode = 2
            logFailure(src, dst, ex.message)

sys.exit(exitcode)
