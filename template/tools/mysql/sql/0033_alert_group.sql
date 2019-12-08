USE `<:grafana_database:>`;

DROP TABLE IF EXISTS `alert_group`;
CREATE TABLE `alert_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `createAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updateAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `alertdef_group`;
CREATE TABLE `alertdef_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `alert_id` varchar(256) NOT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `createAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updateAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=179 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `alertdef_user`;
CREATE TABLE `alertdef_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `alert_id` varchar(256) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `creatAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `group_user`;
CREATE TABLE `group_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `createAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=198 DEFAULT CHARSET=utf8;
