
USE `<:oneagent_database:>`;

-- id 1: 1000 是固定位置, 可以自主使用.



-- datadog id 从101开始
-- datadog config type = 6
-- datadog agent init
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(101, 'apache_yaml', 'Apache配置', 'apache.yaml', 'Apache 收集器配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('101', 'apache_yaml', '初始化', '1', 'apache_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(102, 'docker_daemon_yaml', 'Docker配置', 'docker_daemon.yaml', 'Docker收集器配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('102', 'docker_daemon_yaml', '初始化', '1', 'docker_daemon_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(103, 'elastic_yaml', 'elasticsearch配置', 'elastic.yaml', 'elastic收集器配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('103', 'elastic_yaml', '初始化', '1', 'elastic_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(104, 'hdfs_datanode_yaml', 'HadoopDatanode配置', 'hdfs_datanode.yaml', 'HadoopDatanode收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('104', 'hdfs_datanode_yaml', '初始化', '1', 'hdfs_datanode_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(105, 'hdfs_namenode_yaml', 'HadoopNamenode配置', 'hdfs_namenode.yaml', 'HadoopNamenode收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('105', 'hdfs_namenode_yaml', '初始化', '1', 'hdfs_namenode_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(106, 'haproxy_yaml', 'Haproxy配置', 'haproxy.yaml', 'Haproxy收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('106', 'haproxy_yaml', '初始化', '1', 'haproxy_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(107, 'host_topn_yaml', 'Process配置', 'host_topn.yaml', 'Process收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('107', 'host_topn_yaml', '初始化', '1', 'host_topn_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(108, 'http_check_yaml', 'Http配置', 'http_check.yaml', '网站Ping监控', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('108', 'http_check_yaml', '初始化', '1', 'http_check_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(109, 'kafka_yaml', 'kafka配置', 'kafka.yaml', 'kafka收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('109', 'kafka_yaml', '初始化', '1', 'kafka_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(110, 'mapreduce_yaml', 'mapreduce配置', 'mapreduce.yaml', 'mapreduce收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('110', 'mapreduce_yaml', '初始化', '1', 'mapreduce_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(111, 'mongo_yaml', 'mongo配置', 'mongo.yaml', 'mongo收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('111', 'mongo_yaml', '初始化', '1', 'mongo_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(112, 'mysql_yaml', 'mysql配置', 'mysql.yaml', 'mysql收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('112', 'mysql_yaml', '初始化', '1', 'mysql_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(113, 'nginx_yaml', 'nginx配置', 'nginx.yaml', 'nginx收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('113', 'nginx_yaml', '初始化', '1', 'nginx_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(114, 'oracle_yaml', 'oracle配置', 'oracle.yaml', 'oracle收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('114', 'oracle_yaml', '初始化', '1', 'oracle_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(115, 'postgresql_yaml', 'postgresql配置', 'postgresql.yaml', 'postgresql收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('115', 'postgresql_yaml', '初始化', '1', 'postgresql_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(116, 'rabbitmq_yaml', 'rabbitmq配置', 'rabbitmq.yaml', 'rabbitmq收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('116', 'rabbitmq_yaml', '初始化', '1', 'rabbitmq_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(117, 'redisdb_yaml', 'redisdb配置', 'redisdb.yaml', 'redisdb收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('117', 'redisdb_yaml', '初始化', '1', 'redisdb_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(118, 'spark_yaml', 'spark配置', 'spark.yaml', 'spark收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('118', 'spark_yaml', '初始化', '1', 'spark_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(119, 'sqlserver_yaml', 'sqlserver配置', 'sqlserver.yaml', 'sqlserver收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('119', 'sqlserver_yaml', '初始化', '1', 'sqlserver_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(120, 'tomcat_yaml', 'tomcat配置', 'tomcat.yaml', 'tomcat收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('120', 'tomcat_yaml', '初始化', '1', 'tomcat_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(121, 'vsphere_yaml', 'vsphere配置', 'vsphere.yaml', 'vsphere收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('121', 'vsphere_yaml', '初始化', '1', 'vsphere_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(122, 'yarn_yaml', 'yarn配置', 'yarn.yaml', 'yarn收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('122', 'yarn_yaml', '初始化', '1', 'yarn_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(123, 'zk_yaml', 'zk配置', 'zk.yaml', 'zk收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('123', 'zk_yaml', '初始化', '1', 'zk_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(124, 'hbase_master_yaml', 'hbase_master配置', 'hbase_master.yaml', 'hbase_master收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('124', 'hbase_master_yaml', '初始化', '1', 'hbase_master_yaml');
insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(125, 'hbase_regionserver_yaml', 'hbase_regionserver配置', 'hbase_regionserver.yaml', 'hbase_regionserver收集配置', '6');
insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('125', 'hbase_regionserver_yaml', '初始化', '1', 'hbase_regionserver_yaml');


-- filebeat 从 300开始
-- filebeat config type = 7
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(301, 'apache_yml', 'Apache配置', 'apache.yml', 'Apache 收集器配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('301', 'apache_yml', '初始化', '1', 'apache_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('301', 'logtype', 'apache');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(302, 'docker_daemon_yml', 'Docker配置', 'docker_daemon.yml', 'Docker收集器配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('302', 'docker_daemon_yml', '初始化', '1', 'docker_daemon_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('302', 'logtype', 'docker');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(303, 'elastic_yml', 'elasticsearch配置', 'elastic.yml', 'elastic收集器配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('303', 'elastic_yml', '初始化', '1', 'elastic_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('303', 'logtype', 'elastic');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(304, 'hdfs_datanode_yml', 'HadoopDatanode配置', 'hdfs_datanode.yml', 'HadoopDatanode收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('304', 'hdfs_datanode_yml', '初始化', '1', 'hdfs_datanode_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('304', 'logtype', 'datanode');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(305, 'hdfs_namenode_yml', 'HadoopNamenode配置', 'hdfs_namenode.yml', 'HadoopNamenode收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('305', 'hdfs_namenode_yml', '初始化', '1', 'hdfs_namenode_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('305', 'logtype', 'namenode');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(306, 'haproxy_yml', 'Haproxy配置', 'haproxy.yml', 'Haproxy收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('306', 'haproxy_yml', '初始化', '1', 'haproxy_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('306', 'logtype', 'haproxy');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(307, 'host_topn_yml', 'Process配置', 'host_topn.yml', 'Process收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('307', 'host_topn_yml', '初始化', '1', 'host_topn_yml');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(308, 'http_check_yml', 'Http配置', 'http_check.yml', '网站Ping监控', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('308', 'http_check_yml', '初始化', '1', 'http_check_yml');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(309, 'kafka_yml', 'kafka配置', 'kafka.yml', 'kafka收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('309', 'kafka_yml', '初始化', '1', 'kafka_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('309', 'logtype', 'kafka');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(310, 'mapreduce_yml', 'mapreduce配置', 'mapreduce.yml', 'mapreduce收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('310', 'mapreduce_yml', '初始化', '1', 'mapreduce_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('310', 'logtype', 'mapreduce');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(311, 'mongo_yml', 'mongo配置', 'mongo.yml', 'mongo收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('311', 'mongo_yml', '初始化', '1', 'mongo_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('311', 'logtype', 'mongo');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(312, 'mysql_yml', 'mysql配置', 'mysql.yml', 'mysql收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('312', 'mysql_yml', '初始化', '1', 'mysql_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('312', 'logtype', 'mysql');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('312', 'logtype', 'slow-mysql');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(313, 'nginx_yml', 'nginx配置', 'nginx.yml', 'nginx收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('313', 'nginx_yml', '初始化', '1', 'nginx_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('313', 'logtype', 'nginxaccess');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('313', 'logtype', 'nginxerror');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(314, 'oracle_yml', 'oracle配置', 'oracle.yml', 'oracle收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('314', 'oracle_yml', '初始化', '1', 'oracle_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('314', 'logtype', 'oracle');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(315, 'postgresql_yml', 'postgresql配置', 'postgresql.yml', 'postgresql收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('315', 'postgresql_yml', '初始化', '1', 'postgresql_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('315', 'logtype', 'postgresql');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(316, 'rabbitmq_yml', 'rabbitmq配置', 'rabbitmq.yml', 'rabbitmq收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('316', 'rabbitmq_yml', '初始化', '1', 'rabbitmq_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('316', 'logtype', 'rabbitmq');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(317, 'redisdb_yml', 'redisdb配置', 'redisdb.yml', 'redisdb收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('317', 'redisdb_yml', '初始化', '1', 'redisdb_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('317', 'logtype', 'redis');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(318, 'spark_yml', 'spark配置', 'spark.yml', 'spark收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('318', 'spark_yml', '初始化', '1', 'spark_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('318', 'logtype', 'spark');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(319, 'sqlserver_yml', 'sqlserver配置', 'sqlserver.yml', 'sqlserver收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('319', 'sqlserver_yml', '初始化', '1', 'sqlserver_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('319', 'logtype', 'sqlserver');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(320, 'tomcat_yml', 'tomcat配置', 'tomcat.yml', 'tomcat收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('320', 'tomcat_yml', '初始化', '1', 'tomcat_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('320', 'logtype', 'tomcat');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(321, 'vsphere_yml', 'vsphere配置', 'vsphere.yml', 'vsphere收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('321', 'vsphere_yml', '初始化', '1', 'vsphere_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('321', 'logtype', 'vcenter');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(322, 'yarn_yml', 'yarn配置', 'yarn.yml', 'yarn收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('322', 'yarn_yml', '初始化', '1', 'yarn_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('322', 'logtype', 'yarn');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(323, 'zk_yml', 'zk配置', 'zk.yml', 'zk收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('323', 'zk_yml', '初始化', '1', 'zk_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('323', 'logtype', 'zookeeper');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(324, 'hbase_master_yml', 'hbase_master配置', 'hbase_master.yml', 'hbase_master收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('324', 'hbase_master_yml', '初始化', '1', 'hbase_master_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('324', 'logtype', 'hbase.master');
-- insert into `plugin` (`id`, `latest_version`, `alias`, `name`, `description`, `type`) values(325, 'hbase_regionserver_yml', 'hbase_regionserver配置', 'hbase_regionserver.yml', 'hbase_regionserver收集配置', '7');
-- insert into `plugin_history` (`plugin_id`, `data_id`, `comment`, `operator`, `version`) values('325', 'hbase_regionserver_yml', '初始化', '1', 'hbase_regionserver_yml');
-- insert into `plugin_property` (`plugin_id`, `name`, `value`) values('325', 'logtype', 'hbase.regionserver');