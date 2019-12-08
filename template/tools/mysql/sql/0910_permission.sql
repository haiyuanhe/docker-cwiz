-- ------------------------------
-- Permission发送用户邀请邮件
-- ------------------------------
USE `<:grafana_database:>`;

INSERT INTO `cwiz_static` (org_id, type, name, json_data, created, updated) VALUES (0, 'email', 'grafana_url', '<:nginx_ip:>:3000', now(), now());