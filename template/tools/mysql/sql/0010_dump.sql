-- MySQL dump 10.13  Distrib 5.6.38, for linux-glibc2.12 (x86_64)
--
-- Host: 172.16.16.104    Database: grafana
-- ------------------------------------------------------
-- Server version	5.6.38

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `grafana`
--

/*!40000 DROP DATABASE IF EXISTS `<:grafana_database:>`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `<:grafana_database:>` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `<:grafana_database:>`;

--
-- Table structure for table `SPRING_SESSION`
--

DROP TABLE IF EXISTS `SPRING_SESSION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SPRING_SESSION` (
  `PRIMARY_ID` char(36) COLLATE utf8_bin NOT NULL,
  `SESSION_ID` char(36) COLLATE utf8_bin NOT NULL,
  `CREATION_TIME` bigint(20) NOT NULL,
  `LAST_ACCESS_TIME` bigint(20) NOT NULL,
  `MAX_INACTIVE_INTERVAL` int(11) NOT NULL,
  `EXPIRY_TIME` bigint(20) NOT NULL,
  `PRINCIPAL_NAME` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`PRIMARY_ID`),
  UNIQUE KEY `SPRING_SESSION_IX1` (`SESSION_ID`),
  KEY `SPRING_SESSION_IX2` (`EXPIRY_TIME`),
  KEY `SPRING_SESSION_IX3` (`PRINCIPAL_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SPRING_SESSION`
--

LOCK TABLES `SPRING_SESSION` WRITE;
/*!40000 ALTER TABLE `SPRING_SESSION` DISABLE KEYS */;
/*!40000 ALTER TABLE `SPRING_SESSION` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SPRING_SESSION_ATTRIBUTES`
--

DROP TABLE IF EXISTS `SPRING_SESSION_ATTRIBUTES`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SPRING_SESSION_ATTRIBUTES` (
  `SESSION_PRIMARY_ID` char(36) COLLATE utf8_bin NOT NULL,
  `ATTRIBUTE_NAME` varchar(200) COLLATE utf8_bin NOT NULL,
  `ATTRIBUTE_BYTES` blob NOT NULL,
  PRIMARY KEY (`SESSION_PRIMARY_ID`,`ATTRIBUTE_NAME`),
  CONSTRAINT `SPRING_SESSION_ATTRIBUTES_FK` FOREIGN KEY (`SESSION_PRIMARY_ID`) REFERENCES `SPRING_SESSION` (`PRIMARY_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SPRING_SESSION_ATTRIBUTES`
--

LOCK TABLES `SPRING_SESSION_ATTRIBUTES` WRITE;
/*!40000 ALTER TABLE `SPRING_SESSION_ATTRIBUTES` DISABLE KEYS */;
/*!40000 ALTER TABLE `SPRING_SESSION_ATTRIBUTES` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_key`
--

DROP TABLE IF EXISTS `api_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_key` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `key` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `deleted` int(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_api_key_key` (`key`),
  UNIQUE KEY `UQE_api_key_org_id_name` (`org_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_key`
--

LOCK TABLES `api_key` WRITE;
/*!40000 ALTER TABLE `api_key` DISABLE KEYS */;
INSERT INTO `api_key` VALUES (1,1,'1','<:token:>','Admin','2017-11-05 22:23:14','2017-11-05 22:23:14',0);
/*!40000 ALTER TABLE `api_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cwiz_static`
--

DROP TABLE IF EXISTS `cwiz_static`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cwiz_static` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `json_data` mediumtext NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dashboard`
--

DROP TABLE IF EXISTS `dashboard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `data` mediumtext,
  `org_id` bigint(20) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_dashboard_org_id` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard`
--

LOCK TABLES `dashboard` WRITE;
/*!40000 ALTER TABLE `dashboard` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_snapshot`
--

DROP TABLE IF EXISTS `dashboard_snapshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_snapshot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `key` varchar(255) NOT NULL,
  `delete_key` varchar(255) NOT NULL,
  `org_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `external` tinyint(1) NOT NULL,
  `external_url` varchar(255) NOT NULL,
  `dashboard` mediumtext,
  `expires` datetime NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_dashboard_snapshot_key` (`key`),
  UNIQUE KEY `UQE_dashboard_snapshot_delete_key` (`delete_key`),
  KEY `IDX_dashboard_snapshot_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_snapshot`
--

LOCK TABLES `dashboard_snapshot` WRITE;
/*!40000 ALTER TABLE `dashboard_snapshot` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_snapshot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_tag`
--

DROP TABLE IF EXISTS `dashboard_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dashboard_id` bigint(20) NOT NULL,
  `term` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_tag`
--

LOCK TABLES `dashboard_tag` WRITE;
/*!40000 ALTER TABLE `dashboard_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_source`
--

DROP TABLE IF EXISTS `data_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_source` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `version` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `access` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `intranet_url` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `database` varchar(255) DEFAULT NULL,
  `basic_auth` tinyint(1) NOT NULL,
  `basic_auth_user` varchar(255) DEFAULT NULL,
  `basic_auth_password` varchar(255) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL,
  `json_data` text,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `with_credentials` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_data_source_org_id_name` (`org_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_source`
--

LOCK TABLES `data_source` WRITE;
/*!40000 ALTER TABLE `data_source` DISABLE KEYS */;
INSERT INTO `data_source` VALUES (1,1,0,'customdb','download','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:<:nginx_ext_port:>','<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>',NULL,NULL,NULL,0,NULL,'',0,NULL,'2018-12-03 16:42:39','2018-12-03 16:42:39',0),(2,1,0,'alertd','alertd','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:<:nginx_ext_port:>/<:nginx_prefix:>_alertd','<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_alertd',NULL,NULL,NULL,0,NULL,'',0,NULL,'2018-12-03 16:42:39','2018-12-03 16:42:39',0),(3,1,0,'opentsdb','opentsdb','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:<:nginx_ext_port:>/<:nginx_prefix:>_tsdb','<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_tsdb',NULL,NULL,NULL,0,NULL,'',1,'{\"tsdbResolution\":1,\"tsdbVersion\":2}','2018-12-03 16:42:39','2018-12-03 16:42:39',0),(4,1,0,'elasticsearch','elk','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:<:nginx_ext_port:>/<:nginx_prefix:>_log','<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_log',NULL,NULL,'[$_token-logstash-]YYYY.MM.DD',0,NULL,'',0,'{\"interval\":\"Daily\",\"timeField\":\"@timestamp\"}','2018-12-03 16:42:39','2018-12-03 16:42:39',0),(5,1,0,'prometheus','prometheus','direct','','',NULL,NULL,NULL,0,NULL,NULL,0,'{\"httpMethod\":\"GET\"}','2018-10-16 10:12:00','2018-10-16 10:12:00',0),(23,1,0,'customdb','oneagent','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:8888','<:nginx_protocol:>://<:nginx_ip:>:8888','','','',0,'','',0,'{\"tsdbResolution\":1,\"tsdbVersion\":1}','2019-08-21 13:44:44','2019-08-21 13:44:44',0),(24,1,0,'customdb','pythond','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:8100','<:nginx_protocol:>://<:nginx_ip:>:8100','','','',0,'','',0,'{\"tsdbResolution\":1,\"tsdbVersion\":1}','2019-09-10 10:46:13','2019-09-10 17:59:09',0),(25,1,0,'customdb','permission','direct','<:nginx_ext_protocol:>://<:nginx_ext_ip:>:4123','<:nginx_protocol:>://<:nginx_ip:>:4123',NULL,NULL,NULL,0,NULL,'',0,NULL,'2018-12-03 16:42:39','2018-12-03 16:42:39',0);
/*!40000 ALTER TABLE `data_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migration_log`
--

DROP TABLE IF EXISTS `migration_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migration_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `migration_id` varchar(255) NOT NULL,
  `sql` text NOT NULL,
  `success` tinyint(1) NOT NULL,
  `error` text NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migration_log`
--

LOCK TABLES `migration_log` WRITE;
/*!40000 ALTER TABLE `migration_log` DISABLE KEYS */;
INSERT INTO `migration_log` VALUES (1,'create migration_log table','CREATE TABLE IF NOT EXISTS `migration_log` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `migration_id` VARCHAR(255) NOT NULL\n, `sql` TEXT NOT NULL\n, `success` TINYINT(1) NOT NULL\n, `error` TEXT NOT NULL\n, `timestamp` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:11'),(2,'create user table','CREATE TABLE IF NOT EXISTS `user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `version` INT NOT NULL\n, `login` VARCHAR(255) NOT NULL\n, `email` VARCHAR(255) NOT NULL\n, `name` VARCHAR(255) NULL\n, `password` VARCHAR(255) NULL\n, `salt` VARCHAR(50) NULL\n, `rands` VARCHAR(50) NULL\n, `company` VARCHAR(255) NULL\n, `account_id` BIGINT(20) NOT NULL\n, `is_admin` TINYINT(1) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:11'),(3,'add unique index user.login','CREATE UNIQUE INDEX `UQE_user_login` ON `user` (`login`);',1,'','2017-11-05 22:23:11'),(4,'add unique index user.email','CREATE UNIQUE INDEX `UQE_user_email` ON `user` (`email`);',1,'','2017-11-05 22:23:11'),(5,'drop index UQE_user_login - v1','DROP INDEX `UQE_user_login` ON `user`',1,'','2017-11-05 22:23:11'),(6,'drop index UQE_user_email - v1','DROP INDEX `UQE_user_email` ON `user`',1,'','2017-11-05 22:23:12'),(7,'Rename table user to user_v1 - v1','ALTER TABLE `user` RENAME TO `user_v1`',1,'','2017-11-05 22:23:12'),(8,'create user table v2','CREATE TABLE IF NOT EXISTS `user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `version` INT NOT NULL\n, `login` VARCHAR(255) NOT NULL\n, `email` VARCHAR(255) NOT NULL\n, `name` VARCHAR(255) NULL\n, `password` VARCHAR(255) NULL\n, `salt` VARCHAR(50) NULL\n, `rands` VARCHAR(50) NULL\n, `company` VARCHAR(255) NULL\n, `org_id` BIGINT(20) NOT NULL\n, `is_admin` TINYINT(1) NOT NULL\n, `email_verified` TINYINT(1) NULL\n, `theme` VARCHAR(255) NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(9,'create index UQE_user_login - v2','CREATE UNIQUE INDEX `UQE_user_login` ON `user` (`login`);',1,'','2017-11-05 22:23:12'),(10,'create index UQE_user_email - v2','CREATE UNIQUE INDEX `UQE_user_email` ON `user` (`email`);',1,'','2017-11-05 22:23:12'),(11,'copy data_source v1 to v2','INSERT INTO `user` (`version`\n, `email`\n, `name`\n, `company`\n, `org_id`\n, `is_admin`\n, `created`\n, `id`\n, `updated`\n, `password`\n, `salt`\n, `rands`\n, `login`) SELECT `version`\n, `email`\n, `name`\n, `company`\n, `account_id`\n, `is_admin`\n, `created`\n, `id`\n, `updated`\n, `password`\n, `salt`\n, `rands`\n, `login` FROM `user_v1`',1,'','2017-11-05 22:23:12'),(12,'Drop old table user_v1','DROP TABLE IF EXISTS `user_v1`',1,'','2017-11-05 22:23:12'),(13,'create temp user table v1-7','CREATE TABLE IF NOT EXISTS `temp_user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `version` INT NOT NULL\n, `email` VARCHAR(255) NOT NULL\n, `name` VARCHAR(255) NULL\n, `role` VARCHAR(20) NULL\n, `code` VARCHAR(255) NOT NULL\n, `status` VARCHAR(20) NOT NULL\n, `invited_by_user_id` BIGINT(20) NULL\n, `email_sent` TINYINT(1) NOT NULL\n, `email_sent_on` DATETIME NULL\n, `remote_addr` VARCHAR(255) NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(14,'create propose user table ','CREATE TABLE IF NOT EXISTS `propose_user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `email` VARCHAR(255) NULL\n, `name` VARCHAR(255) NULL\n, `phone` VARCHAR(20) NULL\n, `org` VARCHAR(255) NULL\n, `scale` VARCHAR(20) NULL\n, `status` VARCHAR(255) NOT NULL\n, `created` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(15,'create index IDX_temp_user_email - v1-7','CREATE INDEX `IDX_temp_user_email` ON `temp_user` (`email`);',1,'','2017-11-05 22:23:12'),(16,'create index IDX_temp_user_org_id - v1-7','CREATE INDEX `IDX_temp_user_org_id` ON `temp_user` (`org_id`);',1,'','2017-11-05 22:23:12'),(17,'create index IDX_temp_user_code - v1-7','CREATE INDEX `IDX_temp_user_code` ON `temp_user` (`code`);',1,'','2017-11-05 22:23:12'),(18,'create index IDX_temp_user_status - v1-7','CREATE INDEX `IDX_temp_user_status` ON `temp_user` (`status`);',1,'','2017-11-05 22:23:12'),(19,'create star table','CREATE TABLE IF NOT EXISTS `star` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `user_id` BIGINT(20) NOT NULL\n, `dashboard_id` BIGINT(20) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(20,'add unique index star.user_id_dashboard_id','CREATE UNIQUE INDEX `UQE_star_user_id_dashboard_id` ON `star` (`user_id`,`dashboard_id`);',1,'','2017-11-05 22:23:12'),(21,'create org table v1','CREATE TABLE IF NOT EXISTS `org` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `version` INT NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `address1` VARCHAR(255) NULL\n, `address2` VARCHAR(255) NULL\n, `city` VARCHAR(255) NULL\n, `state` VARCHAR(255) NULL\n, `zip_code` VARCHAR(50) NULL\n, `country` VARCHAR(255) NULL\n, `billing_email` VARCHAR(255) NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(22,'create index UQE_org_name - v1','CREATE UNIQUE INDEX `UQE_org_name` ON `org` (`name`);',1,'','2017-11-05 22:23:12'),(23,'create org_user table v1','CREATE TABLE IF NOT EXISTS `org_user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `user_id` BIGINT(20) NOT NULL\n, `role` VARCHAR(20) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(24,'create index IDX_org_user_org_id - v1','CREATE INDEX `IDX_org_user_org_id` ON `org_user` (`org_id`);',1,'','2017-11-05 22:23:12'),(25,'create index UQE_org_user_org_id_user_id - v1','CREATE UNIQUE INDEX `UQE_org_user_org_id_user_id` ON `org_user` (`org_id`,`user_id`);',1,'','2017-11-05 22:23:12'),(26,'copy data account to org','INSERT INTO `org` (`updated`\n, `id`\n, `version`\n, `name`\n, `created`) SELECT `updated`\n, `id`\n, `version`\n, `name`\n, `created` FROM `account`',1,'','2017-11-05 22:23:12'),(27,'copy data account_user to org_user','INSERT INTO `org_user` (`id`\n, `org_id`\n, `user_id`\n, `role`\n, `created`\n, `updated`) SELECT `id`\n, `account_id`\n, `user_id`\n, `role`\n, `created`\n, `updated` FROM `account_user`',1,'','2017-11-05 22:23:12'),(28,'Drop old table account','DROP TABLE IF EXISTS `account`',1,'','2017-11-05 22:23:12'),(29,'Drop old table account_user','DROP TABLE IF EXISTS `account_user`',1,'','2017-11-05 22:23:12'),(30,'create dashboard table','CREATE TABLE IF NOT EXISTS `dashboard` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `version` INT NOT NULL\n, `slug` VARCHAR(255) NOT NULL\n, `title` VARCHAR(255) NOT NULL\n, `data` TEXT NOT NULL\n, `account_id` BIGINT(20) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(31,'add index dashboard.account_id','CREATE INDEX `IDX_dashboard_account_id` ON `dashboard` (`account_id`);',1,'','2017-11-05 22:23:12'),(32,'add unique index dashboard_account_id_slug','CREATE UNIQUE INDEX `UQE_dashboard_account_id_slug` ON `dashboard` (`account_id`,`slug`);',1,'','2017-11-05 22:23:12'),(33,'create dashboard_tag table','CREATE TABLE IF NOT EXISTS `dashboard_tag` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `dashboard_id` BIGINT(20) NOT NULL\n, `term` VARCHAR(50) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(34,'add unique index dashboard_tag.dasboard_id_term','CREATE UNIQUE INDEX `UQE_dashboard_tag_dashboard_id_term` ON `dashboard_tag` (`dashboard_id`,`term`);',1,'','2017-11-05 22:23:12'),(35,'drop index UQE_dashboard_tag_dashboard_id_term - v1','DROP INDEX `UQE_dashboard_tag_dashboard_id_term` ON `dashboard_tag`',1,'','2017-11-05 22:23:12'),(36,'Rename table dashboard to dashboard_v1 - v1','ALTER TABLE `dashboard` RENAME TO `dashboard_v1`',1,'','2017-11-05 22:23:12'),(37,'create dashboard v2','CREATE TABLE IF NOT EXISTS `dashboard` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `version` INT NOT NULL\n, `slug` VARCHAR(255) NOT NULL\n, `title` VARCHAR(255) NOT NULL\n, `data` TEXT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:12'),(38,'create index IDX_dashboard_org_id - v2','CREATE INDEX `IDX_dashboard_org_id` ON `dashboard` (`org_id`);',1,'','2017-11-05 22:23:12'),(39,'copy dashboard v1 to v2','INSERT INTO `dashboard` (`id`\n, `version`\n, `slug`\n, `title`\n, `data`\n, `org_id`\n, `created`\n, `updated`) SELECT `id`\n, `version`\n, `slug`\n, `title`\n, `data`\n, `account_id`\n, `created`\n, `updated` FROM `dashboard_v1`',1,'','2017-11-05 22:23:12'),(40,'drop table dashboard_v1','DROP TABLE IF EXISTS `dashboard_v1`',1,'','2017-11-05 22:23:12'),(41,'alter dashboard.data to mediumtext v1','ALTER TABLE dashboard MODIFY data MEDIUMTEXT;',1,'','2017-11-05 22:23:12'),(42,'Add column updated_by in dashboard - v2','alter table `dashboard` ADD COLUMN `updated_by` INT NULL ',1,'','2017-11-05 22:23:13'),(43,'Add column created_by in dashboard - v2','alter table `dashboard` ADD COLUMN `created_by` INT NULL ',1,'','2017-11-05 22:23:13'),(44,'create data_source table','CREATE TABLE IF NOT EXISTS `data_source` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `account_id` BIGINT(20) NOT NULL\n, `version` INT NOT NULL\n, `type` VARCHAR(255) NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `access` VARCHAR(255) NOT NULL\n, `url` VARCHAR(255) NOT NULL\n, `password` VARCHAR(255) NULL\n, `user` VARCHAR(255) NULL\n, `database` VARCHAR(255) NULL\n, `basic_auth` TINYINT(1) NOT NULL\n, `basic_auth_user` VARCHAR(255) NULL\n, `basic_auth_password` VARCHAR(255) NULL\n, `is_default` TINYINT(1) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(45,'add index data_source.account_id','CREATE INDEX `IDX_data_source_account_id` ON `data_source` (`account_id`);',1,'','2017-11-05 22:23:13'),(46,'add unique index data_source.account_id_name','CREATE UNIQUE INDEX `UQE_data_source_account_id_name` ON `data_source` (`account_id`,`name`);',1,'','2017-11-05 22:23:13'),(47,'drop index IDX_data_source_account_id - v1','DROP INDEX `IDX_data_source_account_id` ON `data_source`',1,'','2017-11-05 22:23:13'),(48,'drop index UQE_data_source_account_id_name - v1','DROP INDEX `UQE_data_source_account_id_name` ON `data_source`',1,'','2017-11-05 22:23:13'),(49,'Rename table data_source to data_source_v1 - v1','ALTER TABLE `data_source` RENAME TO `data_source_v1`',1,'','2017-11-05 22:23:13'),(50,'create data_source table v2','CREATE TABLE IF NOT EXISTS `data_source` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `version` INT NOT NULL\n, `type` VARCHAR(255) NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `access` VARCHAR(255) NOT NULL\n, `url` VARCHAR(255) NOT NULL\n, `password` VARCHAR(255) NULL\n, `user` VARCHAR(255) NULL\n, `database` VARCHAR(255) NULL\n, `basic_auth` TINYINT(1) NOT NULL\n, `basic_auth_user` VARCHAR(255) NULL\n, `basic_auth_password` VARCHAR(255) NULL\n, `is_default` TINYINT(1) NOT NULL\n, `json_data` TEXT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(51,'create index IDX_data_source_org_id - v2','CREATE INDEX `IDX_data_source_org_id` ON `data_source` (`org_id`);',1,'','2017-11-05 22:23:13'),(52,'create index UQE_data_source_org_id_name - v2','CREATE UNIQUE INDEX `UQE_data_source_org_id_name` ON `data_source` (`org_id`,`name`);',1,'','2017-11-05 22:23:13'),(53,'copy data_source v1 to v2','INSERT INTO `data_source` (`access`\n, `database`\n, `updated`\n, `id`\n, `basic_auth`\n, `created`\n, `url`\n, `user`\n, `basic_auth_password`\n, `is_default`\n, `org_id`\n, `type`\n, `name`\n, `version`\n, `password`\n, `basic_auth_user`) SELECT `access`\n, `database`\n, `updated`\n, `id`\n, `basic_auth`\n, `created`\n, `url`\n, `user`\n, `basic_auth_password`\n, `is_default`\n, `account_id`\n, `type`\n, `name`\n, `version`\n, `password`\n, `basic_auth_user` FROM `data_source_v1`',1,'','2017-11-05 22:23:13'),(54,'Drop old table data_source_v1 #2','DROP TABLE IF EXISTS `data_source_v1`',1,'','2017-11-05 22:23:13'),(55,'Add column with_credentials','alter table `data_source` ADD COLUMN `with_credentials` TINYINT(1) NOT NULL DEFAULT 0 ',1,'','2017-11-05 22:23:13'),(56,'create api_key table','CREATE TABLE IF NOT EXISTS `api_key` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `account_id` BIGINT(20) NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `key` VARCHAR(64) NOT NULL\n, `role` VARCHAR(255) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n, `deleted` INT(1) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(57,'add index api_key.account_id','CREATE INDEX `IDX_api_key_account_id` ON `api_key` (`account_id`);',1,'','2017-11-05 22:23:13'),(58,'add index api_key.key','CREATE UNIQUE INDEX `UQE_api_key_key` ON `api_key` (`key`);',1,'','2017-11-05 22:23:13'),(59,'add index api_key.account_id_name','CREATE UNIQUE INDEX `UQE_api_key_account_id_name` ON `api_key` (`account_id`,`name`);',1,'','2017-11-05 22:23:13'),(60,'drop index IDX_api_key_account_id - v1','DROP INDEX `IDX_api_key_account_id` ON `api_key`',1,'','2017-11-05 22:23:13'),(61,'drop index UQE_api_key_key - v1','DROP INDEX `UQE_api_key_key` ON `api_key`',1,'','2017-11-05 22:23:13'),(62,'drop index UQE_api_key_account_id_name - v1','DROP INDEX `UQE_api_key_account_id_name` ON `api_key`',1,'','2017-11-05 22:23:13'),(63,'Rename table api_key to api_key_v1 - v1','ALTER TABLE `api_key` RENAME TO `api_key_v1`',1,'','2017-11-05 22:23:13'),(64,'create api_key table v2','CREATE TABLE IF NOT EXISTS `api_key` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `key` VARCHAR(255) NOT NULL\n, `role` VARCHAR(255) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n, `deleted` INT(1) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(65,'create index IDX_api_key_org_id - v2','CREATE INDEX `IDX_api_key_org_id` ON `api_key` (`org_id`);',1,'','2017-11-05 22:23:13'),(66,'create index UQE_api_key_key - v2','CREATE UNIQUE INDEX `UQE_api_key_key` ON `api_key` (`key`);',1,'','2017-11-05 22:23:13'),(67,'create index UQE_api_key_org_id_name - v2','CREATE UNIQUE INDEX `UQE_api_key_org_id_name` ON `api_key` (`org_id`,`name`);',1,'','2017-11-05 22:23:13'),(68,'copy api_key v1 to v2','INSERT INTO `api_key` (`role`\n, `created`\n, `updated`\n, `deleted`\n, `id`\n, `org_id`\n, `name`\n, `key`) SELECT `role`\n, `created`\n, `updated`\n, `deleted`\n, `id`\n, `account_id`\n, `name`\n, `key` FROM `api_key_v1`',1,'','2017-11-05 22:23:13'),(69,'Drop old table api_key_v1','DROP TABLE IF EXISTS `api_key_v1`',1,'','2017-11-05 22:23:13'),(70,'create dashboard_snapshot table v4','CREATE TABLE IF NOT EXISTS `dashboard_snapshot` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `key` VARCHAR(255) NOT NULL\n, `dashboard` TEXT NOT NULL\n, `expires` DATETIME NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(71,'drop table dashboard_snapshot_v4 #1','DROP TABLE IF EXISTS `dashboard_snapshot`',1,'','2017-11-05 22:23:13'),(72,'create dashboard_snapshot table v5 #2','CREATE TABLE IF NOT EXISTS `dashboard_snapshot` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `key` VARCHAR(255) NOT NULL\n, `delete_key` VARCHAR(255) NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `user_id` BIGINT(20) NOT NULL\n, `external` TINYINT(1) NOT NULL\n, `external_url` VARCHAR(255) NOT NULL\n, `dashboard` TEXT NOT NULL\n, `expires` DATETIME NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:13'),(73,'create index UQE_dashboard_snapshot_key - v5','CREATE UNIQUE INDEX `UQE_dashboard_snapshot_key` ON `dashboard_snapshot` (`key`);',1,'','2017-11-05 22:23:13'),(74,'create index UQE_dashboard_snapshot_delete_key - v5','CREATE UNIQUE INDEX `UQE_dashboard_snapshot_delete_key` ON `dashboard_snapshot` (`delete_key`);',1,'','2017-11-05 22:23:13'),(75,'create index IDX_dashboard_snapshot_user_id - v5','CREATE INDEX `IDX_dashboard_snapshot_user_id` ON `dashboard_snapshot` (`user_id`);',1,'','2017-11-05 22:23:13'),(76,'alter dashboard_snapshot to mediumtext v2','ALTER TABLE dashboard_snapshot MODIFY dashboard MEDIUMTEXT;',1,'','2017-11-05 22:23:13'),(77,'create quota table v1','CREATE TABLE IF NOT EXISTS `quota` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NULL\n, `user_id` BIGINT(20) NULL\n, `target` VARCHAR(255) NOT NULL\n, `limit` BIGINT(20) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(78,'create index UQE_quota_org_id_user_id_target - v1','CREATE UNIQUE INDEX `UQE_quota_org_id_user_id_target` ON `quota` (`org_id`,`user_id`,`target`);',1,'','2017-11-05 22:23:14'),(79,'create plugin_setting table','CREATE TABLE IF NOT EXISTS `plugin_setting` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NULL\n, `plugin_id` VARCHAR(255) NOT NULL\n, `enabled` TINYINT(1) NOT NULL\n, `pinned` TINYINT(1) NOT NULL\n, `json_data` TEXT NULL\n, `secure_json_data` TEXT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(80,'create index UQE_plugin_setting_org_id_plugin_id - v1','CREATE UNIQUE INDEX `UQE_plugin_setting_org_id_plugin_id` ON `plugin_setting` (`org_id`,`plugin_id`);',1,'','2017-11-05 22:23:14'),(81,'create session table','CREATE TABLE IF NOT EXISTS `session` (\n`key` CHAR(16) PRIMARY KEY NOT NULL\n, `data` BLOB NOT NULL\n, `expiry` INTEGER(255) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(82,'Drop old table playlist table','DROP TABLE IF EXISTS `playlist`',1,'','2017-11-05 22:23:14'),(83,'Drop old table playlist_item table','DROP TABLE IF EXISTS `playlist_item`',1,'','2017-11-05 22:23:14'),(84,'create playlist table v2','CREATE TABLE IF NOT EXISTS `playlist` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `name` VARCHAR(255) NOT NULL\n, `interval` VARCHAR(255) NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(85,'create playlist item table v2','CREATE TABLE IF NOT EXISTS `playlist_item` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `playlist_id` BIGINT(20) NOT NULL\n, `type` VARCHAR(255) NOT NULL\n, `value` TEXT NOT NULL\n, `title` TEXT NOT NULL\n, `order` INT NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(86,'drop preferences table v2','DROP TABLE IF EXISTS `preferences`',1,'','2017-11-05 22:23:14'),(87,'drop preferences table v3','DROP TABLE IF EXISTS `preferences`',1,'','2017-11-05 22:23:14'),(88,'create preferences table v3','CREATE TABLE IF NOT EXISTS `preferences` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `org_id` BIGINT(20) NOT NULL\n, `user_id` BIGINT(20) NOT NULL\n, `version` INT NOT NULL\n, `home_dashboard_id` BIGINT(20) NOT NULL\n, `timezone` VARCHAR(50) NOT NULL\n, `theme` VARCHAR(20) NOT NULL\n, `created` DATETIME NOT NULL\n, `updated` DATETIME NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(89,'create systems table ','CREATE TABLE IF NOT EXISTS `systems` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `systems_name` VARCHAR(255) NOT NULL\n, `slug` VARCHAR(255) NOT NULL\n, `org_id` BIGINT(255) NOT NULL\n, `deleted` INT(1) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(90,'create system_dash table ','CREATE TABLE IF NOT EXISTS `system_dash` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `system_id` BIGINT(20) NOT NULL\n, `dashboard_id` BIGINT(20) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(91,'create system_user table ','CREATE TABLE IF NOT EXISTS `system_user` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `system_id` BIGINT(20) NOT NULL\n, `user_id` VARCHAR(255) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(92,'create system_pick table ','CREATE TABLE IF NOT EXISTS `system_pick` (\n`id` BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL\n, `user_id` VARCHAR(255) NOT NULL\n, `system_id` BIGINT(20) NOT NULL\n) ENGINE=InnoDB DEFAULT CHARSET UTF8 ;',1,'','2017-11-05 22:23:14'),(93,'Add column intranet_url','alter table `data_source` ADD COLUMN `intranet_url` VARCHAR(255) NULL ',1,'','2018-12-02 14:09:19');
/*!40000 ALTER TABLE `migration_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org`
--

DROP TABLE IF EXISTS `org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `org` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip_code` varchar(50) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `billing_email` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `parent_id` bigint(20) DEFAULT '0' COMMENT 'agent',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_org_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org`
--

LOCK TABLES `org` WRITE;
/*!40000 ALTER TABLE `org` DISABLE KEYS */;
INSERT INTO `org` VALUES (1,0,'admin@localhost','','','','','','',NULL,'2017-11-05 22:23:14','2017-11-05 22:23:14',0);
/*!40000 ALTER TABLE `org` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org_permit`
--

DROP TABLE IF EXISTS `org_permit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `org_permit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `data_center` varchar(255) NOT NULL,
  `level` varchar(255) NOT NULL,
  `deadline` datetime NOT NULL,
  `agent_quota` bigint(20) NOT NULL DEFAULT '10',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_org_permit_org_id` (`org_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org_permit`
--

LOCK TABLES `org_permit` WRITE;
/*!40000 ALTER TABLE `org_permit` DISABLE KEYS */;
INSERT INTO `org_permit` VALUES (1,1,'private','free','2020-12-03 16:42:39',10);
/*!40000 ALTER TABLE `org_permit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org_product`
--

DROP TABLE IF EXISTS `org_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `org_product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `org_id` bigint(20) NOT NULL COMMENT '公司ID',
  `product_id` bigint(20) NOT NULL COMMENT '产品ID',
  `created` datetime NOT NULL COMMENT '创建时间',
  `updated` datetime NOT NULL COMMENT '修改时间',
  `deadline` datetime NOT NULL COMMENT '截止日期',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org_product`
--

LOCK TABLES `org_product` WRITE;
/*!40000 ALTER TABLE `org_product` DISABLE KEYS */;
INSERT INTO `org_product` VALUES (1,1,1,'2018-12-03 16:42:40','2018-12-03 16:42:40','2020-12-03 16:42:39');
/*!40000 ALTER TABLE `org_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `org_user`
--

DROP TABLE IF EXISTS `org_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `org_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `role` varchar(20) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `role2` varchar(20) NOT NULL DEFAULT 'Viewer',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_org_user_org_id_user_id` (`org_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `org_user`
--

LOCK TABLES `org_user` WRITE;
/*!40000 ALTER TABLE `org_user` DISABLE KEYS */;
INSERT INTO `org_user` VALUES (1,1,1,'Admin','2017-11-05 22:23:14','2017-11-05 22:23:14','SuperAdmin');
/*!40000 ALTER TABLE `org_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `id` int(20) NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alias` varchar(254) CHARACTER SET utf8 DEFAULT NULL,
  `component` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `permission` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `json` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `parentId` int(20) DEFAULT '0',
  `is_default` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (1,'metric','指标','monitor',NULL,NULL,'{\n\"id\": 1,\n\"text\": \"i18n_menu_dashboardlist\",\n\"url\": \"dashboardlist\",\n\"auth\": 0\n}',42,0),(2,'log','日志','monitor',NULL,NULL,'{\n\"id\": 2,\n\"text\": \"i18n_menu_logs\",\n\"url\": \"logs\",\n\"auth\": 0\n}',42,0),(3,'host','机器','monitor',NULL,NULL,'{\n\"id\": 3,\n\"text\": \"i18n_menu_host\",\n\"url\": \"monitor/hosts/host\",\n\"auth\": 0\n}',42,0),(4,'service','服务','monitor',NULL,NULL,'{\n\"id\": 4,\n\"text\": \"i18n_menu_service\",\n\"url\": \"monitor/services/service\",\n\"auth\": 0\n}',42,0),(5,'alerts','规则报警','alerting',NULL,NULL,'{\n\"id\": 1,\n\"text\": \"i18n_menu_alert_rule\",\n\"url\": \"alerts\",\n\"auth\": 0\n}',43,0),(6,'anomaly','智能报警','alerting',NULL,NULL,'{\n\"id\": 2,\n\"text\": \"i18n_menu_alert_auto\",\n\"url\": \"anomaly\",\n\"auth\": 0\n}',43,0),(7,'rca','诊断分析','diagnostic',NULL,NULL,'{\n\"id\": 1,\n\"text\": \"i18n_menu_diagnostic_assistant\",\n\"url\": \"diagnose/tool\",\n\"auth\": 0\n}',44,0),(8,'report','健康报告','diagnostic',NULL,NULL,'{\n\"id\": 2,\n\"text\": \"i18n_menu_report\",\n\"url\": \"report\",\n\"auth\": 0\n}',44,0),(9,'uagent','探针管理','setting',NULL,NULL,'{\n\"id\": 1,\n\"text\": \"i18n_menu_cmdb_config\",\n\"url\": \"cmdb/config?serviceName=collector\",\n\"auth\": 0\n}',45,0),(10,'logcollector','日志收集器','setting',NULL,NULL,'{\n\"id\": 2,\n\"text\": \"i18n_logcollector\",\n\"url\": \"logs/collectors\",\n\"auth\": 0\n}',45,0),(11,'metricsDefinition','指标管理','setting',NULL,NULL,'{\n\"id\": 3,\n\"text\": \"i18n_menu_cmdb_metrics\",\n\"url\": \"cmdb/metrics\",\n\"auth\": 0\n}',45,0),(12,'devices','设备管理','setting',NULL,NULL,'{\n\"id\": 4,\n\"text\": \"i18n_menu_cmdb_device\",\n\"url\": \"cmdb/device\",\n\"auth\": 5\n}',45,0),(13,'network','网络设备','setting',NULL,NULL,'{\n\"id\": 5,\n\"text\": \"i18n_menu_network\",\n\"url\": \"network/list\",\n\"auth\": 5\n}',45,0),(14,'getMetrics','指标查看','metric',NULL,NULL,NULL,1,0),(15,'updateMetrics','指标修改','metric',NULL,NULL,NULL,1,0),(16,'addMetrics','指标增加','metric',NULL,NULL,NULL,1,0),(17,'deleteMetrics','指标删除','metric',NULL,NULL,NULL,1,0),(18,'hostTags','标签新增/删除','host',NULL,NULL,NULL,3,0),(19,'hostService','在机器下添加服务','host',NULL,NULL,NULL,3,0),(20,'deleteHost','删除机器','host',NULL,NULL,NULL,3,0),(21,'dataview','DataView','menusTop',NULL,NULL,'{\n\"icon\": \"fa fa-fw fa-dataview\",\n\"id\": 10,\n\"text\": \"DataView\",\n\"url\": \"dataview\"\n}',0,0),(22,'alertStatus','报警状态','alert',NULL,NULL,NULL,5,0),(23,'alertDiagnosis','诊断分析','alert',NULL,NULL,NULL,5,0),(24,'alertDeny','延迟报警','alert',NULL,NULL,NULL,5,0),(25,'postmortem','处理报警','alert',NULL,NULL,NULL,5,0),(26,'alertRule','报警规则查看','alert',NULL,NULL,NULL,5,0),(27,'alertMan','报警规则管理','alert',NULL,NULL,NULL,5,0),(28,'export/import','导入导出','alert',NULL,NULL,NULL,5,0),(29,'anomalyHistory','历史查看','anomaly',NULL,NULL,NULL,6,0),(30,'anomalySnooze','暂缓报警','anomaly',NULL,NULL,NULL,6,0),(31,'alertSnooze','暂缓报警','alert',NULL,NULL,NULL,5,0),(32,'rootCause','诊断助手','rca',NULL,NULL,NULL,7,0),(33,'reportSetting','健康报告设置','report',NULL,NULL,NULL,8,0),(34,'oncallerAdd','添加值班人员','oncaller',NULL,NULL,NULL,35,0),(35,'oncaller','运维轮班','menusBottom',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-calendar\",\n    \"id\": 101,\n    \"text\": \"i18n_oncaller\",\n    \"url\": \"oncaller/schedule\",\n    \"auth\": 0\n}',0,1),(36,'oncallerSetting','值班人员','oncaller',NULL,NULL,NULL,35,0),(38,'knowledgeAdd','创建运维知识','knowledgebase',NULL,NULL,NULL,37,0),(39,'profile','个人信息','menu','/user/*','user:all',NULL,0,0),(40,'orgs','公司管理','menu','/org/*','org:all',NULL,0,0),(41,'backend','后台管理','menu','',NULL,NULL,0,0),(42,'monitor','实时监控','menusTop',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-tachometer\",\n    \"id\": 2,\n    \"text\": \"i18n_menu_monitor\",\n    \"url\": \"dashboardlist\"\n}',0,1),(43,'alerting','实时报警','menusTop',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-bell\",\n    \"id\": 3,\n    \"text\": \"i18n_menu_alert\",\n    \"url\": \"3\"\n}',0,1),(44,'diagnostic','分析诊断','menusTop',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-bar-chart\",\n    \"id\": 4,\n    \"text\": \"i18n_menu_diagnosis\",\n    \"url\": \"4\"\n}',0,1),(45,'setting','系统配置','menusTop',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-cubes\",\n    \"id\": 5,\n    \"text\": \"i18n_menu_cmdb\",\n    \"url\": \"5\"\n}',0,1),(46,'install','安装指南','menusBottom',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-cloud-download\",\n    \"id\": 103,\n    \"text\": \"i18n_install_guide\",\n    \"url\": \"setting/agent\",\n    \"auth\": 0\n}',0,1),(47,'knowledgebase','运维知识库','menusBottom',NULL,NULL,'{\n    \"icon\": \"fa fa-fw fa-book\",\n    \"id\": 102,\n    \"text\": \"i18n_kb\",\n    \"url\": \"knowledgebase\",\n    \"auth\": 0\n}',0,1),(48,'azure','azure','setting',NULL,NULL,'{\n\"id\": 6,\n\"text\": \"i18n_azure_integration\",\n\"url\": \"/installation/modules?name=azure\",\n\"auth\": 0,\"target\":\"_top\"\n}',45,0),(49,'topn','资源消耗','diagnostic',NULL,NULL,'{\n\"id\": 3,\n\"text\": \"i18n_menu_topn\",\n\"url\": \"topn\",\n\"auth\": 0\n}',44,0),(50,'rca','故障溯源','diagnostic',NULL,NULL,'{\n  \"id\": 4,\n  \"text\": \"i18n_menu_rca\",\n  \"url\": \"rca\"\n}',44,0),(51,'predict','资源预测','diagnostic',NULL,NULL,'{\"id\":5,\"text\":\"page_host_tab6\",\"url\":\"resource_predictor\",\"auth\":0}',44,0),(52,'logparser','日志解析器','setting',NULL,NULL,'{\"id\":7,\"text\":\"i18n_logparser\",\"url\":\"logs/parserlist\",\"auth\":0}',45,0),(53,'hardware','硬件管理','setting',NULL,NULL,'{\"id\":6,\"text\":\"硬件管理\",\"url\":\"/installation/modules?name=hardware\",\"auth\":0,\"target\":\"_top\"}',45,0), (54,'Installation Guide','新安装指南','menusBottom',NULL,NULL,'{\"icon\":\"fa fa-fw fa-cloud-download\",\"id\":104,\"text\":\"新安装指南\",\"url\":\"installation/getstarted\",\"auth\":0,\"target\":\"_top\"}',0,0),(55,'Plugin Center','插件中心','setting',NULL,NULL,'{\"id\":6,\"text\":\"i18n_menu_plugin_center\",\"url\":\"/plugin/management\",\"auth\":0}',45,0), (56,'Schedule Center', '调度中心','setting',NULL,NULL,'{\"id\":8,\"text\":\"i18n_menu_schedule_center\",\"url\":\"/schedule/management\",\"auth\": 0}',45,0), (57,'data_source management', '数据管理','setting',NULL,NULL,'{\"id\”:9,\”text\":\"i18n_menu_datasource_management\”,\”url\”:\”/datasource/management\”,\”auth\": 0}',45,0);
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playlist`
--

DROP TABLE IF EXISTS `playlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playlist` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `interval` varchar(255) NOT NULL,
  `org_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlist`
--

LOCK TABLES `playlist` WRITE;
/*!40000 ALTER TABLE `playlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `playlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playlist_item`
--

DROP TABLE IF EXISTS `playlist_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playlist_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `playlist_id` bigint(20) NOT NULL,
  `type` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `title` text NOT NULL,
  `order` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlist_item`
--

LOCK TABLES `playlist_item` WRITE;
/*!40000 ALTER TABLE `playlist_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `playlist_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugin_setting`
--

DROP TABLE IF EXISTS `plugin_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin_setting` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) DEFAULT NULL,
  `plugin_id` varchar(255) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `pinned` tinyint(1) NOT NULL,
  `json_data` text,
  `secure_json_data` text,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_plugin_setting_org_id_plugin_id` (`org_id`,`plugin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugin_setting`
--

LOCK TABLES `plugin_setting` WRITE;
/*!40000 ALTER TABLE `plugin_setting` DISABLE KEYS */;
/*!40000 ALTER TABLE `plugin_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preferences`
--

DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preferences` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `version` int(11) NOT NULL,
  `home_dashboard_id` bigint(20) NOT NULL,
  `timezone` varchar(50) NOT NULL,
  `theme` varchar(20) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `language` varchar(50) DEFAULT 'en',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preferences`
--

LOCK TABLES `preferences` WRITE;
/*!40000 ALTER TABLE `preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `preferences` ENABLE KEYS */;
INSERT INTO `preferences` VALUES (1,1,1,1,0,'','light','2017-11-05 22:23:14','2017-11-05 22:23:14','zh_CN');
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `id` bigint(20) NOT NULL COMMENT '主键',
  `name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '产品名称',
  `i18n` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '国际化',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'监控','i18n_monitoring'),(2,'计费','i18n_billing');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_permission`
--

DROP TABLE IF EXISTS `product_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_permission` (
  `permission_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '权限ID',
  `product_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '产品ID',
  PRIMARY KEY (`product_id`,`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='权限-产品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_permission`
--

LOCK TABLES `product_permission` WRITE;
/*!40000 ALTER TABLE `product_permission` DISABLE KEYS */;
INSERT INTO `product_permission` VALUES (1,1),(2,1),(3,1),(4,1),(5,1),(6,1),(7,1),(8,1),(9,1),(10,1),(11,1),(12,1),(13,1),(14,1),(15,1),(16,1),(17,1),(18,1),(19,1),(20,1),(21,1),(22,1),(23,1),(24,1),(25,1),(26,1),(27,1),(28,1),(29,1),(30,1),(31,1),(32,1),(33,1),(34,1),(35,1),(36,1),(38,1),(39,1),(40,1),(41,1),(42,1),(43,1),(44,1),(45,1),(46,1),(47,1),(48,1),(49,1),(50,1),(51,1),(39,2),(40,2),(41,2),(52,1),(53,1),(54,1),(55,1),(56,1);
/*!40000 ALTER TABLE `product_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `propose_user`
--

DROP TABLE IF EXISTS `propose_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `propose_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `org` varchar(255) DEFAULT NULL,
  `scale` varchar(20) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `propose_user`
--

LOCK TABLES `propose_user` WRITE;
/*!40000 ALTER TABLE `propose_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `propose_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quota`
--

DROP TABLE IF EXISTS `quota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `target` varchar(255) NOT NULL,
  `limit` bigint(20) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_quota_org_id_user_id_target` (`org_id`,`user_id`,`target`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quota`
--

LOCK TABLES `quota` WRITE;
/*!40000 ALTER TABLE `quota` DISABLE KEYS */;
/*!40000 ALTER TABLE `quota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `req_key`
--

DROP TABLE IF EXISTS `req_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `req_key` (
  `id` varchar(50) NOT NULL,
  `org_id` bigint(20) DEFAULT NULL,
  `sys_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `req_key`
--

LOCK TABLES `req_key` WRITE;
/*!40000 ALTER TABLE `req_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `req_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `role_name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `org_id` bigint(20) NOT NULL,
  `rank` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,0,'superadmin',0,100),(2,0,'subadmin',0,200),(3,0,'orgadmin',1,300),(4,0,'editor',1,500),(5,0,'viewer',1,600);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_permission` (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) NOT NULL,
  `permission_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=316 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` VALUES (1,1,1),(2,1,2),(3,1,3),(4,1,4),(5,1,5),(6,1,6),(7,1,7),(8,1,8),(9,1,9),(10,1,10),(11,1,11),(12,1,12),(13,1,13),(14,1,14),(15,1,15),(16,1,16),(17,1,17),(18,1,18),(19,1,19),(20,1,20),(21,1,21),(22,1,22),(23,1,23),(24,1,24),(25,1,25),(26,1,26),(27,1,27),(28,1,28),(29,1,29),(30,1,30),(31,1,31),(32,1,32),(33,1,33),(34,1,34),(35,1,35),(36,1,36),(37,1,38),(38,1,39),(39,1,40),(40,1,41),(41,1,42),(42,1,43),(43,1,44),(44,1,45),(45,1,46),(46,1,47),(47,1,48),(48,1,49),(49,1,50),(50,1,51),(64,2,1),(65,2,2),(66,2,3),(67,2,4),(68,2,5),(69,2,6),(70,2,7),(71,2,8),(72,2,9),(73,2,10),(74,2,11),(75,2,12),(76,2,13),(77,2,14),(78,2,15),(79,2,16),(80,2,17),(81,2,18),(82,2,19),(83,2,20),(84,2,22),(85,2,23),(86,2,24),(87,2,25),(88,2,26),(89,2,27),(90,2,28),(91,2,29),(92,2,30),(93,2,31),(94,2,32),(95,2,33),(96,2,34),(97,2,35),(98,2,36),(99,2,38),(100,2,39),(101,2,40),(102,2,41),(103,2,42),(104,2,43),(105,2,44),(106,2,45),(107,2,46),(108,2,47),(109,2,48),(110,2,49),(111,2,50),(112,2,51),(127,3,1),(128,3,2),(129,3,3),(130,3,4),(131,3,5),(132,3,6),(133,3,7),(134,3,8),(135,3,9),(136,3,10),(137,3,11),(138,3,14),(139,3,16),(140,3,17),(141,3,18),(142,3,19),(143,3,20),(144,3,22),(145,3,23),(146,3,24),(147,3,25),(148,3,26),(149,3,27),(150,3,28),(151,3,29),(152,3,30),(153,3,31),(154,3,32),(155,3,33),(156,3,34),(157,3,35),(158,3,36),(159,3,38),(160,3,39),(161,3,40),(162,3,42),(163,3,43),(164,3,44),(165,3,45),(166,3,46),(167,3,47),(168,3,49),(169,3,50),(170,3,51),(190,4,1),(191,4,2),(192,4,3),(193,4,4),(194,4,5),(195,4,6),(196,4,7),(197,4,8),(198,4,9),(199,4,10),(200,4,11),(201,4,14),(202,4,16),(203,4,17),(204,4,18),(205,4,19),(206,4,20),(207,4,22),(208,4,23),(209,4,24),(210,4,25),(211,4,26),(212,4,27),(213,4,28),(214,4,29),(215,4,30),(216,4,31),(217,4,32),(218,4,33),(219,4,34),(220,4,35),(221,4,36),(222,4,38),(223,4,39),(224,4,40),(225,4,42),(226,4,43),(227,4,44),(228,4,45),(229,4,46),(230,4,47),(231,4,49),(232,4,50),(233,4,51),(253,5,1),(254,5,2),(255,5,3),(256,5,4),(257,5,5),(258,5,6),(259,5,7),(260,5,8),(261,5,11),(262,5,14),(263,5,16),(264,5,17),(265,5,18),(266,5,19),(267,5,20),(268,5,22),(269,5,23),(270,5,24),(271,5,25),(272,5,26),(273,5,27),(274,5,28),(275,5,29),(276,5,30),(277,5,31),(278,5,32),(279,5,33),(280,5,38),(281,5,39),(282,5,40),(283,5,42),(284,5,43),(285,5,44),(286,5,45),(287,5,47),(288,5,49),(289,5,50),(290,5,51),(291,1,52),(292,2,52),(293,3,52),(294,4,52),(295,5,52);
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `key` char(16) NOT NULL,
  `data` blob NOT NULL,
  `expiry` int(255) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `star`
--

DROP TABLE IF EXISTS `star`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `star` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `dashboard_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_star_user_id_dashboard_id` (`user_id`,`dashboard_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `star`
--

LOCK TABLES `star` WRITE;
/*!40000 ALTER TABLE `star` DISABLE KEYS */;
/*!40000 ALTER TABLE `star` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_dash`
--

DROP TABLE IF EXISTS `system_dash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_dash` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `dashboard_id` bigint(20) NOT NULL,
  `count` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_dash`
--

LOCK TABLES `system_dash` WRITE;
/*!40000 ALTER TABLE `system_dash` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_dash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_pick`
--

DROP TABLE IF EXISTS `system_pick`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_pick` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `system_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_pick`
--

LOCK TABLES `system_pick` WRITE;
/*!40000 ALTER TABLE `system_pick` DISABLE KEYS */;
INSERT INTO `system_pick` VALUES (1,'1',1);
/*!40000 ALTER TABLE `system_pick` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_user`
--

DROP TABLE IF EXISTS `system_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `role_id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_user`
--

LOCK TABLES `system_user` WRITE;
/*!40000 ALTER TABLE `system_user` DISABLE KEYS */;
INSERT INTO `system_user` VALUES (1,1,'1',3);
/*!40000 ALTER TABLE `system_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `systems`
--

DROP TABLE IF EXISTS `systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `systems` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `systems_name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `org_id` bigint(255) NOT NULL,
  `deleted` int(1) NOT NULL,
  `rank` int(6) DEFAULT '0',
  `type` int(2) DEFAULT '1' COMMENT 'system_type',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `systems`
--

LOCK TABLES `systems` WRITE;
/*!40000 ALTER TABLE `systems` DISABLE KEYS */;
INSERT INTO `systems` VALUES (1,'Cloudwiz','cloudwiz',1,0,0,1);
/*!40000 ALTER TABLE `systems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_system_user`
--

DROP TABLE IF EXISTS `temp_system_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_system_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) COLLATE utf8_bin NOT NULL,
  `system_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_system_user`
--

LOCK TABLES `temp_system_user` WRITE;
/*!40000 ALTER TABLE `temp_system_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_system_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_user`
--

DROP TABLE IF EXISTS `temp_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org_id` bigint(20) NOT NULL,
  `version` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `invited_by_user_id` bigint(20) DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL,
  `email_sent_on` datetime DEFAULT NULL,
  `remote_addr` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_temp_user_email` (`email`),
  KEY `IDX_temp_user_org_id` (`org_id`),
  KEY `IDX_temp_user_code` (`code`),
  KEY `IDX_temp_user_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_user`
--

LOCK TABLES `temp_user` WRITE;
/*!40000 ALTER TABLE `temp_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `login` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `salt` varchar(50) DEFAULT NULL,
  `rands` varchar(50) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `org_id` bigint(20) NOT NULL,
  `is_admin` tinyint(1) NOT NULL,
  `email_verified` tinyint(1) DEFAULT NULL,
  `theme` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_system_id` bigint(20) NOT NULL DEFAULT '0',
  `origin_org_id` bigint(20) NOT NULL COMMENT 'origin_orgId',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQE_user_login` (`login`),
  UNIQUE KEY `UQE_user_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,0,'admin','admin@localhost','admin','362a6645f94b71c441bfd8c6ced78456d5f948b5','rqNyWYrWDQ','ZCLJloybXH','',1,1,0,'light','2017-11-05 22:23:14','2017-11-05 22:23:14',NULL,1,0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_data`
--

SET NAMES utf8;

DROP TABLE IF EXISTS `temp_data`;
CREATE TABLE `temp_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) NOT NULL COMMENT 'type',
  `code` varchar(255) DEFAULT NULL COMMENT 'code',
  `created` datetime NOT NULL,
  `updated` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `email` varchar(255) DEFAULT NULL,
  `status` int(2) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `code_index` (`code`) COMMENT 'codeindex'
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;


--
-- Current Database: `CloudwizCMDB`
--

/*!40000 DROP DATABASE IF EXISTS `<:cmdb_database:>`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `<:cmdb_database:>` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `<:cmdb_database:>`;

--
-- Table structure for table `cw_Attribute`
--

DROP TABLE IF EXISTS `cw_Attribute`;
CREATE TABLE `cw_Attribute` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `ciId` bigint(20) NOT NULL,
  `name` varchar(1024) NOT NULL,
  `value` mediumtext,
  `deletedAt` datetime DEFAULT NULL,
  `type` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cw_Attribute_cw_CI_id_fk` (`ciId`),
  KEY `cw_Attribute_orgId_sysId_name_value_index` (`orgId`,`sysId`,`name`(64),`value`(64)),
  CONSTRAINT `cw_Attribute_cw_CI_id_fk` FOREIGN KEY (`ciId`) REFERENCES `cw_CI` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18909 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Attribute`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Attribute` VALUES ('7', '0', '0', '2', 'name', 'filebeat', null, '0'), ('8', '0', '0', '2', 'version', '0', null, '0'), ('9', '0', '0', '2', 'serviceVersion', '0', null, '0'), ('10', '0', '0', '2', 'serviceName', 'filebeat', null, '0'), ('11', '0', '0', '2', 'scope', 'definition', null, '0'), ('12', '0', '0', '2', 'content', '{\"id\":0,\"orgId\":0,\"sysId\":0,\"name\":\"filebeat\",\"version\":0,\"lastModified\":0,\"lastModifiedBy\":\"nobody\",\"type\":\"definition\",\"serviceId\":0,\"hostId\":0,\"properties\":{\"filebeat.prospectors\":[{\"input_type\":{\"type\":\"string\",\"readOnly\":true},\"paths\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"document_type\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"apache\",\"collector\",\"cloudwiz\",\"hadoop\",\"hbase\",\"mysql\",\"nginx\",\"spark\",\"storm\",\"system\",\"tomcat\",\"tsd\",\"yarn\",\"zookeeper\"]},\"fields.orgid\":{\"type\":\"integer\",\"readOnly\":true},\"fields.sysid\":{\"type\":\"integer\",\"readOnly\":true},\"fields.token\":{\"type\":\"string\",\"readOnly\":true},\"fields_under_root\":{\"type\":\"boolean\",\"readOnly\":true},\"close_*\":{\"type\":\"boolean\",\"readOnly\":true},\"tail_files\":{\"type\":\"boolean\",\"readOnly\":true},\"multiline.pattern\":{\"type\":\"string\",\"optional\":true,\"readOnly\":false},\"multiline.negate\":{\"type\":\"boolean\",\"readOnly\":false},\"multiline.match\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"after\",\"before\"]}}],\"output.logstash\":{\"hosts\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":true},\"ssl.enabled\":{\"type\":\"boolean\",\"readOnly\":true},\"ssl.certificate_authorities\":{\"type\":\"string\",\"readOnly\":true,\"isCollection\":true},\"ssl.certificate\":{\"type\":\"string\",\"readOnly\":true},\"ssl.key\":{\"type\":\"string\",\"readOnly\":true},\"ssl.supported_protocols\":{\"type\":\"string\",\"readOnly\":true}},\"logging.level\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"critical\",\"debug\",\"error\",\"info\",\"warning\"]},\"logging.to_files\":{\"type\":\"boolean\",\"readOnly\":false},\"logging.to_syslog\":{\"type\":\"boolean\",\"readOnly\":false},\"logging.files\":{\"path\":{\"type\":\"string\",\"readOnly\":false},\"name\":{\"type\":\"string\",\"readOnly\":false},\"keepfiles\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":2,\"maxValue\":1024},\"rotateeverybytes\":{\"type\":\"integer\",\"readOnly\":false}}}}', null, '0'), ('13', '0', '0', '3', 'name', 'collector', null, '0'), ('14', '0', '0', '3', 'version', '0', null, '0'), ('15', '0', '0', '3', 'serviceVersion', '0', null, '0'), ('16', '0', '0', '3', 'serviceName', 'collector', null, '0'), ('17', '0', '0', '3', 'scope', 'definition', null, '0'), ('18', '0', '0', '3', 'content', '{\"Apache\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"disable_ssl_validation\":{\"type\":\"boolean\",\"readOnly\":false},\"apache_url\":{\"type\":\"string\",\"readOnly\":false},\"connect_timeout\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":0,\"unit\":\"sec\"},\"receive_timeout\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":0,\"unit\":\"sec\"}}},\"Cloudmon\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Cloudwiz\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"process\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":true}}},\"Cpus_pctusage\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Cwagent\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Docker_alauda\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Dockerd\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Elasticsearch\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Elasticsearchstat\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"protocol\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"http\",\"https\"]},\"authentication\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"enabled\",\"disabled\"]},\"cert_verification\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"enabled\",\"disabled\"]},\"user\":{\"type\":\"string\",\"readOnly\":false},\"password\":{\"type\":\"password\",\"readOnly\":false}}},\"Flume\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Hadoop_data_node\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Hadoop_name_node\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Hbase_master\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Hbase_regionserver\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Hbase_regionserver_info\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"hbase_bin\":{\"type\":\"string\",\"readOnly\":false},\"master_status_url\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"state_file\":{\"type\":\"string\",\"readOnly\":false}}},\"Hive\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Host_topn\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"N\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":100}}},\"Iftop\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Iostat\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Iostats\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Jvm\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"java_home\":{\"type\":\"string\",\"readOnly\":false},\"processes\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"log_file\":{\"type\":\"string\",\"readOnly\":false}}},\"Kafka\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"java_home\":{\"type\":\"string\",\"readOnly\":false},\"process\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Kafka_consumers\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"process_names\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false}}},\"Kubernetes\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}},\"cadvisor\":{\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"protocol\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"http\",\"https\"]}},\"coredns\":{\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"protocol\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"http\",\"https\"]}},\"kube-state\":{\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"protocol\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"http\",\"https\"]}}},\"Manual_script\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"command\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false}}},\"Map_reduce\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Mongo3\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"db\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"config\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"mongos\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"replica\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":false},\"username\":{\"type\":\"string\",\"readOnly\":false},\"password\":{\"type\":\"password\",\"readOnly\":false}}},\"Mysql\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"user\":{\"type\":\"string\",\"readOnly\":false},\"pass\":{\"type\":\"password\",\"readOnly\":false}}},\"Netstat\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Nginx\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"is_enable_https\":{\"type\":\"boolean\",\"readOnly\":false},\"uri\":{\"type\":\"string\",\"readOnly\":false}}},\"Ntp\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"timeout\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":0,\"unit\":\"sec\"}}},\"Opentsdb\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Oracle\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"username\":{\"type\":\"string\",\"readOnly\":false},\"password\":{\"type\":\"password\",\"readOnly\":false},\"database\":{\"type\":\"string\",\"readOnly\":false}},\"sql\":{\"active|val\":{\"type\":\"string\",\"readOnly\":true},\"rcachehit|val\":{\"type\":\"string\",\"readOnly\":true},\"dsksortratio|val\":{\"type\":\"string\",\"readOnly\":true},\"activeusercount|val\":{\"type\":\"string\",\"readOnly\":true},\"dbsize|val\":{\"type\":\"string\",\"readOnly\":true},\"dbfilesize|val\":{\"type\":\"string\",\"readOnly\":true},\"uptime|val\":{\"type\":\"string\",\"readOnly\":true},\"commits|val\":{\"type\":\"string\",\"readOnly\":true},\"rollbacks|val\":{\"type\":\"string\",\"readOnly\":true},\"deadlocks|val\":{\"type\":\"string\",\"readOnly\":true},\"redowrites|val\":{\"type\":\"string\",\"readOnly\":true},\"tblscans|val\":{\"type\":\"string\",\"readOnly\":true},\"tblrowsscans|val\":{\"type\":\"string\",\"readOnly\":true},\"indexffs|val\":{\"type\":\"string\",\"readOnly\":true},\"hardparseratio|val\":{\"type\":\"string\",\"readOnly\":true},\"netsent|val\":{\"type\":\"string\",\"readOnly\":true},\"netresv|val\":{\"type\":\"string\",\"readOnly\":true},\"netroundtrips|val\":{\"type\":\"string\",\"readOnly\":true},\"logonscurrent|val\":{\"type\":\"string\",\"readOnly\":true},\"lastarclog|val\":{\"type\":\"string\",\"readOnly\":true},\"lastapplarclog|val\":{\"type\":\"string\",\"readOnly\":true},\"logswcompletion|val\":{\"type\":\"string\",\"readOnly\":true},\"event.freebufwaits|val\":{\"type\":\"string\",\"readOnly\":true},\"event.bufbusywaits|val\":{\"type\":\"string\",\"readOnly\":true},\"event.logfilesync|val\":{\"type\":\"string\",\"readOnly\":true},\"event.logparallelwrite|val\":{\"type\":\"string\",\"readOnly\":true},\"event.enqueue|val\":{\"type\":\"string\",\"readOnly\":true},\"event.dbseqread|val\":{\"type\":\"string\",\"readOnly\":true},\"event.dbscattread|val\":{\"type\":\"string\",\"readOnly\":true},\"event.dbsinglewrite|val\":{\"type\":\"string\",\"readOnly\":true},\"event.dbparallelwrite|val\":{\"type\":\"string\",\"readOnly\":true},\"event.directread|val\":{\"type\":\"string\",\"readOnly\":true},\"event.directwrite|val\":{\"type\":\"string\",\"readOnly\":true},\"event.latchfree|val\":{\"type\":\"string\",\"readOnly\":true},\"query_sessions|val\":{\"type\":\"string\",\"readOnly\":true},\"query_rollbacks|val\":{\"type\":\"string\",\"readOnly\":true}},\"customize\":{\"slow.query|val|elapsed_time|cmd\":{\"type\":\"string\",\"readOnly\":true}}},\"Play_framework\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"process_names\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":true}}},\"Postgresql\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"user\":{\"type\":\"string\",\"readOnly\":false},\"password\":{\"type\":\"password\",\"readOnly\":false}}},\"Procstats\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Rabbit_mq\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"rabbitmq_api_url\":{\"type\":\"string\",\"readOnly\":false},\"rabbitmq_user\":{\"type\":\"string\",\"readOnly\":false},\"rabbitmq_pass\":{\"type\":\"string\",\"readOnly\":false}}},\"Redisdb\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"string\",\"readOnly\":false},\"slowloglen\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Response_time\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"urls\":{\"type\":\"string\",\"readOnly\":true}}},\"Services_startup\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"services\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":true}}},\"Spark\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"spark_host\":{\"type\":\"string\",\"readOnly\":false},\"spark_port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Ssdb_state\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Storm\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Summary\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Tomcat\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"protocol\":{\"type\":\"enum\",\"readOnly\":false,\"enumValues\":[\"http\",\"https\"]},\"ports\":{\"type\":\"integer\",\"isCollection\":true,\"readOnly\":false,\"minValue\":1,\"maxValue\":65535},\"tomcat_version\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Weblogic\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"process_names\":{\"type\":\"string\",\"isCollection\":true,\"readOnly\":true}}},\"Win32_top_n\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}},\"Yarn\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"host\":{\"type\":\"string\",\"readOnly\":false},\"port\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"maxValue\":65535}}},\"Zookeeper\":{\"base\":{\"enabled\":{\"type\":\"boolean\",\"readOnly\":false},\"interval\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"},\"user\":{\"type\":\"string\",\"readOnly\":false},\"SCAN_INTERVAL\":{\"type\":\"integer\",\"readOnly\":false,\"minValue\":1,\"unit\":\"sec\"}}}}', null, '0'), ('19', '0', '0', '4', 'name', 'Cloudmon', null, '0'), ('20', '0', '0', '4', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/cloudmon.conf', null, '0'), ('21', '0', '0', '4', 'lastModifiedBy', 'nobody', null, '0'), ('22', '0', '0', '4', 'configVersion', '0', null, '0'), ('23', '0', '0', '4', 'serviceVersion', '0', null, '0'), ('24', '0', '0', '4', 'serviceName', 'collector', null, '0'), ('25', '0', '0', '4', 'scope', 'template', null, '0'), ('26', '0', '0', '4', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('27', '0', '0', '5', 'name', 'Cpus_pctusage', null, '0'), ('28', '0', '0', '5', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/cpus_pctusage.conf', null, '0'), ('29', '0', '0', '5', 'lastModifiedBy', 'nobody', null, '0'), ('30', '0', '0', '5', 'configVersion', '0', null, '0'), ('31', '0', '0', '5', 'serviceVersion', '0', null, '0'), ('32', '0', '0', '5', 'serviceName', 'collector', null, '0'), ('33', '0', '0', '5', 'scope', 'template', null, '0'), ('34', '0', '0', '5', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('35', '0', '0', '6', 'name', 'Cwagent', null, '0'), ('36', '0', '0', '6', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/cwagent.conf', null, '0'), ('37', '0', '0', '6', 'lastModifiedBy', 'nobody', null, '0'), ('38', '0', '0', '6', 'configVersion', '0', null, '0'), ('39', '0', '0', '6', 'serviceVersion', '0', null, '0'), ('40', '0', '0', '6', 'serviceName', 'collector', null, '0'), ('41', '0', '0', '6', 'scope', 'template', null, '0'), ('42', '0', '0', '6', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('51', '0', '0', '8', 'name', 'Docker_alauda', null, '0'), ('52', '0', '0', '8', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/docker_alauda.conf', null, '0'), ('53', '0', '0', '8', 'lastModifiedBy', 'nobody', null, '0'), ('54', '0', '0', '8', 'configVersion', '0', null, '0'), ('55', '0', '0', '8', 'serviceVersion', '0', null, '0'), ('56', '0', '0', '8', 'serviceName', 'collector', null, '0'), ('57', '0', '0', '8', 'scope', 'template', null, '0'), ('58', '0', '0', '8', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60}]}]', null, '0'), ('59', '0', '0', '9', 'name', 'Dockerd', null, '0'), ('60', '0', '0', '9', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/dockerd.conf', null, '0'), ('61', '0', '0', '9', 'lastModifiedBy', 'nobody', null, '0'), ('62', '0', '0', '9', 'configVersion', '0', null, '0'), ('63', '0', '0', '9', 'serviceVersion', '0', null, '0'), ('64', '0', '0', '9', 'serviceName', 'collector', null, '0'), ('65', '0', '0', '9', 'scope', 'template', null, '0'), ('66', '0', '0', '9', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60}]}]', null, '0'), ('67', '0', '0', '10', 'name', 'Elasticsearch', null, '0'), ('68', '0', '0', '10', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/elasticsearch.conf', null, '0'), ('69', '0', '0', '10', 'lastModifiedBy', 'nobody', null, '0'), ('70', '0', '0', '10', 'configVersion', '0', null, '0'), ('71', '0', '0', '10', 'serviceVersion', '0', null, '0'), ('72', '0', '0', '10', 'serviceName', 'collector', null, '0'), ('73', '0', '0', '10', 'scope', 'template', null, '0'), ('74', '0', '0', '10', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60}]}]', null, '0'), ('75', '0', '0', '11', 'name', 'Elasticsearchstat', null, '0'), ('76', '0', '0', '11', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/elasticsearchstat.conf', null, '0'), ('77', '0', '0', '11', 'lastModifiedBy', 'nobody', null, '0'), ('78', '0', '0', '11', 'configVersion', '0', null, '0'), ('79', '0', '0', '11', 'serviceVersion', '0', null, '0'), ('80', '0', '0', '11', 'serviceName', 'collector', null, '0'), ('81', '0', '0', '11', 'scope', 'template', null, '0'), ('82', '0', '0', '11', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":9200},{\"name\":\"protocol\",\"value\":\"http\"},{\"name\":\"authentication\",\"value\":\"disabled\"},{\"name\":\"cert_verification\",\"value\":\"enabled\"},{\"name\":\"user\",\"value\":\"\"},{\"name\":\"password\",\"value\":\"\"}]}]', null, '0'), ('83', '0', '0', '12', 'name', 'Flume', null, '0'), ('84', '0', '0', '12', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/flume.conf', null, '0'), ('85', '0', '0', '12', 'lastModifiedBy', 'nobody', null, '0'), ('86', '0', '0', '12', 'configVersion', '0', null, '0'), ('87', '0', '0', '12', 'serviceVersion', '0', null, '0'), ('88', '0', '0', '12', 'serviceName', 'collector', null, '0'), ('89', '0', '0', '12', 'scope', 'template', null, '0'), ('90', '0', '0', '12', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":41414}]}]', null, '0'), ('91', '0', '0', '13', 'name', 'Hadoop_data_node', null, '0'), ('92', '0', '0', '13', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hadoop_data_node.conf', null, '0'), ('93', '0', '0', '13', 'lastModifiedBy', 'nobody', null, '0'), ('94', '0', '0', '13', 'configVersion', '0', null, '0'), ('95', '0', '0', '13', 'serviceVersion', '0', null, '0'), ('96', '0', '0', '13', 'serviceName', 'collector', null, '0'), ('97', '0', '0', '13', 'scope', 'template', null, '0'), ('98', '0', '0', '13', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('99', '0', '0', '14', 'name', 'Hadoop_name_node', null, '0'), ('100', '0', '0', '14', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hadoop_name_node.conf', null, '0'), ('101', '0', '0', '14', 'lastModifiedBy', 'nobody', null, '0'), ('102', '0', '0', '14', 'configVersion', '0', null, '0'), ('103', '0', '0', '14', 'serviceVersion', '0', null, '0'), ('104', '0', '0', '14', 'serviceName', 'collector', null, '0'), ('105', '0', '0', '14', 'scope', 'template', null, '0'), ('106', '0', '0', '14', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":90}]}]', null, '0'), ('107', '0', '0', '15', 'name', 'Hbase_master', null, '0'), ('108', '0', '0', '15', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hbase_master.conf', null, '0'), ('109', '0', '0', '15', 'lastModifiedBy', 'nobody', null, '0'), ('110', '0', '0', '15', 'configVersion', '0', null, '0'), ('111', '0', '0', '15', 'serviceVersion', '0', null, '0'), ('112', '0', '0', '15', 'serviceName', 'collector', null, '0'), ('113', '0', '0', '15', 'scope', 'template', null, '0'), ('114', '0', '0', '15', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"port\",\"value\":16010}]}]', null, '0'), ('115', '0', '0', '16', 'name', 'Hbase_regionserver', null, '0'), ('116', '0', '0', '16', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hbase_regionserver.conf', null, '0'), ('117', '0', '0', '16', 'lastModifiedBy', 'nobody', null, '0'), ('118', '0', '0', '16', 'configVersion', '0', null, '0'), ('119', '0', '0', '16', 'serviceVersion', '0', null, '0'), ('120', '0', '0', '16', 'serviceName', 'collector', null, '0'), ('121', '0', '0', '16', 'scope', 'template', null, '0'), ('122', '0', '0', '16', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"port\",\"value\":16030}]}]', null, '0'), ('123', '0', '0', '17', 'name', 'Hive', null, '0'), ('124', '0', '0', '17', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hive.conf', null, '0'), ('125', '0', '0', '17', 'lastModifiedBy', 'nobody', null, '0'), ('126', '0', '0', '17', 'configVersion', '0', null, '0'), ('127', '0', '0', '17', 'serviceVersion', '0', null, '0'), ('128', '0', '0', '17', 'serviceName', 'collector', null, '0'), ('129', '0', '0', '17', 'scope', 'template', null, '0'), ('130', '0', '0', '17', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('131', '0', '0', '18', 'name', 'Host_topn', null, '0'), ('132', '0', '0', '18', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/host_topn.conf', null, '0'), ('133', '0', '0', '18', 'lastModifiedBy', 'nobody', null, '0'), ('134', '0', '0', '18', 'configVersion', '0', null, '0'), ('135', '0', '0', '18', 'serviceVersion', '0', null, '0'), ('136', '0', '0', '18', 'serviceName', 'collector', null, '0'), ('137', '0', '0', '18', 'scope', 'template', null, '0'), ('138', '0', '0', '18', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":90},{\"name\":\"N\",\"value\":20}]}]', null, '0'), ('147', '0', '0', '20', 'name', 'Iftop', null, '0'), ('148', '0', '0', '20', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/iftop.conf', null, '0'), ('149', '0', '0', '20', 'lastModifiedBy', 'nobody', null, '0'), ('150', '0', '0', '20', 'configVersion', '0', null, '0'), ('151', '0', '0', '20', 'serviceVersion', '0', null, '0'), ('152', '0', '0', '20', 'serviceName', 'collector', null, '0'), ('153', '0', '0', '20', 'scope', 'template', null, '0'), ('154', '0', '0', '20', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('155', '0', '0', '21', 'name', 'Iostat', null, '0'), ('156', '0', '0', '21', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/iostat.conf', null, '0'), ('157', '0', '0', '21', 'lastModifiedBy', 'nobody', null, '0'), ('158', '0', '0', '21', 'configVersion', '0', null, '0'), ('159', '0', '0', '21', 'serviceVersion', '0', null, '0'), ('160', '0', '0', '21', 'serviceName', 'collector', null, '0'), ('161', '0', '0', '21', 'scope', 'template', null, '0'), ('162', '0', '0', '21', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":60}]}]', null, '0'), ('163', '0', '0', '22', 'name', 'Iostats', null, '0'), ('164', '0', '0', '22', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/iostats.conf', null, '0'), ('165', '0', '0', '22', 'lastModifiedBy', 'nobody', null, '0'), ('166', '0', '0', '22', 'configVersion', '0', null, '0'), ('167', '0', '0', '22', 'serviceVersion', '0', null, '0'), ('168', '0', '0', '22', 'serviceName', 'collector', null, '0'), ('169', '0', '0', '22', 'scope', 'template', null, '0'), ('170', '0', '0', '22', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('171', '0', '0', '23', 'name', 'Kafka', null, '0'), ('172', '0', '0', '23', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/kafka.conf', null, '0'), ('173', '0', '0', '23', 'lastModifiedBy', 'nobody', null, '0'), ('174', '0', '0', '23', 'configVersion', '0', null, '0'), ('175', '0', '0', '23', 'serviceVersion', '0', null, '0'), ('176', '0', '0', '23', 'serviceName', 'collector', null, '0'), ('177', '0', '0', '23', 'scope', 'template', null, '0'), ('178', '0', '0', '23', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"java_home\",\"value\":\"\"},{\"name\":\"process\",\"value\":\"kafka_*\"},{\"name\":\"port\",\"value\":8778}]}]', null, '0'), ('179', '0', '0', '24', 'name', 'Kafka_consumers', null, '0'), ('180', '0', '0', '24', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/kafka_consumers.conf', null, '0'), ('181', '0', '0', '24', 'lastModifiedBy', 'nobody', null, '0'), ('182', '0', '0', '24', 'configVersion', '0', null, '0'), ('183', '0', '0', '24', 'serviceVersion', '0', null, '0'), ('184', '0', '0', '24', 'serviceName', 'collector', null, '0'), ('185', '0', '0', '24', 'scope', 'template', null, '0'), ('186', '0', '0', '24', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"process_names\",\"value\":[\"ConsumerLoop:7777\",\"ConsumerLoop2:7778\"]}]}]', null, '0'), ('187', '0', '0', '25', 'name', 'Map_reduce', null, '0'), ('188', '0', '0', '25', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/map_reduce.conf', null, '0'), ('189', '0', '0', '25', 'lastModifiedBy', 'nobody', null, '0'), ('190', '0', '0', '25', 'configVersion', '0', null, '0'), ('191', '0', '0', '25', 'serviceVersion', '0', null, '0'), ('192', '0', '0', '25', 'serviceName', 'collector', null, '0'), ('193', '0', '0', '25', 'scope', 'template', null, '0'), ('194', '0', '0', '25', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":8088}]}]', null, '0'), ('195', '0', '0', '26', 'name', 'Mongo3', null, '0'), ('196', '0', '0', '26', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/mongo3.conf', null, '0'), ('197', '0', '0', '26', 'lastModifiedBy', 'nobody', null, '0'), ('198', '0', '0', '26', 'configVersion', '0', null, '0'), ('199', '0', '0', '26', 'serviceVersion', '0', null, '0'), ('200', '0', '0', '26', 'serviceName', 'collector', null, '0'), ('201', '0', '0', '26', 'scope', 'template', null, '0'), ('202', '0', '0', '26', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"db\",\"value\":[]},{\"name\":\"config\",\"value\":[\"localhost:27017\"]},{\"name\":\"mongos\",\"value\":[]},{\"name\":\"replica\",\"value\":[]},{\"name\":\"username\",\"value\":\"\"},{\"name\":\"password\",\"value\":\"\"}]}]', null, '0'), ('203', '0', '0', '27', 'name', 'Mysql', null, '0'), ('204', '0', '0', '27', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/mysql.conf', null, '0'), ('205', '0', '0', '27', 'lastModifiedBy', 'nobody', null, '0'), ('206', '0', '0', '27', 'configVersion', '0', null, '0'), ('207', '0', '0', '27', 'serviceVersion', '0', null, '0'), ('208', '0', '0', '27', 'serviceName', 'collector', null, '0'), ('209', '0', '0', '27', 'scope', 'template', null, '0'), ('210', '0', '0', '27', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":3306},{\"name\":\"user\",\"value\":\"\"},{\"name\":\"pass\",\"value\":\"\"}]}]', null, '0'), ('211', '0', '0', '28', 'name', 'Netstat', null, '0'), ('212', '0', '0', '28', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/netstat.conf', null, '0'), ('213', '0', '0', '28', 'lastModifiedBy', 'nobody', null, '0'), ('214', '0', '0', '28', 'configVersion', '0', null, '0'), ('215', '0', '0', '28', 'serviceVersion', '0', null, '0'), ('216', '0', '0', '28', 'serviceName', 'collector', null, '0'), ('217', '0', '0', '28', 'scope', 'template', null, '0'), ('218', '0', '0', '28', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('219', '0', '0', '29', 'name', 'Nginx', null, '0'), ('220', '0', '0', '29', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/nginx.conf', null, '0'), ('221', '0', '0', '29', 'lastModifiedBy', 'nobody', null, '0'), ('222', '0', '0', '29', 'configVersion', '0', null, '0'), ('223', '0', '0', '29', 'serviceVersion', '0', null, '0'), ('224', '0', '0', '29', 'serviceName', 'collector', null, '0'), ('225', '0', '0', '29', 'scope', 'template', null, '0'), ('226', '0', '0', '29', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":80},{\"name\":\"is_enable_https\",\"value\":false},{\"name\":\"uri\",\"value\":\"/nginx_status\"}]}]', null, '0'), ('227', '0', '0', '30', 'name', 'Ntp', null, '0'), ('228', '0', '0', '30', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/ntp.conf', null, '0'), ('229', '0', '0', '30', 'lastModifiedBy', 'nobody', null, '0'), ('230', '0', '0', '30', 'configVersion', '0', null, '0'), ('231', '0', '0', '30', 'serviceVersion', '0', null, '0'), ('232', '0', '0', '30', 'serviceName', 'collector', null, '0'), ('233', '0', '0', '30', 'scope', 'template', null, '0'), ('234', '0', '0', '30', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"127.0.0.1\"},{\"name\":\"timeout\",\"value\":1}]}]', null, '0'), ('235', '0', '0', '31', 'name', 'Opentsdb', null, '0'), ('236', '0', '0', '31', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/opentsdb.conf', null, '0'), ('237', '0', '0', '31', 'lastModifiedBy', 'nobody', null, '0'), ('238', '0', '0', '31', 'configVersion', '0', null, '0'), ('239', '0', '0', '31', 'serviceVersion', '0', null, '0'), ('240', '0', '0', '31', 'serviceName', 'collector', null, '0'), ('241', '0', '0', '31', 'scope', 'template', null, '0'), ('242', '0', '0', '31', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('243', '0', '0', '32', 'name', 'Oracle', null, '0'), ('244', '0', '0', '32', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/oracle.conf', null, '0'), ('245', '0', '0', '32', 'lastModifiedBy', 'nobody', null, '0'), ('246', '0', '0', '32', 'configVersion', '0', null, '0'), ('247', '0', '0', '32', 'serviceVersion', '0', null, '0'), ('248', '0', '0', '32', 'serviceName', 'collector', null, '0'), ('249', '0', '0', '32', 'scope', 'template', null, '0'), ('250', '0', '0', '32', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"\"},{\"name\":\"port\",\"value\":0},{\"name\":\"username\",\"value\":\"\"},{\"name\":\"password\",\"value\":\"\"},{\"name\":\"database\",\"value\":\"\"}]},{\"name\":\"sql\",\"props\":[{\"name\":\"active|val\",\"value\":\"select to_char(case when inst_cnt > 0 then 1 else 0 end, \'FM99999999999999990\') retvalue from (select count(*) inst_cnt from v$instance where status = \'OPEN\' and logins = \'ALLOWED\' and database_status = \'ACTIVE\')\"},{\"name\":\"rcachehit|val\",\"value\":\"SELECT to_char((1 - (phy.value - lob.value - dir.value) / ses.value) * 100, \'FM99999990.9999\') retvalue FROM v$sysstat ses, v$sysstat lob, v$sysstat dir, v$sysstat phy WHERE ses.name = \'session logical reads\' AND dir.name = \'physical reads direct\' AND lob.name = \'physical reads direct (lob)\' AND phy.name = \'physical reads\'\"},{\"name\":\"dsksortratio|val\",\"value\":\"SELECT to_char(d.value/(d.value + m.value)*100, \'FM99999990.9999\') retvalue FROM  v$sysstat m, v$sysstat d WHERE m.name = \'sorts (memory)\' AND d.name = \'sorts (disk)\'\"},{\"name\":\"activeusercount|val\",\"value\":\"select to_char(count(*)-1, \'FM99999999999999990\') retvalue from v$session where username is not null and status=\'ACTIVE\'\"},{\"name\":\"dbsize|val\",\"value\":\"SELECT to_char(sum(  NVL(a.bytes - NVL(f.bytes, 0), 0)), \'FM99999999999999990\') retvalue FROM sys.dba_tablespaces d, (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) a, (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+) AND NOT (d.extent_management like \'LOCAL\' AND d.contents like \'TEMPORARY\')\"},{\"name\":\"dbfilesize|val\",\"value\":\"select to_char(sum(bytes), \'FM99999999999999990\') retvalue from dba_data_files\"},{\"name\":\"uptime|val\",\"value\":\"select to_char((sysdate-startup_time)*86400, \'FM99999999999999990\') retvalue from v$instance\"},{\"name\":\"commits|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'user commits\'\"},{\"name\":\"rollbacks|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'user rollbacks\'\"},{\"name\":\"deadlocks|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'enqueue deadlocks\'\"},{\"name\":\"redowrites|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'redo writes\'\"},{\"name\":\"tblscans|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'table scans (long tables)\'\"},{\"name\":\"tblrowsscans|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'table scan rows gotten\'\"},{\"name\":\"indexffs|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'index fast full scans (full)\'\"},{\"name\":\"hardparseratio|val\",\"value\":\"SELECT to_char(h.value/t.value*100,\'FM99999990.9999\') retvalue FROM  v$sysstat h, v$sysstat t WHERE h.name = \'parse count (hard)\' AND t.name = \'parse count (total)\'\"},{\"name\":\"netsent|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'bytes sent via SQL*Net to client\'\"},{\"name\":\"netresv|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'bytes received via SQL*Net from client\'\"},{\"name\":\"netroundtrips|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'SQL*Net roundtrips to/from client\'\"},{\"name\":\"logonscurrent|val\",\"value\":\"select to_char(value, \'FM99999999999999990\') retvalue from v$sysstat where name = \'logons current\'\"},{\"name\":\"lastarclog|val\",\"value\":\"select to_char(max(SEQUENCE#), \'FM99999999999999990\') retvalue from v$log where archived = \'YES\'\"},{\"name\":\"lastapplarclog|val\",\"value\":\"select to_char(max(lh.SEQUENCE#), \'FM99999999999999990\') retvalue from v$loghist lh, v$archived_log al where lh.SEQUENCE# = al.SEQUENCE# and applied=\'YES\'\"},{\"name\":\"logswcompletion|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'log file switch completion\'\"},{\"name\":\"event.freebufwaits|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'free buffer waits\'\"},{\"name\":\"event.bufbusywaits|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'buffer busy waits\'\"},{\"name\":\"event.logfilesync|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'log file sync\'\"},{\"name\":\"event.logparallelwrite|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'log file parallel write\'\"},{\"name\":\"event.enqueue|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'enqueue\'\"},{\"name\":\"event.dbseqread|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'db file sequential read\'\"},{\"name\":\"event.dbscattread|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'db file scattered read\'\"},{\"name\":\"event.dbsinglewrite|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'db file single write\'\"},{\"name\":\"event.dbparallelwrite|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'db file parallel write\'\"},{\"name\":\"event.directread|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'direct path read\'\"},{\"name\":\"event.directwrite|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'direct path write\'\"},{\"name\":\"event.latchfree|val\",\"value\":\"select to_char(time_waited, \'FM99999999999999990\') retvalue from v$system_event se, v$event_name en where se.event(+) = en.name and en.name = \'latch free\'\"},{\"name\":\"query_sessions|val\",\"value\":\"select count(*) from gv$session where username is not null and status=\'ACTIVE\'\"},{\"name\":\"query_rollbacks|val\",\"value\":\"select nvl(trunc(sum(used_ublk*4096)/1024/1024),0) from gv$transaction t,gv$session s where ses_addr = saddr\"}]},{\"name\":\"customize\",\"props\":[{\"name\":\"slow.query|val|elapsed_time|cmd\",\"value\":\"select * from (select disk_reads, elapsed_time, sql_text from v$sqlarea order by elapsed_time desc) where rownum< 3\"}]}]', null, '0'), ('251', '0', '0', '33', 'name', 'Play_framework', null, '0'), ('252', '0', '0', '33', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/play_framework.conf', null, '0'), ('253', '0', '0', '33', 'lastModifiedBy', 'nobody', null, '0'), ('254', '0', '0', '33', 'configVersion', '0', null, '0'), ('255', '0', '0', '33', 'serviceVersion', '0', null, '0'), ('256', '0', '0', '33', 'serviceName', 'collector', null, '0'), ('257', '0', '0', '33', 'scope', 'template', null, '0'), ('258', '0', '0', '33', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"process_names\",\"value\":[{\"process\":\"sbt-launch.jar\",\"name\":\"play_framework\",\"port\":7778}]}]}]', null, '0'), ('259', '0', '0', '34', 'name', 'Postgresql', null, '0'), ('260', '0', '0', '34', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/postgresql.conf', null, '0'), ('261', '0', '0', '34', 'lastModifiedBy', 'nobody', null, '0'), ('262', '0', '0', '34', 'configVersion', '0', null, '0'), ('263', '0', '0', '34', 'serviceVersion', '0', null, '0'), ('264', '0', '0', '34', 'serviceName', 'collector', null, '0'), ('265', '0', '0', '34', 'scope', 'template', null, '0'), ('266', '0', '0', '34', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"user\",\"value\":\"\"},{\"name\":\"password\",\"value\":\"\"}]}]', null, '0'), ('275', '0', '0', '36', 'name', 'Procstats', null, '0'), ('276', '0', '0', '36', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/procstats.conf', null, '0'), ('277', '0', '0', '36', 'lastModifiedBy', 'nobody', null, '0'), ('278', '0', '0', '36', 'configVersion', '0', null, '0'), ('279', '0', '0', '36', 'serviceVersion', '0', null, '0'), ('280', '0', '0', '36', 'serviceName', 'collector', null, '0'), ('281', '0', '0', '36', 'scope', 'template', null, '0'), ('282', '0', '0', '36', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('283', '0', '0', '37', 'name', 'Rabbit_mq', null, '0'), ('284', '0', '0', '37', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/rabbit_mq.conf', null, '0'), ('285', '0', '0', '37', 'lastModifiedBy', 'nobody', null, '0'), ('286', '0', '0', '37', 'configVersion', '0', null, '0'), ('287', '0', '0', '37', 'serviceVersion', '0', null, '0'), ('288', '0', '0', '37', 'serviceName', 'collector', null, '0'), ('289', '0', '0', '37', 'scope', 'template', null, '0'), ('290', '0', '0', '37', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"rabbitmq_api_url\",\"value\":\"http://localhost:15672/api/\"},{\"name\":\"rabbitmq_user\",\"value\":\"guest\"},{\"name\":\"rabbitmq_pass\",\"value\":\"guest\"}]}]', null, '0'), ('291', '0', '0', '38', 'name', 'Redisdb', null, '0'), ('292', '0', '0', '38', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/redisdb.conf', null, '0'), ('293', '0', '0', '38', 'lastModifiedBy', 'nobody', null, '0'), ('294', '0', '0', '38', 'configVersion', '0', null, '0'), ('295', '0', '0', '38', 'serviceVersion', '0', null, '0'), ('296', '0', '0', '38', 'serviceName', 'collector', null, '0'), ('297', '0', '0', '38', 'scope', 'template', null, '0'), ('298', '0', '0', '38', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"127.0.0.1\"},{\"name\":\"port\",\"value\":[6379]},{\"name\":\"slowloglen\",\"value\":2}]}]', null, '0'), ('299', '0', '0', '39', 'name', 'Response_time', null, '0'), ('300', '0', '0', '39', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/response_time.conf', null, '0'), ('301', '0', '0', '39', 'lastModifiedBy', 'nobody', null, '0'), ('302', '0', '0', '39', 'configVersion', '0', null, '0'), ('303', '0', '0', '39', 'serviceVersion', '0', null, '0'), ('304', '0', '0', '39', 'serviceName', 'collector', null, '0'), ('305', '0', '0', '39', 'scope', 'template', null, '0'), ('306', '0', '0', '39', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"urls\",\"value\":{\"cloudwiz\":{\"url\":\"http://app.cloudwiz.cn\",\"timeout_sec\":30}}}]}]', null, '0'), ('307', '0', '0', '40', 'name', 'Services_startup', null, '0'), ('308', '0', '0', '40', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/services_startup.conf', null, '0'), ('309', '0', '0', '40', 'lastModifiedBy', 'nobody', null, '0'), ('310', '0', '0', '40', 'configVersion', '0', null, '0'), ('311', '0', '0', '40', 'serviceVersion', '0', null, '0'), ('312', '0', '0', '40', 'serviceName', 'collector', null, '0'), ('313', '0', '0', '40', 'scope', 'template', null, '0'), ('314', '0', '0', '40', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"services\",\"value\":[\"org.apache.hadoop.hbase.regionserver.HRegionServer\",\"org.apache.hadoop.hdfs.server.namenode.NameNode\",\"org.apache.hadoop.hbase.master.HMaster --backup\",\"com.cloudmon.alert.daemon.AlertService\",\"org.apache.hadoop.hdfs.server.datanode.DataNode\",\"net.opentsdb.tools.TSDMain\",\"org.apache.zookeeper.server.quorum.QuorumPeerMain\",\"org.apache.hadoop.hbase.master.HMaster\",\"/usr/sbin/mysqld\",\"grafana-server\",\"/opt/Rserve/RserveCmd.sh\",\"<:agent_root:>/cloudwiz-agent/agent/runner.py\"]}]}]', null, '0'), ('323', '0', '0', '42', 'name', 'Spark', null, '0'), ('324', '0', '0', '42', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/spark.conf', null, '0'), ('325', '0', '0', '42', 'lastModifiedBy', 'nobody', null, '0'), ('326', '0', '0', '42', 'configVersion', '0', null, '0'), ('327', '0', '0', '42', 'serviceVersion', '0', null, '0'), ('328', '0', '0', '42', 'serviceName', 'collector', null, '0'), ('329', '0', '0', '42', 'scope', 'template', null, '0'), ('330', '0', '0', '42', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"spark_host\",\"value\":\"localhost\"},{\"name\":\"spark_port\",\"value\":8080}]}]', null, '0'), ('331', '0', '0', '43', 'name', 'Ssdb_state', null, '0'), ('332', '0', '0', '43', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/ssdb_state.conf', null, '0'), ('333', '0', '0', '43', 'lastModifiedBy', 'nobody', null, '0'), ('334', '0', '0', '43', 'configVersion', '0', null, '0'), ('335', '0', '0', '43', 'serviceVersion', '0', null, '0'), ('336', '0', '0', '43', 'serviceName', 'collector', null, '0'), ('337', '0', '0', '43', 'scope', 'template', null, '0'), ('338', '0', '0', '43', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":8888}]}]', null, '0'), ('339', '0', '0', '44', 'name', 'Storm', null, '0'), ('340', '0', '0', '44', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/storm.conf', null, '0'), ('341', '0', '0', '44', 'lastModifiedBy', 'nobody', null, '0'), ('342', '0', '0', '44', 'configVersion', '0', null, '0'), ('343', '0', '0', '44', 'serviceVersion', '0', null, '0'), ('344', '0', '0', '44', 'serviceName', 'collector', null, '0'), ('345', '0', '0', '44', 'scope', 'template', null, '0'), ('346', '0', '0', '44', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":8080}]}]', null, '0'), ('347', '0', '0', '45', 'name', 'Summary', null, '0'), ('348', '0', '0', '45', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/summary.conf', null, '0'), ('349', '0', '0', '45', 'lastModifiedBy', 'nobody', null, '0'), ('350', '0', '0', '45', 'configVersion', '0', null, '0'), ('351', '0', '0', '45', 'serviceVersion', '0', null, '0'), ('352', '0', '0', '45', 'serviceName', 'collector', null, '0'), ('353', '0', '0', '45', 'scope', 'template', null, '0'), ('354', '0', '0', '45', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30}]}]', null, '0'), ('355', '0', '0', '46', 'name', 'Tomcat', null, '0'), ('356', '0', '0', '46', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/tomcat.conf', null, '0'), ('357', '0', '0', '46', 'lastModifiedBy', 'nobody', null, '0'), ('358', '0', '0', '46', 'configVersion', '0', null, '0'), ('359', '0', '0', '46', 'serviceVersion', '0', null, '0'), ('360', '0', '0', '46', 'serviceName', 'collector', null, '0'), ('361', '0', '0', '46', 'scope', 'template', null, '0'), ('362', '0', '0', '46', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60},{\"name\":\"protocol\",\"value\":\"http\"},{\"name\":\"ports\",\"value\":[8080,8081]},{\"name\":\"tomcat_version\",\"value\":7}]}]', null, '0'), ('371', '0', '0', '48', 'name', 'Weblogic', null, '0'), ('372', '0', '0', '48', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/weblogic.conf', null, '0'), ('373', '0', '0', '48', 'lastModifiedBy', 'nobody', null, '0'), ('374', '0', '0', '48', 'configVersion', '0', null, '0'), ('375', '0', '0', '48', 'serviceVersion', '0', null, '0'), ('376', '0', '0', '48', 'serviceName', 'collector', null, '0'), ('377', '0', '0', '48', 'scope', 'template', null, '0'), ('378', '0', '0', '48', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"process_names\",\"value\":[{\"process\":\"-Dweblogic.Name=AdminServer\",\"name\":\"AdminSever\",\"port\":7001},{\"process\":\"-Dweblogic.Name=Server-0\",\"name\":\"Server-0\",\"port\":7002}]}]}]', null, '0'), ('379', '0', '0', '49', 'name', 'Win32_top_n', null, '0'), ('380', '0', '0', '49', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/win32_top_n.conf', null, '0'), ('381', '0', '0', '49', 'lastModifiedBy', 'nobody', null, '0'), ('382', '0', '0', '49', 'configVersion', '0', null, '0'), ('383', '0', '0', '49', 'serviceVersion', '0', null, '0'), ('384', '0', '0', '49', 'serviceName', 'collector', null, '0'), ('385', '0', '0', '49', 'scope', 'template', null, '0'), ('386', '0', '0', '49', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":60}]}]', null, '0'), ('387', '0', '0', '50', 'name', 'Yarn', null, '0'), ('388', '0', '0', '50', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/yarn.conf', null, '0'), ('389', '0', '0', '50', 'lastModifiedBy', 'nobody', null, '0'), ('390', '0', '0', '50', 'configVersion', '0', null, '0'), ('391', '0', '0', '50', 'serviceVersion', '0', null, '0'), ('392', '0', '0', '50', 'serviceName', 'collector', null, '0'), ('393', '0', '0', '50', 'scope', 'template', null, '0'), ('394', '0', '0', '50', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":8088}]}]', null, '0'), ('395', '0', '0', '51', 'name', 'Zookeeper', null, '0'), ('396', '0', '0', '51', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/zookeeper.conf', null, '0'), ('397', '0', '0', '51', 'lastModifiedBy', 'nobody', null, '0'), ('398', '0', '0', '51', 'configVersion', '0', null, '0'), ('399', '0', '0', '51', 'serviceVersion', '0', null, '0'), ('400', '0', '0', '51', 'serviceName', 'collector', null, '0'), ('401', '0', '0', '51', 'scope', 'template', null, '0'), ('402', '0', '0', '51', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"user\",\"value\":\"root\"},{\"name\":\"SCAN_INTERVAL\",\"value\":600}]}]', null, '0'), ('403', '0', '0', '52', 'name', 'Manual_script', null, '0'), ('404', '0', '0', '52', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/manual_script.conf', null, '0'), ('405', '0', '0', '52', 'lastModifiedBy', 'nobody', null, '0'), ('406', '0', '0', '52', 'configVersion', '0', null, '0'), ('407', '0', '0', '52', 'serviceVersion', '0', null, '0'), ('408', '0', '0', '52', 'serviceName', 'collector', null, '0'), ('409', '0', '0', '52', 'scope', 'template', null, '0'), ('410', '0', '0', '52', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"command\",\"value\":[]}]}]', null, '0'), ('411', '0', '0', '53', 'name', 'Cloudwiz', null, '0'), ('412', '0', '0', '53', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/cloudwiz.conf', null, '0'), ('413', '0', '0', '53', 'lastModifiedBy', 'nobody', null, '0'), ('414', '0', '0', '53', 'configVersion', '0', null, '0'), ('415', '0', '0', '53', 'serviceVersion', '0', null, '0'), ('416', '0', '0', '53', 'serviceName', 'collector', null, '0'), ('417', '0', '0', '53', 'scope', 'template', null, '0'), ('418', '0', '0', '53', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":true},{\"name\":\"interval\",\"value\":30},{\"name\":\"process\",\"value\":[\"collector:<:agent_root:>/cloudwiz-agent/agent/runner.py\", \"filebeat:<:agent_root:>/cloudwiz-agent/filebeat/filebeat -c\", \"supervisord:<:agent_root:>/cloudwiz-agent/altenv/bin/supervisord\", \"uagent:<:agent_root:>/cloudwiz-agent/uagent/daemon.py\"]}]}]', null, '0'), ('427', '0', '0', '55', 'name', 'Apache', null, '0'), ('428', '0', '0', '55', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/apache.conf', null, '0'), ('429', '0', '0', '55', 'lastModifiedBy', 'nobody', null, '0'), ('430', '0', '0', '55', 'configVersion', '0', null, '0'), ('431', '0', '0', '55', 'serviceVersion', '0', null, '0'), ('432', '0', '0', '55', 'serviceName', 'collector', null, '0'), ('433', '0', '0', '55', 'scope', 'template', null, '0'), ('434', '0', '0', '55', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":30},{\"name\":\"disable_ssl_validation\",\"value\":false},{\"name\":\"apache_url\",\"value\":\"http://127.0.0.1/server-status?auto\"},{\"name\":\"connect_timeout\",\"value\":5},{\"name\":\"receive_timeout\",\"value\":15}]}]', null, '0'), ('435', '0', '0', '56', 'hosts', '[]', null, '0'), ('436', '0', '0', '56', 'logServiceName', 'collector', null, '0'), ('437', '0', '0', '56', 'logType', 'collector', null, '0'), ('438', '0', '0', '56', 'logTypes', '[\"collector\"]', null, '0'), ('439', '0', '0', '56', 'paths', '[\"<:agent_root:>/cloudwiz-agent/altenv/var/log/collector.log\",\"<:agent_root:>/cloudwiz-agent/altenv/var/log/uagent.log\"]', null, '0'), ('440', '0', '0', '56', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{DATA} %{LOGLEVEL:loglevel}: \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-07 07:41:03,814 agent_main[19860:139875429213952]:787 INFO: put request payload 1003\"}]', null, '0'), ('441', '0', '0', '56', 'multiline', 'true', null, '0'), ('442', '0', '0', '56', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('443', '0', '0', '56', 'multiline.negate', 'true', null, '0'), ('444', '0', '0', '56', 'multiline.match', 'after', null, '0'), ('445', '0', '0', '56', 'ruleName', 'cloudwiz.collector', null, '0'), ('446', '0', '0', '56', 'serviceName', 'log-processor', null, '0'), ('447', '0', '0', '57', 'hosts', '[]', null, '0'), ('448', '0', '0', '57', 'logServiceName', 'elasticsearch', null, '0'), ('449', '0', '0', '57', 'logType', 'elasticsearch', null, '0'), ('450', '0', '0', '57', 'logTypes', '[\"elasticsearch\"]', null, '0'), ('451', '0', '0', '57', 'paths', '[]', null, '0'), ('452', '0', '0', '57', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^\\\\[%{TIMESTAMP_ISO8601:timestamp}\\\\]\\\\[%{LOGLEVEL:loglevel}\",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"[2017-10-20 09:19:21,448][DEBUG][action.search            ] [DD1097] [logstash-2017.10.19][2], node[dfNWLOKiREm7wHjb4q00Aw], [P], v[3], s[STARTED], a[id=gDmu4fl2RDK91KQSZvvRRA]: Failed to execute [org.elasticsearch.action.search.SearchRequest@4dcd525] lastShard [true]\"}]', null, '0'), ('453', '0', '0', '57', 'multiline', 'true', null, '0'), ('454', '0', '0', '57', 'multiline.pattern', '^\\\\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}\\\\]', null, '0'), ('455', '0', '0', '57', 'multiline.negate', 'true', null, '0'), ('456', '0', '0', '57', 'multiline.match', 'after', null, '0'), ('457', '0', '0', '57', 'ruleName', 'elasticsearch', null, '0'), ('458', '0', '0', '57', 'serviceName', 'log-processor', null, '0'), ('459', '0', '0', '58', 'hosts', '[]', null, '0'), ('460', '0', '0', '58', 'logServiceName', 'filebeat', null, '0'), ('461', '0', '0', '58', 'logType', 'filebeat', null, '0'), ('462', '0', '0', '58', 'logTypes', '[\"filebeat\"]', null, '0'), ('463', '0', '0', '58', 'paths', '[\"<:agent_root:>/cloudwiz-agent/altenv/var/log/filebeat.log\"]', null, '0'), ('464', '0', '0', '58', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-04T04:37:17+08:00 INFO No non-zero metrics in the last 30s\"}]', null, '0'), ('465', '0', '0', '58', 'multiline', 'true', null, '0'), ('466', '0', '0', '58', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}', null, '0'), ('467', '0', '0', '58', 'multiline.negate', 'true', null, '0'), ('468', '0', '0', '58', 'multiline.match', 'after', null, '0'), ('469', '0', '0', '58', 'ruleName', 'filebeat', null, '0'), ('470', '0', '0', '58', 'serviceName', 'log-processor', null, '0'), ('471', '0', '0', '59', 'hosts', '[]', null, '0'), ('472', '0', '0', '59', 'logServiceName', 'hadoop.datanode', null, '0'), ('473', '0', '0', '59', 'logType', 'hadoop', null, '0'), ('474', '0', '0', '59', 'logTypes', '[\"hadoop\"]', null, '0'), ('475', '0', '0', '59', 'paths', '[\"/var/log/hadoop/datanode.log\"]', null, '0'), ('476', '0', '0', '59', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-07 18:29:53,191 INFO org.apache.hadoop.hdfs.server.datanode.DataNode.clienttrace: src: /10.9.121.89:50010, dest: /10.9.121.89:56184, bytes: 2031616, op: HDFS_READ, cliID: DFSClient_NONMAPREDUCE_1781450902_1, offset: 55923712, srvID: 38a934c6-e307-4b52-b758-0fa5bc268b23, blockid: BP-1126104793-127.0.0.1-1484720282771:blk_1074291161_551163, duration: 8328558\"}]', null, '0'), ('477', '0', '0', '59', 'multiline', 'true', null, '0'), ('478', '0', '0', '59', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('479', '0', '0', '59', 'multiline.negate', 'true', null, '0'), ('480', '0', '0', '59', 'multiline.match', 'after', null, '0'), ('481', '0', '0', '59', 'ruleName', 'hadoop.datanode', null, '0'), ('482', '0', '0', '59', 'serviceName', 'log-processor', null, '0'), ('483', '0', '0', '60', 'hosts', '[]', null, '0'), ('484', '0', '0', '60', 'logServiceName', 'hbase.master', null, '0'), ('485', '0', '0', '60', 'logType', 'hbase', null, '0'), ('486', '0', '0', '60', 'logTypes', '[\"hbase\"]', null, '0'), ('487', '0', '0', '60', 'paths', '[\"/var/log/hbase/master.log\"]', null, '0'), ('488', '0', '0', '60', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-07-08 14:33:22,812 INFO  [main] util.ServerCommandLine: env:HBASE_SECURITY_LOGGER=INFO,RFAS\"}]', null, '0');
INSERT INTO `cw_Attribute` VALUES ('489', '0', '0', '60', 'multiline', 'true', null, '0'), ('490', '0', '0', '60', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('491', '0', '0', '60', 'multiline.negate', 'true', null, '0'), ('492', '0', '0', '60', 'multiline.match', 'after', null, '0'), ('493', '0', '0', '60', 'ruleName', 'hbase.master', null, '0'), ('494', '0', '0', '60', 'serviceName', 'log-processor', null, '0'), ('495', '0', '0', '61', 'hosts', '[]', null, '0'), ('496', '0', '0', '61', 'logServiceName', 'kafka', null, '0'), ('497', '0', '0', '61', 'logType', 'kafka.server', null, '0'), ('498', '0', '0', '61', 'logTypes', '[\"kafka.server\"]', null, '0'), ('499', '0', '0', '61', 'paths', '[\"/var/log/kafka/server.log\"]', null, '0'), ('500', '0', '0', '61', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^\\\\[%{TIMESTAMP_ISO8601:timestamp}\\\\] %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"[2017-11-07 19:10:51,195] INFO [Group Metadata Manager on Broker 0]: Removed 0 expired offsets in 0 milliseconds. (kafka.coordinator.group.GroupMetadataManager)\"}]', null, '0'), ('501', '0', '0', '61', 'multiline', 'true', null, '0'), ('502', '0', '0', '61', 'multiline.pattern', '^\\\\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}\\\\] ', null, '0'), ('503', '0', '0', '61', 'multiline.negate', 'true', null, '0'), ('504', '0', '0', '61', 'multiline.match', 'after', null, '0'), ('505', '0', '0', '61', 'ruleName', 'kafka.server', null, '0'), ('506', '0', '0', '61', 'serviceName', 'log-processor', null, '0'), ('507', '0', '0', '62', 'hosts', '[]', null, '0'), ('508', '0', '0', '62', 'logServiceName', 'kibana', null, '0'), ('509', '0', '0', '62', 'logType', 'kibana', null, '0'), ('510', '0', '0', '62', 'logTypes', '[\"kibana\"]', null, '0'), ('511', '0', '0', '62', 'paths', '[\"/var/log/kibana/kibana.log\"]', null, '0'), ('512', '0', '0', '62', 'patterns', '[{\"name\":\"timestamp\",\"pattern\":\"\\\"@timestamp\\\":\\\"%{TIMESTAMP_ISO8601:timestamp}\\\"\",\"type\":\"grok\",\"isMetric\":false,\"fields\":[],\"log\":\"{\\\"type\\\":\\\"response\\\",\\\"@timestamp\\\":\\\"2017-02-23T02:54:19Z\\\",\\\"tags\\\":[],\\\"pid\\\":3208,\\\"method\\\":\\\"get\\\",\\\"statusCode\\\":404,\\\"req\\\":{\\\"url\\\":\\\"/favicon.ico\\\"}}\"}]', null, '0'), ('513', '0', '0', '62', 'multiline', 'false', null, '0'), ('514', '0', '0', '62', 'multiline.pattern', '', null, '0'), ('515', '0', '0', '62', 'multiline.negate', 'true', null, '0'), ('516', '0', '0', '62', 'multiline.match', 'after', null, '0'), ('517', '0', '0', '62', 'ruleName', 'kibana', null, '0'), ('518', '0', '0', '62', 'serviceName', 'log-processor', null, '0'), ('519', '0', '0', '63', 'hosts', '[]', null, '0'), ('520', '0', '0', '63', 'logServiceName', 'logstash', null, '0'), ('521', '0', '0', '63', 'logType', 'logstash', null, '0'), ('522', '0', '0', '63', 'logTypes', '[\"logstash\"]', null, '0'), ('523', '0', '0', '63', 'paths', '[\"/var/log/logstash/logstash.log\"]', null, '0'), ('524', '0', '0', '63', 'patterns', '[{\"name\":\"timestamp\",\"pattern\":\"timestamp=>\\\"%{TIMESTAMP_ISO8601:timestamp}\\\"\",\"type\":\"grok\",\"isMetric\":false,\"fields\":[],\"log\":\"{:timestamp=>\\\"2017-05-20T22:10:47.544000+0800\\\", :message=>\\\"Pipeline main started\\\"}\"}]', null, '0'), ('525', '0', '0', '63', 'multiline', 'false', null, '0'), ('526', '0', '0', '63', 'multiline.pattern', '', null, '0'), ('527', '0', '0', '63', 'multiline.negate', 'true', null, '0'), ('528', '0', '0', '63', 'multiline.match', 'after', null, '0'), ('529', '0', '0', '63', 'ruleName', 'logstash', null, '0'), ('530', '0', '0', '63', 'serviceName', 'log-processor', null, '0'), ('531', '0', '0', '64', 'hosts', '[]', null, '0'), ('532', '0', '0', '64', 'logServiceName', 'mysql', null, '0'), ('533', '0', '0', '64', 'logType', 'mysql', null, '0'), ('534', '0', '0', '64', 'logTypes', '[\"mysql\"]', null, '0'), ('535', '0', '0', '64', 'paths', '[\"/var/log/mysqld.log\"]', null, '0'), ('536', '0', '0', '64', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{WORD} \\\\[%{LOGLEVEL:loglevel}\\\\] \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-01-18 19:37:49 26086 [Note] InnoDB: Using Linux native AIO\"}]', null, '0'), ('537', '0', '0', '64', 'multiline', 'true', null, '0'), ('538', '0', '0', '64', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}', null, '0'), ('539', '0', '0', '64', 'multiline.negate', 'true', null, '0'), ('540', '0', '0', '64', 'multiline.match', 'after', null, '0'), ('541', '0', '0', '64', 'ruleName', 'mysql', null, '0'), ('542', '0', '0', '64', 'serviceName', 'log-processor', null, '0'), ('543', '0', '0', '65', 'hosts', '[]', null, '0'), ('544', '0', '0', '65', 'logServiceName', 'nginx', null, '0'), ('545', '0', '0', '65', 'logType', 'nginx.access', null, '0'), ('546', '0', '0', '65', 'logTypes', '[\"nginx.access\",\"nginx.error\"]', null, '0'), ('547', '0', '0', '65', 'paths', '[\"/var/log/nginx/access.log\"]', null, '0'), ('548', '0', '0', '65', 'patterns', '[{\"name\":\"client_ip\",\"pattern\":\"^%{IP:ip} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"ip\"],\"log\":\"12.34.56.78 - - [07/Nov/2017:04:24:05 +0800] \\\"POST /api/put?details HTTP/1.0\\\" 200 36 \\\"-\\\" \\\"Python-urllib/2.7\\\" 0.199 0.001\\\"\"}]', null, '0'), ('549', '0', '0', '65', 'multiline', 'false', null, '0'), ('550', '0', '0', '65', 'multiline.pattern', '', null, '0'), ('551', '0', '0', '65', 'multiline.negate', 'true', null, '0'), ('552', '0', '0', '65', 'multiline.match', 'after', null, '0'), ('553', '0', '0', '65', 'ruleName', 'nginx.access', null, '0'), ('554', '0', '0', '65', 'serviceName', 'log-processor', null, '0'), ('555', '0', '0', '66', 'hosts', '[]', null, '0'), ('556', '0', '0', '66', 'logServiceName', 'nginx', null, '0'), ('557', '0', '0', '66', 'logType', 'nginx.error', null, '0'), ('558', '0', '0', '66', 'logTypes', '[\"nginx.access\",\"nginx.error\"]', null, '0'), ('559', '0', '0', '66', 'paths', '[\"/var/log/nginx/error.log\"]', null, '0'), ('560', '0', '0', '66', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^(?<timestamp>%{YEAR}/%{MONTHNUM}/%{MONTHDAY} %{HOUR}:%{MINUTE}:%{SECOND}) \\\\[%{LOGLEVEL:loglevel}\\\\] \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017/11/07 04:28:04 [error] 11011#11011: *1449804945 connect() failed (111: Connection refused) while connecting to upstream, client: 124.202.184.186, server: 0.0.0.0:9907, upstream: \\\"10.9.163.9:9907\\\", bytes from/to client:0/0, bytes from/to upstream:0/0\"}]', null, '0'), ('561', '0', '0', '66', 'multiline', 'true', null, '0'), ('562', '0', '0', '66', 'multiline.pattern', '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} ', null, '0'), ('563', '0', '0', '66', 'multiline.negate', 'true', null, '0'), ('564', '0', '0', '66', 'multiline.match', 'after', null, '0'), ('565', '0', '0', '66', 'ruleName', 'nginx.error', null, '0'), ('566', '0', '0', '66', 'serviceName', 'log-processor', null, '0'), ('567', '0', '0', '67', 'hosts', '[]', null, '0'), ('568', '0', '0', '67', 'logServiceName', 'opentsdb', null, '0'), ('569', '0', '0', '67', 'logType', 'opentsdb', null, '0'), ('570', '0', '0', '67', 'logTypes', '[\"opentsdb\"]', null, '0'), ('571', '0', '0', '67', 'paths', '[\"/var/log/opentsdb/opentsdb.log\"]', null, '0'), ('572', '0', '0', '67', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^(?<timestamp>%{HOUR}:%{MINUTE}:%{SECOND}) %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"20:08:23.934 ERROR [UniqueId.createReverseMapping] - OMG All Unique IDs for tagv on 3 bytes are already assigned!\"}]', null, '0'), ('573', '0', '0', '67', 'multiline', 'true', null, '0'), ('574', '0', '0', '67', 'multiline.pattern', '^[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3} ', null, '0'), ('575', '0', '0', '67', 'multiline.negate', 'true', null, '0'), ('576', '0', '0', '67', 'multiline.match', 'after', null, '0'), ('577', '0', '0', '67', 'ruleName', 'opentsdb', null, '0'), ('578', '0', '0', '67', 'serviceName', 'log-processor', null, '0'), ('579', '0', '0', '68', 'hosts', '[]', null, '0'), ('580', '0', '0', '68', 'logServiceName', 'zookeeper', null, '0'), ('581', '0', '0', '68', 'logType', 'zookeeper', null, '0'), ('582', '0', '0', '68', 'logTypes', '[\"zookeeper\"]', null, '0'), ('583', '0', '0', '68', 'paths', '[\"/var/log/zookeeper/zookeeper.log\"]', null, '0'), ('584', '0', '0', '68', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{DATA} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-07 17:26:22,631 [myid:1] - INFO  [ProcessThread(sid:1 cport:-1)::PrepRequestProcessor@487] - Processed session termination for sessionid: 0x15f495f61a1\"}]', null, '0'), ('585', '0', '0', '68', 'multiline', 'true', null, '0'), ('586', '0', '0', '68', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('587', '0', '0', '68', 'multiline.negate', 'true', null, '0'), ('588', '0', '0', '68', 'multiline.match', 'after', null, '0'), ('589', '0', '0', '68', 'ruleName', 'zookeeper', null, '0'), ('590', '0', '0', '68', 'serviceName', 'log-processor', null, '0'), ('591', '0', '0', '69', 'hosts', '[]', null, '0'), ('592', '0', '0', '69', 'logServiceName', 'hadoop.namenode', null, '0'), ('593', '0', '0', '69', 'logType', 'hadoop', null, '0'), ('594', '0', '0', '69', 'logTypes', '[\"hadoop\"]', null, '0'), ('595', '0', '0', '69', 'paths', '[\"/var/log/hadoop/namenode.log\"]', null, '0'), ('596', '0', '0', '69', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-07 20:31:46,212 INFO org.apache.hadoop.hdfs.StateChange: DIR* completeFile: /hbase/data/default/tsdb/24ccb3a308f35a7d11ad8061ade330c2/.tmp/dbe71868d90348cd882960a749a673c2 is closed by DFSClient_NONMAPREDUCE_1881499531_1\"}]', null, '0'), ('597', '0', '0', '69', 'multiline', 'true', null, '0'), ('598', '0', '0', '69', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('599', '0', '0', '69', 'multiline.negate', 'true', null, '0'), ('600', '0', '0', '69', 'multiline.match', 'after', null, '0'), ('601', '0', '0', '69', 'ruleName', 'hadoop.namenode', null, '0'), ('602', '0', '0', '69', 'serviceName', 'log-processor', null, '0'), ('603', '0', '0', '70', 'hosts', '[]', null, '0'), ('604', '0', '0', '70', 'logServiceName', 'hbase.regionserver', null, '0'), ('605', '0', '0', '70', 'logType', 'hbase', null, '0'), ('606', '0', '0', '70', 'logTypes', '[\"hbase\"]', null, '0'), ('607', '0', '0', '70', 'paths', '[\"/var/log/hbase/regionserver.log\"]', null, '0'), ('608', '0', '0', '70', 'patterns', '[{\"name\":\"log_level\",\"pattern\":\"^%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:loglevel} \",\"type\":\"grok\",\"isMetric\":false,\"fields\":[\"loglevel\"],\"log\":\"2017-11-14 16:30:26,942 INFO  [regionserver/10-9-187-78/10.9.187.78:16020-shortCompactions-1510478528209] compress.CodecPool: Got brand-new decompressor [.gz]\"}]', null, '0'), ('609', '0', '0', '70', 'multiline', 'true', null, '0'), ('610', '0', '0', '70', 'multiline.pattern', '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} ', null, '0'), ('611', '0', '0', '70', 'multiline.negate', 'true', null, '0'), ('612', '0', '0', '70', 'multiline.match', 'after', null, '0'), ('613', '0', '0', '70', 'ruleName', 'hbase.regionserver', null, '0'), ('614', '0', '0', '70', 'serviceName', 'log-processor', null, '0'), ('621', '0', '0', '72', 'name', 'Aws_cloudwatch_stats', null, '0'), ('622', '0', '0', '72', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/aws_cloudwatch_stats.conf', null, '0'), ('623', '0', '0', '72', 'lastModifiedBy', 'nobody', null, '0'), ('624', '0', '0', '72', 'configVersion', '0', null, '0'), ('625', '0', '0', '72', 'serviceVersion', '0', null, '0'), ('626', '0', '0', '72', 'serviceName', 'collector', null, '0'), ('627', '0', '0', '72', 'scope', 'template', null, '0'), ('628', '0', '0', '72', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":300}]}]', null, '0'), ('629', '0', '0', '73', 'name', 'Jvm', null, '0'), ('630', '0', '0', '73', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/jvm.conf', null, '0'), ('631', '0', '0', '73', 'lastModifiedBy', 'nobody', null, '0'), ('632', '0', '0', '73', 'configVersion', '0', null, '0'), ('633', '0', '0', '73', 'serviceVersion', '0', null, '0'), ('634', '0', '0', '73', 'serviceName', 'collector', null, '0'), ('635', '0', '0', '73', 'scope', 'template', null, '0'), ('636', '0', '0', '73', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":300},{\"name\":\"processes\",\"value\":[\"{\\\"name\\\":\\\"regionserver\\\",\\\"command\\\":\\\"HRegionServer\\\",\\\"threshold\\\":5}\"]},{\"name\":\"java_home\",\"value\":\"/usr/lib/jvm/jre\"},{\"name\":\"log_file\",\"value\":\"<:agent_root:>/cloudwiz-agent/altenv/var/log/jstack.log\"}]}]', null, '0'), ('637', '0', '0', '74', 'name', 'Hbase_regionserver_info', null, '0'), ('638', '0', '0', '74', 'fullPath', '<:agent_root:>/cloudwiz-agent/agent/collectors/conf/hbase_regionserver_info.conf', null, '0'), ('639', '0', '0', '74', 'lastModifiedBy', 'nobody', null, '0'), ('640', '0', '0', '74', 'configVersion', '0', null, '0'), ('641', '0', '0', '74', 'serviceVersion', '0', null, '0'), ('642', '0', '0', '74', 'serviceName', 'collector', null, '0'), ('643', '0', '0', '74', 'scope', 'template', null, '0'), ('644', '0', '0', '74', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":300},{\"name\":\"hbase_bin\",\"value\":\"/opt/hbase/bin/hbase\"},{\"name\":\"master_status_url\",\"value\":[\"http://localhost:16010/master-status\"]},{\"name\":\"state_file\",\"value\":\"/tmp/hbase_regionserver_info.txt\"}]}]', null, '0'), ('645', '0', '0', '75', 'name', 'cloudwiz.jstack', null, '0'), ('646', '0', '0', '75', 'version', '0', null, '0'), ('647', '0', '0', '75', 'serviceVersion', '0', null, '0'), ('648', '0', '0', '75', 'serviceName', 'filebeat', null, '0'), ('649', '0', '0', '75', 'scope', 'template', null, '0'), ('650', '0', '0', '75', 'content', '{\"id\":0,\"orgId\":0,\"sysId\":0,\"name\":\"filebeat\",\"version\":0,\"lastModified\":0,\"lastModifiedBy\":\"nobody\",\"type\":\"template\",\"fullPath\":\"<:agent_root:>/cloudwiz-agent/filebeat/filebeat.yml\",\"serviceId\":0,\"serviceName\":\"filebeat\",\"serviceVersion\":\"\",\"hostId\":0,\"hostName\":\"\",\"properties\":{\"filebeat.prospectors\":[{\"input_type\":\"log\",\"paths\":[\"<:agent_root:>/cloudwiz-agent/altenv/var/log/jstack.log*\"],\"document_type\":\"jstack\",\"fields.orgid\":1,\"fields.sysid\":1,\"fields.token\":\"<:token:>\",\"fields_under_root\":true,\"close_*\":true,\"tail_files\":true,\"multiline.pattern\":\"\"}],\"output.logstash\":{\"hosts\":[\"<:agent_ip:>:5044\"],\"ssl.enabled\":false,\"ssl.certificate_authorities\":[\"<:agent_root:>/cloudwiz-agent/filebeat/ca.crt\"],\"ssl.certificate\":\"<:agent_root:>/cloudwiz-agent/filebeat/client.crt\",\"ssl.key\":\"<:agent_root:>/cloudwiz-agent/filebeat/client.key\",\"ssl.supported_protocols\":\"TLSv1.2\"},\"logging\":{\"level\":\"info\",\"to_files\":true,\"to_syslog\":false,\"files\":{\"path\":\"<:agent_root:>/cloudwiz-agent/altenv/var/log\",\"name\":\"filebeat.log\",\"keepfiles\":7}}}}', null, '0'), ('651', '0', '0', '76', 'name', 'Kubernetes', null, '0'), ('652', '0', '0', '76', 'version', '0', null, '0'), ('653', '0', '0', '76', 'serviceVersion', '0', null, '0'), ('654', '0', '0', '76', 'serviceName', 'collector', null, '0'), ('655', '0', '0', '76', 'scope', 'template', null, '0'), ('656', '0', '0', '76', 'content', '[{\"name\":\"base\",\"props\":[{\"name\":\"enabled\",\"value\":false},{\"name\":\"interval\",\"value\":120}]},{\"name\":\"cadvisor\",\"props\":[{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":10255},{\"name\":\"protocol\",\"value\":\"http\"}]},{\"name\":\"coredns\",\"props\":[{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":9153},{\"name\":\"protocol\",\"value\":\"http\"}]},{\"name\":\"kube-state\",\"props\":[{\"name\":\"host\",\"value\":\"localhost\"},{\"name\":\"port\",\"value\":8080},{\"name\":\"protocol\",\"value\":\"http\"}]}]', null, '0');
COMMIT;

-- ----------------------------
--  Table structure for `cw_CI`
-- ----------------------------
DROP TABLE IF EXISTS `cw_CI`;
CREATE TABLE `cw_CI` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) DEFAULT NULL,
  `key` varchar(512) NOT NULL,
  `type` bigint(20) NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `deletedAt` datetime DEFAULT '2000-01-01 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cw_CI_orgId_sysId_key_type_deletedAt_uindex` (`orgId`,`sysId`,`key`,`type`,`deletedAt`),
  KEY `cw_CI_orgId_sysId_type_deletedAt_index` (`orgId`,`sysId`,`type`,`deletedAt`),
  KEY `cw_CI_cw_Type_id_fk` (`type`),
  CONSTRAINT `cw_CI_cw_Type_id_fk` FOREIGN KEY (`type`) REFERENCES `cw_Meta_Type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2708 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_CI`
-- ----------------------------
BEGIN;
INSERT INTO `cw_CI` VALUES ('2', '0', '0', 'Cloudwiz_Configuration_Definition_Filebeat', '7', '2017-10-04 11:54:34', null), ('3', '0', '0', 'Cloudwiz_Configuration_Definition_Collector', '7', '2017-10-04 11:58:19', null), ('4', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Cloudmon', '7', '2017-10-04 12:04:58', null), ('5', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Cpus_pctusage', '7', '2017-10-04 12:11:13', null), ('6', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Cwagent', '7', '2017-10-04 12:14:47', null), ('8', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Docker_alauda', '7', '2017-10-04 12:25:23', null), ('9', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Dockerd', '7', '2017-10-04 12:33:16', null), ('10', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Elasticsearch', '7', '2017-10-04 12:38:25', null), ('11', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Elasticsearchstat', '7', '2017-10-04 12:42:36', null), ('12', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Flume', '7', '2017-10-04 12:46:43', null), ('13', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hadoop_data_node', '7', '2017-10-04 12:49:16', null), ('14', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hadoop_name_node', '7', '2017-10-04 12:51:14', null), ('15', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hbase_master', '7', '2017-10-04 12:52:59', null), ('16', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hbase_regionserver', '7', '2017-10-04 12:55:49', null), ('17', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hive', '7', '2017-10-04 12:58:13', null), ('18', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Host_topn', '7', '2017-10-04 13:00:02', null), ('20', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Iftop', '7', '2017-10-04 13:03:26', null), ('21', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Iostat', '7', '2017-10-04 13:05:36', null), ('22', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Iostats', '7', '2017-10-04 13:07:36', null), ('23', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Kafka', '7', '2017-10-04 13:09:02', null), ('24', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Kafka_consumers', '7', '2017-10-04 13:13:59', null), ('25', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Map_reduce', '7', '2017-10-04 13:17:26', null), ('26', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Mongo3', '7', '2017-10-04 13:19:54', null), ('27', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Mysql', '7', '2017-10-04 13:27:24', null), ('28', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Netstat', '7', '2017-10-04 13:29:46', null), ('29', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Nginx', '7', '2017-10-04 13:31:43', null), ('30', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Ntp', '7', '2017-10-04 13:34:35', null), ('31', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Opentsdb', '7', '2017-10-04 13:36:35', null), ('32', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Oracle', '7', '2017-10-04 13:38:51', null), ('33', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Play_framework', '7', '2017-10-04 13:54:13', null), ('34', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Postgresql', '7', '2017-10-04 13:58:09', null), ('36', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Procstats', '7', '2017-10-04 14:02:54', null), ('37', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Rabbit_mq', '7', '2017-10-04 14:04:40', null), ('38', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Redisdb', '7', '2017-10-04 14:08:01', null), ('39', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Response_time', '7', '2017-10-04 14:10:16', null), ('40', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Services_startup', '7', '2017-10-04 14:14:42', null), ('42', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Spark', '7', '2017-10-04 14:41:46', null), ('43', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Ssdb_state', '7', '2017-10-04 14:44:05', null), ('44', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Storm', '7', '2017-10-04 14:45:43', null), ('45', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Summary', '7', '2017-10-04 14:47:29', null), ('46', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Tomcat', '7', '2017-10-04 14:48:59', null), ('48', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Weblogic', '7', '2017-10-04 14:53:25', null), ('49', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Win32_top_n', '7', '2017-10-04 14:57:30', null), ('50', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Yarn', '7', '2017-10-04 14:59:06', null), ('51', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Zookeeper', '7', '2017-10-04 15:00:56', null), ('52', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Manual_script', '7', '2017-10-23 11:07:02', null), ('53', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Cloudwiz', '7', '2017-10-23 14:24:00', null), ('55', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Apache', '7', '2017-10-23 16:01:23', null), ('56', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Collector', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('57', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Elasticsearch', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('58', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Filebeat', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('59', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Hadoop_DataNode', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('60', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Hbase_Master', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('61', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Kafka_Server', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('62', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Kibana', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('63', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Logstash', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('64', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_MySQL', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('65', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Nginx_Access', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('66', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Nginx_Error', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('67', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Opentsdb', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('68', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Zookeeper', '7', '2017-11-10 16:36:07', '2000-01-01 00:00:00'), ('69', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Hadoop_NameNode', '7', '2017-11-15 11:24:59', '2000-01-01 00:00:00'), ('70', '0', '0', 'Cloudwiz_Configuration_Template_Log_Processor_Hbase_RegionServer', '7', '2017-11-15 11:35:39', '2000-01-01 00:00:00'), ('72', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Aws_cloudwatch_stats', '7', '2017-11-16 20:40:33', '2000-01-01 00:00:00'), ('73', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Jvm', '7', '2017-11-16 20:40:33', '2000-01-01 00:00:00'), ('74', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Hbase_regionserver_info', '7', '2017-11-16 20:40:33', '2000-01-01 00:00:00'), ('75', '0', '0', 'Cloudwiz_Configuration_Template_Filebeat', '7', '2017-11-15 13:47:32', '2000-01-01 00:00:00'), ('76', '0', '0', 'Cloudwiz_Configuration_Template_Collector_Kubernetes', '7', '2017-10-23 16:01:23', '2000-01-01 00:00:00');
COMMIT;

-- ----------------------------
--  Table structure for `cw_Config_Host`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Config_Host`;
CREATE TABLE `cw_Config_Host` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `inventory` text NOT NULL,
  `remoteUser` varchar(512) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cw_Config_Host_orgId_sysId_index` (`orgId`,`sysId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_Config_ScanResult`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Config_ScanResult`;
CREATE TABLE `cw_Config_ScanResult` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `startedAt` datetime NOT NULL,
  `completedAt` datetime DEFAULT NULL,
  `trigger` tinyint(4) DEFAULT '1',
  `result` text,
  PRIMARY KEY (`id`),
  KEY `cw_Config_Scan_orgId_sysId_index` (`orgId`,`sysId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_Config_Software`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Config_Software`;
CREATE TABLE `cw_Config_Software` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `software` text NOT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cw_Config_Host_orgId_sysId_index` (`orgId`,`sysId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Config_Software`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Config_Software` VALUES ('1', '0', '0', '[{\"name\":\"iis\",\"platform\":\"windows\",\"command\":\"w3svc\",\"alias\":\"iis\",\"prefix\":\"iis\"},{\"name\":\"mysql\",\"platform\":\"linux\",\"command\":\"mysqld\",\"alias\":\"mysql\",\"prefix\":\"mysql\"},{\"name\":\"elasticsearch\",\"platform\":\"linux\",\"command\":\"org.elasticsearch.bootstrap.Elasticsearch start \",\"alias\":\"elasticsearch\",\"prefix\":\"elasticsearch\"},{\"name\":\"zookeeper\",\"platform\":\"linux\",\"command\":\"org.apache.zookeeper.server.quorum.QuorumPeerMain\",\"alias\":\"zookeeper\",\"prefix\":\"zk_\"},{\"name\":\"hadoop.datanode\",\"platform\":\"linux\",\"command\":\"org.apache.hadoop.hdfs.server.datanode.DataNode\",\"alias\":\"HadoopDatanode\",\"prefix\":\"hadoop.datanode\"},{\"name\":\"hadoop.namenode\",\"platform\":\"linux\",\"command\":\"org.apache.hadoop.hdfs.server.namenode.NameNode\",\"alias\":\"HadoopNamenode\",\"prefix\":\"hadoop.namenode\"},{\"name\":\"hbase.master\",\"platform\":\"linux\",\"command\":\"org.apache.hadoop.hbase.master.HMaster\",\"alias\":\"HbaseMaster\",\"prefix\":\"hbase.master\"},{\"name\":\"hbase.regionserver\",\"platform\":\"linux\",\"command\":\"org.apache.hadoop.hbase.regionserver.HRegionServer\",\"alias\":\"HbaseRegionserver\",\"prefix\":\"hbase.regionserver\"},{\"name\":\"opentsdb\",\"platform\":\"linux\",\"command\":\"net.opentsdb.tools.TSDMain\",\"alias\":\"opentsdb\",\"prefix\":\"tsd\"},{\"name\":\"apache\",\"platform\":\"linux\",\"command\":\"apache2 -k start\",\"alias\":\"apache\",\"prefix\":\"apache\"},{\"name\":\"kafka\",\"platform\":\"linux\",\"command\":\"kafka.Kafka\",\"alias\":\"kafka\",\"prefix\":\"kafka\"},{\"name\":\"nginx\",\"platform\":\"linux\",\"command\":\"nginx: master process\",\"alias\":\"nginx\",\"prefix\":\"nginx\"},{\"name\":\"tomcat\",\"platform\":\"linux\",\"command\":\"org.apache.catalina.startup.Bootstrap\",\"alias\":\"tomcat\",\"prefix\":\"tomcat\"},{\"name\":\"redis\",\"platform\":\"linux\",\"command\":\"redis-server\",\"alias\":\"redis\",\"prefix\":\"redis\"},{\"name\":\"postgresql\",\"platform\":\"linux\",\"command\":\"postmaster\",\"alias\":\"postgresql\",\"prefix\":\"postgresql\"},{\"name\":\"mongo3\",\"platform\":\"linux\",\"command\":\"mongod\",\"alias\":\"mongodb\",\"prefix\":\"mongo\"},{\"name\":\"ssdb\",\"platform\":\"linux\",\"command\":\"ssdb-server\",\"alias\":\"ssdb\",\"prefix\":\"ssdb\"},{\"name\":\"rabbitmq\",\"platform\":\"linux\",\"command\":\"rabbitmq-server\",\"alias\":\"rabbitmq\",\"prefix\":\"rabbitmq\"},{\"name\":\"play\",\"platform\":\"linux\",\"command\":\"sbt-launch.jar\",\"alias\":\"playframework\",\"prefix\":\"play\"},{\"name\":\"docker\",\"platform\":\"linux\",\"command\":\"dockerd\",\"alias\":\"docker\",\"prefix\":\"docker\"}]', null, null);
COMMIT;

-- ----------------------------
--  Table structure for `cw_History_Attribute`
-- ----------------------------
DROP TABLE IF EXISTS `cw_History_Attribute`;
CREATE TABLE `cw_History_Attribute` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `ciId` bigint(20) DEFAULT NULL,
  `attributeId` bigint(20) NOT NULL,
  `name` varchar(1024) NOT NULL,
  `newValue` text,
  `op` tinyint(4) NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cw_History_Attribute_cw_Attribute_id_fk` (`attributeId`),
  KEY `cw_History_Attribute_orgId_sysId_updatedAt_index` (`orgId`,`sysId`,`updatedAt`),
  CONSTRAINT `cw_History_Attribute_cw_Attribute_id_fk` FOREIGN KEY (`attributeId`) REFERENCES `cw_Attribute` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_History_CI`
-- ----------------------------
DROP TABLE IF EXISTS `cw_History_CI`;
CREATE TABLE `cw_History_CI` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `ciId` bigint(20) NOT NULL,
  `key` varchar(512) DEFAULT NULL,
  `op` tinyint(4) NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cw_History_CI_cw_CI_id_fk` (`ciId`),
  KEY `cw_History_CI_orgId_sysId_updatedAt_index` (`orgId`,`sysId`,`updatedAt`),
  CONSTRAINT `cw_History_CI_cw_CI_id_fk` FOREIGN KEY (`ciId`) REFERENCES `cw_CI` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_History_Relationship`
-- ----------------------------
DROP TABLE IF EXISTS `cw_History_Relationship`;
CREATE TABLE `cw_History_Relationship` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `relationshipId` bigint(20) NOT NULL,
  `sourceId` bigint(20) DEFAULT NULL,
  `targetId` bigint(20) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `userOverwriteOp` tinyint(4) DEFAULT NULL,
  `op` tinyint(4) NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cw_History_Relationship_cw_Relationship_id_fk` (`relationshipId`),
  KEY `cw_History_Relationship_orgId_sysId_updatedAt_index` (`orgId`,`sysId`,`updatedAt`),
  KEY `cw_History_Relationship_sourceId_cw_CI_id_fk` (`sourceId`),
  KEY `cw_History_Relationship_cw_CI_id_fk` (`targetId`),
  CONSTRAINT `cw_History_Relationship_cw_CI_id_fk` FOREIGN KEY (`targetId`) REFERENCES `cw_CI` (`id`),
  CONSTRAINT `cw_History_Relationship_cw_Relationship_id_fk` FOREIGN KEY (`relationshipId`) REFERENCES `cw_Relationship` (`id`),
  CONSTRAINT `cw_History_Relationship_sourceId_cw_CI_id_fk` FOREIGN KEY (`sourceId`) REFERENCES `cw_CI` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_Meta_Database`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Meta_Database`;
CREATE TABLE `cw_Meta_Database` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NOT NULL,
  `value` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Meta_Database`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Meta_Database` VALUES ('1', 'version', '1.4');
COMMIT;

-- ----------------------------
--  Table structure for `cw_Meta_RelationshipType`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Meta_RelationshipType`;
CREATE TABLE `cw_Meta_RelationshipType` (
  `id` bigint(20) NOT NULL,
  `name` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Meta_RelationshipType`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Meta_RelationshipType` VALUES ('1', 'Component_of'), ('2', 'Member_of');
COMMIT;

-- ----------------------------
--  Table structure for `cw_Meta_Type`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Meta_Type`;
CREATE TABLE `cw_Meta_Type` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(1024) NOT NULL,
  `properties` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1103 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Meta_Type`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Meta_Type` VALUES ('1', 'Host', ''), ('2', 'Interface', ''), ('3', 'Device', ''), ('4', 'Memory', ''), ('5', 'SoftwareGroup', ''), ('6', 'ServiceDepend', ''), ('7', 'Configuration', ''), ('8', 'Metric', ''), ('9', 'Category', ''), ('10', 'Group', ''), ('11', 'Node', ''), ('12', 'NetworkTopo', ''), ('13', 'SNMPMonitor', ''), ('14', 'Cluster', ''), ('1101', 'VMware', ''), ('1102', 'Vcenter', '');
COMMIT;

-- ----------------------------
--  Table structure for `cw_Relationship`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Relationship`;
CREATE TABLE `cw_Relationship` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `sourceId` bigint(20) NOT NULL,
  `targetId` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `userOverwriteOp` tinyint(4) DEFAULT '0',
  `deletedAt` datetime DEFAULT '2000-01-01 00:00:00',
  PRIMARY KEY (`id`),
  KEY `cw_Relationship_target_cw_CI_id_fk` (`targetId`),
  KEY `cw_Relationship_source_cw_CI_id_fk` (`sourceId`),
  KEY `cw_Relationship_orgId_sysId_type_index` (`orgId`,`sysId`,`type`),
  CONSTRAINT `cw_Relationship_source_cw_CI_id_fk` FOREIGN KEY (`sourceId`) REFERENCES `cw_CI` (`id`),
  CONSTRAINT `cw_Relationship_target_cw_CI_id_fk` FOREIGN KEY (`targetId`) REFERENCES `cw_CI` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2414 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_Relationship_Attribute`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Relationship_Attribute`;
CREATE TABLE `cw_Relationship_Attribute` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `rsId` bigint(20) NOT NULL,
  `name` varchar(1024) NOT NULL,
  `value` text,
  `deletedAt` datetime DEFAULT NULL,
  `type` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `cw_Relationship_Attribute_orgId_sysId_name_value_index` (`orgId`,`sysId`,`name`(64),`value`(64)) USING BTREE,
  KEY `rsId` (`rsId`),
  CONSTRAINT `cw_relationship_attribute_ibfk_1` FOREIGN KEY (`rsId`) REFERENCES `cw_Relationship` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `cw_Sequence`
-- ----------------------------
DROP TABLE IF EXISTS `cw_Sequence`;
CREATE TABLE `cw_Sequence` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `orgId` int(11) NOT NULL,
  `sysId` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `value` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cw_Sequence_orgId_sysId_name_uindex` (`orgId`,`sysId`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `cw_Sequence`
-- ----------------------------
BEGIN;
INSERT INTO `cw_Sequence` VALUES ('1', '0', '0', 'agent.version.major', '1'), ('2', '0', '0', 'agent.version.minor', '0'), ('3', '0', '0', 'agent.version.patch', '0'), ('4', '0', '0', 'agent.version.config', '0');
COMMIT;

--
-- Current Database: `loghelp`
--

/*!40000 DROP DATABASE IF EXISTS `<:log_database:>`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `<:log_database:>` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `<:log_database:>`;

--
-- Table structure for table `folder`
--

DROP TABLE IF EXISTS `folder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org` bigint(20) DEFAULT '0',
  `sys` bigint(20) DEFAULT '0',
  `user` bigint(20) DEFAULT '0',
  `pnote` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `logmark`
--

DROP TABLE IF EXISTS `logmark`;
CREATE TABLE `logmark` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `org` bigint(20) DEFAULT '0',
  `sys` bigint(20) DEFAULT '0',
  `user` bigint(20) DEFAULT '0',
  `info` mediumtext COMMENT '查询条件',
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `rank` int(10) DEFAULT '0' COMMENT '排序',
  `note` varchar(255) DEFAULT NULL COMMENT '标签名',
  `pid` bigint(20) DEFAULT '0',
  `pnote` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COMMENT='日志搜索-收藏夹';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-03 16:58:03
