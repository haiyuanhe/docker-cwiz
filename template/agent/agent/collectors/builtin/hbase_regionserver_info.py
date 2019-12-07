import time
from collectors.lib.collectorbase import CollectorBase
from collectors.lib import utils
import os
import ast
import subprocess
import psutil
import re
import requests


class HbaseRegionserverInfo(CollectorBase):
    def __init__(self, config, logger, readq):
        super(HbaseRegionserverInfo, self).__init__(config, logger, readq)
        self.threshold = self.get_config('threshold', 100)
        self.hbase_bin_str = self.get_config("hbase_bin", "hbase")
        self.cmd = ['which', self.hbase_bin_str]
        self.hbase_shell_file = os.path.dirname(os.path.abspath(__file__)) + "/hbase_regionserver_info"
        self.hbase_cmd = [self.hbase_bin_str, 'shell', self.hbase_shell_file]
        self.recomplite = re.compile(r'^\s{1,}')
        self.tags = "table_name=%s table_region_node=%s region_on_host=%s"
        self.master_status_urls = ast.literal_eval(self.get_config("master_status_url", "[\"http://localhost:16010/master-status\"]"))
        self.host_url_pattern = re.compile(r'"|<|>')
        self.region_id_pattern = re.compile(r'<td>.{2,}</td>')
        self.host_region_id = {}
        self.table_stats = TableStats(readq, self.get_config("state_file", "/tmp/hbase_regionserver_info.txt"), self.threshold, self.tags)

    def __call__(self):
        if not self._exist_hbase():
            self.log_warn("Hbase or which does not exist!")
            return

        self.ts = time.time()
        self._send_metrics()

    def get_region_host(self, table_region_node):
        region_host = '_'
        for host, region_ids in self.host_region_id.items():
            if table_region_node in region_ids:
                region_host = host
                break
        return region_host

    def _send_metrics(self):
        if not self.set_region_on_host():
            return  # this is not a master
        with psutil.Popen(self.hbase_cmd, stdout=subprocess.PIPE) as proc:
            out = proc.stdout
            line = out.readline()
            stack = []
            while line:
                spaces = self.recomplite.findall(line)
                if len(spaces) > 0 and len(spaces[0]) == 12:
                    tags_line = stack.pop()
                    tags = tags_line.replace('"', '').split(',')
                    table_name = utils.remove_invalid_characters(tags[0].strip())
                    if tags[0].strip() == 'hbase:meta':
                        stack.append(tags_line)
                        table_region_node = tags[-1].strip().split('.')[-1]
                    else:
                        table_region_node = tags[-1].strip().split('.')[-2]
                    region_host = self.get_region_host(table_region_node)
                    if region_host != '_':
                        region_host = utils.remove_invalid_characters(region_host)
                        tags = self.tags % (table_name, table_region_node, region_host)
                        for metric in line.replace('NaN', "0").replace(r'\s+', '').split(','):
                            metric_name, value = utils.remove_invalid_characters(metric.split('=')[0].strip()), metric.split('=')[1].strip()
                            if metric_name.endswith("Count"):
                                self.table_stats.add_stat(table_name, metric_name, table_region_node, region_host, value)
                            else:
                                self._readq.nput("hbase.regionserver.info.%s %d %s %s" % (metric_name, self.ts, value, tags))
                else:
                    stack.append(line)
                line = out.readline()
        self.table_stats.send_metrics(self.ts)

    def set_host_has_region_ids(self, dict_host):
        for host in dict_host:
            url = "http:%s" % dict_host[host]
            if not url.endswith('/rs-status'):
                if url.endswith('/'):
                    url = url + 'rs-status'
                else:
                    url = url + '/rs-status'
            region_page = self.get_request_line_list(url)
            region_id_set = self.server_has_region_id(region_page)
            dict_host[host] = region_id_set

    def set_region_on_host(self):
        try:
            dict_host = self.get_host_region_url()
            if len(dict_host) == 0:
                return False
            self.set_host_has_region_ids(dict_host)
            self.host_region_id = dict_host
            return True
        except Exception:
            self.log_exception("when setting region on host!")
            return False

    def server_has_region_id(self, lines):
        region_set = set()
        page_split = lines.split(r'<th>Region Name</th>')
        td_list = page_split[1].split('\n')
        for td in td_list:
            table = self.region_id_pattern.findall(td)
            if len(table) > 0 and ',' in table[0]:
                region_name = table[0].replace('<td>', '').replace('</td>', '').strip()
                region_name_infos = region_name.split(r'.')
                if len(region_name_infos) > 1 :
                    if  'hbase:meta' in table[0]:
                        region_id = region_name_infos[-1]
                    else:
                        region_id = region_name_infos[-2]
                    region_set.add(region_id)
        return region_set

    def get_host_region_url(self):
        host_dict = {}
        if len(self.master_status_urls):
            for url in self.master_status_urls:
                num_regions_found = False
                lines = self.get_request_line_list(url).split('\n')
                for line in lines:
                    if 'Num. Regions' in line:
                        num_regions_found = True
                        continue
                    if not num_regions_found:
                        continue
                    if 'href' in line:
                        line_list = self.host_url_pattern.split(line)
                        region_host_name = line_list[4].split(',')[0]
                        if not host_dict.has_key(region_host_name):
                            host_dict[region_host_name] = line_list[2]
                    if 'Total:' in line:
                        break
                if host_dict:
                    break
        return host_dict

    def get_request_line_list(self, url):
        try:
            r = requests.get(url)
            r.raise_for_status()
            lines = r.content
            return lines
        except Exception:
            self.log_exception(url)
            return []

    def _exist_hbase(self):
        with psutil.Popen(self.cmd, stdout=subprocess.PIPE) as proc:
            res = proc.stdout.readlines()
            if len(res) == 0: return False
            return True


class TableStats():
    def __init__(self, readq, state_file, threshold, tags):
        self.readq = readq
        self.state_file = state_file
        self.threshold = threshold
        self.tags = tags
        self.tables = {}
        self.prev_state = {}
        self.curr_state = {}
        self.load_state()

    def add_stat(self, table, metric, region, host, value):
        value = self.add_state(table, metric, region, host, value)

        if table in self.tables:
            metrics = self.tables[table]
        else:
            metrics = {}
            self.tables[table] = metrics

        if metric in metrics:
            datapoint = metrics[metric]
            _n = datapoint[0]
            _avg = datapoint[1]
            _min = datapoint[2]
            _max = datapoint[3]

            _avg = (float(_avg) * float(_n) + float(value)) / (float(_n) + 1.0)
            _n = int(_n) + 1
            _min = min(float(_min), float(value))
            _max = max(float(_max), float(value))

            datapoint[0] = _n
            datapoint[1] = _avg
            datapoint[2] = _min
            datapoint[3] = _max
        else:
            datapoint = [1, value, value, value]
            metrics[metric] = datapoint

    def send_metrics(self, ts):
        for table in self.tables:
            metrics = self.tables[table]
            for metric in metrics:
                datapoint = metrics[metric]
                _n = datapoint[0]
                _avg = datapoint[1]
                _min = datapoint[2]
                _max = datapoint[3]

                tbl = utils.remove_invalid_characters(table)
                val = max(abs(float(_max) - float(_avg)), abs(float(_avg) - float(_min)))
                self.readq.nput("hbase.regionserver.info.%s.delta %d %f host=%s" % (metric, ts, val, tbl))

                if float(_avg) > 0.001 and float(val) > float(self.threshold):
                    val = val / abs(float(_avg))
                    self.readq.nput("hbase.regionserver.info.%s.dev %d %f host=%s" % (metric, ts, val, tbl))
                else:
                    self.readq.nput("hbase.regionserver.info.%s.dev %d 0.0 host=%s" % (metric, ts, tbl))

                if metric.endswith("Count"):
                    try:
                        real_metric = metric.replace("Count", "Cnt")
                        curr_regions = self.curr_state[table][metric]
                        prev_regions = self.prev_state[table][metric]
                        for region in curr_regions:
                            tags = self.tags % (tbl, region, curr_regions[region][1])
                            if region in prev_regions:
                                _cnt = abs(int(curr_regions[region][0]) - int(prev_regions[region][0]))
                            else:
                                _cnt = int(curr_regions[region][0])
                            self.readq.nput("hbase.regionserver.info.%s %d %d %s" % (real_metric, ts, _cnt, tags))
                    except:
                        pass
        self.save_state()
        self.tables = {}

    def save_state(self):
        try:
            with open(self.state_file, "w") as f:
                f.write(str(self.curr_state))
            self.prev_state = self.curr_state
            self.curr_state = {}
        except:
            pass

    def load_state(self):
        try:
            with open(self.state_file, "r") as f:
                self.prev_state = ast.literal_eval(f.readlines()[0])
        except:
            pass

    def add_state(self, table, metric, region, host, value):
        if not metric.endswith("Count"):
            return value

        # add to current state
        if table in self.curr_state:
            metrics = self.curr_state[table]
        else:
            metrics = {}
            self.curr_state[table] = metrics

        if metric in metrics:
            regions = metrics[metric]
        else:
            regions = {}
            metrics[metric] = regions

        regions[region] = [value, host]

        # calculate change from prev_state
        if table in self.prev_state:
            metrics = self.prev_state[table]
        else:
            metrics = {}

        if metric in metrics:
            regions = metrics[metric]
        else:
            regions = {}

        if region in regions:
            prev_value = regions[region][0]
            value = abs(int(value) - int(prev_value))

        return value


if __name__ == '__main__':

    import ConfigParser
    from collectors.lib.utils import TestQueue
    from collectors.lib.utils import TestLogger

    config = ConfigParser.SafeConfigParser()
    config.read("../conf/hbase_regionserver_info.conf")

    test = HbaseRegionserverInfo(config, TestLogger(), TestQueue())
    test.__call__()
