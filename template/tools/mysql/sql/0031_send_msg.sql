USE `<:cmdb_database:>`;

# delete existing settings
set @id := 0;
select @id := id from cw_CI where `key` = 'sendMessage_config' and orgId = 0 and sysId = 0 and deletedAt = '2000-01-01';

set @now = now();
update cw_Attribute set deletedAt = @now where @id != 0 and ciId = @id;
update cw_CI set deletedAt = @now where @id != 0 and id = @id;

# create new settings
insert into `CloudwizCMDB`.`cw_CI` (`orgId`, `sysId`, `key`, `type`) values ('0', '0', 'sendMessage_config', '7');
SELECT @id := last_insert_id();

insert into `CloudwizCMDB`.`cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`) values
('0', '0', @id, 'sslEnabled', 'false'),
('0', '0', @id, 'smtpHost', 'smtp.exmail.qq.com'),
('0', '0', @id, 'smtpPort', '25'),
('0', '0', @id, 'emailAccount', 'aiops1@cloudwiz.cn'),
('0', '0', @id, 'emailPassword', 'Cwiz_1234'),
('0', '0', @id, 'smsPlatform', 'tencent'),
('0', '0', @id, 'tencentAppId', '1400030979'),
('0', '0', @id, 'tencentAppKey', '901b7bb29eb46cfd1ef3b2376a124c07'),
('0', '0', @id, 'tencentTemplateId', '19397'),
('0', '0', @id, 'tencentCloseTemplateId', '421231'),
('0', '0', @id, 'azureTemplateId', null),
('0', '0', @id, 'azureAccount', null),
('0', '0', @id, 'azureKey', null),
('0', '0', @id, 'token', 'cloudwiz_test'),
('0', '0', @id, 'wxAppId', '12342'),
('0', '0', @id, 'wxAppSecret', '1abccc3c9f80eec9fa6c291acaa0365c'),
('0', '0', @id, 'wxTemplateId', '823410');


# delete existing settings
set @id := 0;
select @id := id from cw_CI where `key` = 'switchConfig' and orgId = 0 and sysId = 0 and deletedAt = '2000-01-01';

set @now = now();
update cw_Attribute set deletedAt = @now where @id != 0 and ciId = @id;
update cw_CI set deletedAt = @now where @id != 0 and id = @id;

# create new settings
insert into `CloudwizCMDB`.`cw_CI` (`orgId`, `sysId`, `key`, `type`) values ('0', '0', 'switchConfig', '7');
SELECT @id := last_insert_id();

insert into `CloudwizCMDB`.`cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`) values
('0', '0', @id, 'tcEnable', 'false');


# delete existing settings
set @id := 0;
select @id := id from cw_CI where `key` = 'svConfig' and orgId = 0 and sysId = 0 and deletedAt = '2000-01-01';

set @now = now();
update cw_Attribute set deletedAt = @now where @id != 0 and ciId = @id;
update cw_CI set deletedAt = @now where @id != 0 and id = @id;

# create new settings
insert into `CloudwizCMDB`.`cw_CI` (`orgId`, `sysId`, `key`, `type`) values ('0', '0', 'svConfig', '7');
SELECT @id := last_insert_id();

insert into `CloudwizCMDB`.`cw_Attribute` (`orgId`, `sysId`, `ciId`, `name`, `value`) values
('0', '0', @id, 'tencentAppId', '1400030979'),
('0', '0', @id, 'tencentAppKey', '901b7bb29eb46cfd1ef3b2376a124c07'),
('0', '0', @id, 'tencentTemplateId', '421186'),
('0', '0', @id, 'tencentCloseTemplateId', '421213'),
('0', '0', @id, 'platformType', 'tencent');
