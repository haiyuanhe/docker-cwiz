-- ------------------------------
-- DATABASE channel_info for `巡检报告数据库`
-- ------------------------------
CREATE DATABASE `<:report_database:>`;

USE `<:report_database:>`;

-- ------------------------------
-- Table channel_info for `死锁信息表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_deadlock(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  pid INT NOT NULL DEFAULT '-1' COMMENT '产生死锁请求的PID',
  d_sql LONGTEXT COMMENT '产生死锁的执行语句',
  d_relation_sql LONGTEXT  COMMENT '死锁的关联语句',
  exec_time VARCHAR(100) DEFAULT '-1' COMMENT '产生死锁的时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '死锁信息表';

-- ------------------------------
-- Table channel_info for `慢查询语句表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_slow_query_statement(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  s_sql LONGTEXT  COMMENT '产生慢查询的执行语句',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '慢查询语句表';


-- ------------------------------
-- Table channel_info for `慢查询统计信息表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_slow_query_statis(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  statement_id BIGINT(20) NOT NULL DEFAULT '-1' COMMENT '慢查询语句ID',
  compile_time VARCHAR(100) COMMENT 'sql编译时间',
  last_execution_time VARCHAR(100)  COMMENT 'sql最后一次执行时间',
  report_date VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'sql最后一次执行时间',
  execution_counts INT DEFAULT NULL DEFAULT '0' COMMENT '当前执行次数',
  total_time INT DEFAULT NULL DEFAULT '0' COMMENT '当前总花费时间（s）',
  average_time INT DEFAULT NULL DEFAULT '0' COMMENT '当前平均花费时间（s）',
  report_execution_counts INT DEFAULT NULL DEFAULT '0' COMMENT '当日统计执行次数',
  report_total_time INT DEFAULT NULL DEFAULT '0' COMMENT '当日统计总花费时间（s）',
  report_average_time INT DEFAULT NULL DEFAULT '0' COMMENT '当日统计平均花费时间（s）',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '慢查询统计信息表';

-- ------------------------------
-- Table channel_info for `无用索引信息表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_useless_indexs(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  db_name VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT '无用索引对应的数据库名',
  table_name VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT '无用索引对应的表名',
  index_name VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT '无用索引对应的索引名',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '无用索引信息表';


-- ------------------------------
-- Table channel_info for `索引缺失信息表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_lack_indexs(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  db_name VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT '索引缺失对应的数据库名',
  table_name VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT '索引缺失对应的表名',
  column_name VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT '索引缺失对应的列名称',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '索引缺失信息表';

-- ------------------------------
-- Table channel_info for `最新指标值信息表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_metrics(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  batch_requests VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒批处理请求数',
  sql_compilations VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒SQL编译数',
  lock_waits VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒等待的锁请求数',
  procs_blocked VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒被阻塞进程数',
  cache_hit_ratio VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '缓存命中率',
  page_life_expectancy VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '页平均寿命',
  checkpoint_pages VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒检查点或刷新到磁盘的页数',
  page_splits VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒页拆分数',
  sql_recompilations VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '每秒SQL重编译数',
  connections VARCHAR(20) NOT NULL DEFAULT '-1' COMMENT '用户连接数',
  last_exec_time VARCHAR(50) NOT NULL DEFAULT '-1' COMMENT '获取指标时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '最新指标值信息表';

-- ------------------------------
-- Table channel_info for `查询响应时间表`
-- ------------------------------
CREATE TABLE IF NOT EXISTS sqlserver_query_response(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  host VARCHAR(100) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的host',
  instance VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT 'SqlServer服务器的实例名称',
  total_counts VARCHAR(200) NOT NULL DEFAULT '-1' COMMENT '查询总次数',
  total_time VARCHAR(500) NOT NULL DEFAULT '-1' COMMENT '查询总时间（毫秒）',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT '查询响应时间表';

CREATE TABLE IF NOT EXISTS `mysql_slowlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) DEFAULT NULL,
  `port` varchar(255) DEFAULT NULL,
  `user_host` varchar(255) DEFAULT NULL,
  `query_time` time DEFAULT NULL,
  `lock_time` time DEFAULT NULL,
  `sql_text` blob,
  `start_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `time_index` (`start_time`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `mysql_index` (
  `ip` varchar(255) NOT NULL,
  `port` varchar(255) NOT NULL,
  `type` enum('index_miss','index_duplicate','index_unused') NOT NULL,
  `detail` text,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`ip`,`port`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
