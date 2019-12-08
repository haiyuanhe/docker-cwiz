USE `<:grafana_database:>`;

DROP TABLE IF EXISTS `vGroup_user`;
CREATE TABLE `vGroup_user` (
	`id` bigint(20) NOT NULL AUTO_INCREMENT,
	`system_id` bigint(20),
	`user_id` bigint(20),
	`num` int(8) COMMENT '序号',
	`createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
	`updateAt` datetime,
	PRIMARY KEY (`id`)
) COMMENT='';
