-- ------------------------------
-- DATABASE channel_info for `巡检报告数据库`
-- ------------------------------
USE `<:cmdb_database:>`;

-- ------------------------------
-- Add default multiline settings
-- ------------------------------
INSERT INTO `cw_CI` (`orgId`, `sysId`, `key`, `type`, `createdAt`, `deletedAt`) VALUES (0, 0, 'Cloudwiz_Configuration_Log_PP_default', 7, '2017-10-04 11:54:34', NULL);

INSERT INTO `cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`, `type`) values (0, 0, (SELECT id FROM `cw_CI` where `orgId`=0 AND `sysId`=0 AND type=7 AND `key`='Cloudwiz_Configuration_Log_PP_default' limit 1), 'serviceName', 'log-pp',  0);
INSERT INTO `cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`, `type`) values (0, 0, (SELECT id FROM `cw_CI` where `orgId`=0 AND `sysId`=0 AND type=7 AND `key`='Cloudwiz_Configuration_Log_PP_default' limit 1), 'type', 'default',  0);
INSERT INTO `cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`, `type`) values (0, 0, (SELECT id FROM `cw_CI` where `orgId`=0 AND `sysId`=0 AND type=7 AND `key`='Cloudwiz_Configuration_Log_PP_default' limit 1), 'pattern', '^\\s+|^Caused by:.+',  0);
INSERT INTO `cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`, `type`) values (0, 0, (SELECT id FROM `cw_CI` where `orgId`=0 AND `sysId`=0 AND type=7 AND `key`='Cloudwiz_Configuration_Log_PP_default' limit 1), 'negate', 'false',  0);
INSERT INTO `cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`, `type`) values (0, 0, (SELECT id FROM `cw_CI` where `orgId`=0 AND `sysId`=0 AND type=7 AND `key`='Cloudwiz_Configuration_Log_PP_default' limit 1), 'match', 'after',  0);
