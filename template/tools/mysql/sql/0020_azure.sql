USE `<:cmdb_database:>`;

ALTER TABLE cw_CI CHANGE `key` `key` VARCHAR(254) CHARACTER SET utf8 COLLATE utf8_general_ci;

ALTER TABLE cw_History_CI CHANGE `key` `key` VARCHAR(254) CHARACTER SET utf8 COLLATE utf8_general_ci;

--
-- Azure integration
--

-- 1. Meta type
INSERT INTO cw_Meta_Type (`id`, `name`, `properties`) VALUES (1000, 'AzureResourceGroup', '');
INSERT INTO cw_Meta_Type (`id`, `name`, `properties`) VALUES (1001, 'AzureResource', '');

-- 2. Service Types
INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Network/trafficmanagerprofiles', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.traffic.manager', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Network/applicationGateways', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.application.gateway', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Web/sites', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.web.application', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Web/serverFarms', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.server.farm', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Sql/servers', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.sqlserver', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Sql/servers/databases', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.sqlserver.database', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Cache/Redis', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.redis.cache', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Storage/storageAccounts', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.storage', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.ServiceBus/namespaces', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.service.bus', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Scheduler/jobCollections', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.scheduler.jobcollections', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.Scheduler/jobCollections/jobs', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.scheduler.jobs', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);

INSERT INTO `cw_CI` (orgId, sysId, `key`, type) VALUES (0, 0, 'Microsoft.DBforMySQL/servers', 5);
select @id := LAST_INSERT_ID();
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'name', 'azure.mysqlserver', 0);
INSERT INTO `cw_Attribute` (orgId, sysId, ciId, name, value, type) VALUES (0, 0, @id, 'platform', 'azure', 0);
