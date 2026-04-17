# 故障排除指南

## 脚本执行问题

### 1. 脚本权限错误
**症状**: `bash: ./deploy_blog.sh: Permission denied`
**解决**:
chmod +x deploy_blog.sh
### 2. 配置文件未找到
**症状**: `[ERROR] 配置文件 deploy_config.sh 不存在！`
**解决**:cp deploy_config.example.sh deploy_config.sh
nano deploy_config.sh
### 3. 非交互安装卡住
**症状**: 安装过程中弹出蓝色配置界面
**解决**: 在脚本开头添加:export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
## 网络连接问题

### 1. SSH连接失败
**症状**: `Connection timed out`
**解决**:
1. 检查安全组是否开放22端口
2. 检查服务器防火墙: `ufw status`
3. 重启SSH服务: `systemctl restart ssh`

### 2. 网站无法访问
**症状**: 浏览器显示无法连接
**解决**:检查Nginx状态
systemctl status nginx
检查端口监听
netstat -tlnp | grep :80
检查防火墙
ufw status
iptables -L -n
## 服务启动问题

### 1. Nginx启动失败
**症状**: `nginx: [emerg] bind() to 0.0.0.0:80 failed`
**解决**:检查80端口是否被占用
lsof -i:80
测试Nginx配置
nginx -t
### 2. MySQL启动失败
**症状**: `Failed to start mysql.service`
**解决**:查看错误详情
journalctl -u mysql -n 50
常见原因：数据目录权限问题
chown -R mysql:mysql /var/lib/mysql
### 3. PHP-FPM启动失败
**症状**: `php8.1-fpm.service failed`
**解决**:检查配置文件
php-fpm8.1 -t
查看错误日志
tail -f /var/log/php8.1-fpm.log
## 数据库问题

### 1. 数据库连接失败
**症状**: `Error establishing a database connection`
**解决**:检查MySQL服务
systemctl status mysql
测试数据库连接
mysql -u wordpressuser -p

## 权限问题

### 1. 文件权限错误
**症状**: `Permission denied` 写入文件失败
**解决**
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod 755 {} ;
find /var/www/wordpress -type f -exec chmod 644 {} ;
## 日志查看
Nginx访问日志
tail -f /var/log/nginx/access.log
Nginx错误日志
tail -f /var/log/nginx/error.log
PHP错误日志
tail -f /var/log/php8.1-fpm.log
MySQL错误日志
tail -f /var/log/mysql/error.log
