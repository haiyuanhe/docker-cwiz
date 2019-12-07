-- ------------------------------
-- pythond `初始化数据`
-- ------------------------------

USE `<:grafana_database:>`;


SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ad_feedback_confirmed
-- ----------------------------
DROP TABLE IF EXISTS `ad_feedback_confirmed`;
CREATE TABLE `ad_feedback_confirmed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_tags` varchar(255) NOT NULL,
  `feedback_json` text NOT NULL,
  `confirm_dt` datetime NOT NULL,
  `process_flag` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `metric_tags_index` (`metric_tags`) USING BTREE,
  KEY `process_flag_index` (`process_flag`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for ad_feedback_unconfirmed
-- ----------------------------
DROP TABLE IF EXISTS `ad_feedback_unconfirmed`;
CREATE TABLE `ad_feedback_unconfirmed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_tags` varchar(255) NOT NULL,
  `feedback_json` text NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `metric_tags_unique` (`metric_tags`),
  KEY `metric_tags_index` (`metric_tags`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for anom_hyper_param
-- ----------------------------
DROP TABLE IF EXISTS `anom_hyper_param`;
CREATE TABLE `anom_hyper_param` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_tags` varchar(255) NOT NULL,
  `period_minutes` int(11) DEFAULT NULL,
  `params_json` text,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `metric_tags` (`metric_tags`),
  KEY `metric_tags_index` (`metric_tags`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;

