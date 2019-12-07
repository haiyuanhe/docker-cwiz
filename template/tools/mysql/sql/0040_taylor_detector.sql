USE `<:grafana_database:>`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
-- ----------------------------
-- Table structure for taylor_detector
-- ----------------------------
DROP TABLE IF EXISTS `taylor_detector`;
CREATE TABLE `taylor_detector` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_tags` varchar(255) NOT NULL,
  `prev_avail_param_json` text,
  `prev_avail_pred_summary_json` text,
  `latest_avail_param_json` text NOT NULL,
  `latest_avail_pred_summary_json` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `metric_tags` (`metric_tags`),
  KEY `metric_tags_index` (`metric_tags`)
) ENGINE=InnoDB AUTO_INCREMENT=871 DEFAULT CHARSET=utf8;
SET FOREIGN_KEY_CHECKS = 1;
