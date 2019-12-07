INSERT INTO `scheduler` VALUES ('5', null, '5', null, '2019-03-07 10:35:45', '1', '0');
INSERT INTO `scheduler` VALUES ('6', null, '6', null, '2019-03-07 10:35:45', '1', '0');

insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'id', 'id', 'system', null, 'id', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '操作系统', 'os', 'system', null, 'os', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'fqdn', 'fqdn', 'system', null, 'fqdn', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '主机名', 'Host', 'system', null, 'host', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'ipv4', 'ipv4', 'system', null, 'ipv4', 'Array');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'ipv6', 'ipv6', 'system', null, 'ipv6', 'Array');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'uuid', 'uuid', 'system', null, 'uuid', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '内核', 'kernel', 'system', null, 'kernel', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '操作系统型号', 'osarch', 'system', null, 'osarch', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '虚拟机', 'virtual', 'system', null, 'virtual', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '虚拟机', 'virtual', 'system', null, 'virtual', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'fqdn_ip4', 'fqdn_ip4', 'system', null, 'fqdn_ip4', 'Array');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'Cpu型号', 'cpu_model', 'system', null, 'cpu_model', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '用户组', 'groupname', 'system', null, 'groupname', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '内存大小', 'mem_total', 'system', null, 'mem_total', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'OS系列', 'os_family', 'system', null, 'os_family', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', 'OS版本', 'osrelease', 'system', null, 'osrelease', 'String');
insert into `oneagent`.`property_meta` ( `org_id`, `sys_id`, `alias_zh`, `alias_en`, `type`, `default_value`, `name`, `data_type`) values ( '0', '0', '机器id', 'machine_id', 'system', null, 'machine_id', 'String');


insert into `grafana`.`permission` ( `url`, `alias`, `permission`, `id`, `parentId`, `component`, `is_default`, `json`, `name`) values ( null, '调度中心', null, '54', '45', 'setting', '0', '{\"id\": 8,\"text\": \"调度中心\",\"url\": \"/task_management\",\"auth\": 0}', 'task');
insert into `grafana`.`permission` ( `url`, `alias`, `permission`, `id`, `parentId`, `component`, `is_default`, `json`, `name`) values ( null, '插件中心', null, '55', '45', 'setting', '0', '{\"id\": 9,\"text\": \"插件中心\",\"url\": \"/plugin_management\",\"auth\": 0}', 'plugin');