#!<:install_root:>/supervisord/altenv/bin/python2.7

import base64
import time
import logging
import signal
import update_manager
import subprocess
import sys
from optparse import OptionParser
from os import path
sys.path.append(path.abspath(path.join(path.dirname(__file__), path.pardir)))
sys.path.append("<:install_root:>/agent/cloudwiz-agent/agent")
sys.path.append("<:install_root:>/agent/cloudwiz-agent/agent/collectors/lib")
sys.path.append("<:install_root:>/kazoo")
import common_utils
from datetime import datetime, timedelta
from kazoo.client import KazooClient
import pymysql as MySQLdb

GET_TOKENS_SH = '<:install_root:>/umanager/bin/get_tokens.sh'
DEFAULT_LOG_FILE = '<:log_root:>/umanager/umanager.log'
LOG = logging.getLogger('umanager')

# configurations
INTERVAL = 5
ZOOKEEPER = "<:nginx_ip:>:2182"

MYSQL_HOST = "<:nginx_ip:>"
MYSQL_PORT = 3308
MYSQL_USERNAME = "<:mysql_username:>"
MYSQL_PASSWORD = "<:mysql_password:>"

shutdown_requested = False

def shutdown_signal(signum, frame):
    shutdown_requested = True
    LOG.info("shutting down, got signal %d", signum)

def sleep_for(seconds):
    for s in range(0, seconds):
        if shutdown_requested:
            exit(0)
        time.sleep(1)

def get_current_time():

    global MYSQL_HOST
    global MYSQL_PORT
    global MYSQL_USERNAME
    global MYSQL_PASSWORD

    db = MySQLdb.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USERNAME,
        passwd=MYSQL_PASSWORD,
        ssl=None,
        connect_timeout=5   # seconds
        )
    cursor = db.cursor()
    cursor.execute("SELECT NOW()");
    rs = cursor.fetchall()
    ts = str(rs[0][0])
    db.close()
    return ts


def main(argv):

    global MYSQL_PASSWORD

    options, args = parse_cmdline(argv)
    common_utils.setup_logging(LOG, options.logfile, 64 * 1024 * 1024, 1)
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, shutdown_signal)

    # Trying to become master in order to proceed
    zk = KazooClient(hosts=ZOOKEEPER)
    zk.start()
    lock = zk.Lock('/umanager')
    subprocess.call(GET_TOKENS_SH)

    MYSQL_PASSWORD = base64.b64decode(MYSQL_PASSWORD)

    with lock:
        LOG.info("I am the master of the universe!")
        count = 0
        lastHourDateTime = datetime.strptime(get_current_time(), "%Y-%m-%d %H:%M:%S") - timedelta(days=1)
        while not shutdown_requested:
            LOG.info("update manager daemon starting...")
            try:
                if (count % 100) == 0:
                    LOG.info("reloading tokens")
                    try:
                        subprocess.call(GET_TOKENS_SH)
                    except:
                        LOG.info("Failed to update tokens")
                count += 1

                manager = update_manager.UpdateManager(LOG)
                fromTime = datetime.strptime(str(lastHourDateTime), "%Y-%m-%d %H:%M:%S") - timedelta(seconds=128)
                toTime = get_current_time()
                LOG.info("from %s to %s", fromTime, toTime)
                exit_code = manager.run(fromTime, toTime)
                LOG.info("update manager daemon finished. exit code %d. sleep for %d seconds.", exit_code, INTERVAL)
                if exit_code == 0:
                    lastHourDateTime = datetime.strptime(toTime, "%Y-%m-%d %H:%M:%S") - timedelta(seconds=1)
                sleep_for(INTERVAL)
                # in case the update agent itself was upgraded
                LOG.info("reloading update manager package...")
                reload(update_manager)
                LOG.info("reloaded update_manager package.")
            except SystemExit:
                LOG.info("shutting down, exit")
                exit(0)
            except:
                LOG.exception("failed to run one iteration of update_manager. ignore error and retry after 2 seconds")
                sleep_for(2)

    zk.stop()
    return 0


def parse_cmdline(argv):
    parser = OptionParser(description='update manager options')
    parser.add_option('--logfile', dest='logfile', type='str',
                      default=DEFAULT_LOG_FILE,
                      help='Filename where logs are written to.')
    (options, args) = parser.parse_args(args=argv[1:])
    return options, args

if __name__ == "__main__":
    main(sys.argv)
