ALTER USER 'root'@'localhost' IDENTIFIED BY 'PASSWORD';
CREATE USER '<:mysql_username:>'@'%' IDENTIFIED BY 'PASSWORD';
GRANT ALL ON *.* TO '<:mysql_username:>'@'%';
