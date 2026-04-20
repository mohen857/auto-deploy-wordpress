# WordPress监控系统

## 概述
这是WordPress自动化部署项目的监控子系统，用于监控WordPress网站的健康状态和服务器资源。

## 功能特性
- ✅ 服务状态监控：Nginx、MySQL、PHP-FPM
- ✅ 网站可用性监控：HTTP状态码、响应时间
- ✅ 系统资源监控：CPU、内存、磁盘、负载
- ✅ 智能告警：分级告警（WARNING/ERROR）
- ✅ 自动化运行：定时任务调度
- ✅ 日志记录：完整的监控日志和告警记录

## 快速开始

### 1. 安装监控系统
cd /path/to/auto-deploy-wordpress
sudo ./monitoring-system/install_monitoring.sh
### 2. 配置监控
复制配置文件
cp monitoring-system/configs/monitor.conf.example /opt/wordpress-monitoring/configs/monitor.conf
编辑配置文件
nano /opt/wordpress-monitoring/configs/monitor.conf
在配置文件中设置：
- `SERVER_IP`: 您的服务器公网IP
- `WEBSITE_URL`: 您的WordPress网站地址
- 告警阈值等参数

### 3. 运行测试
测试告警系统
wp-test-alert all
手动运行监控
wp-check-service
## 监控项目说明

| 监控项 | 检查内容 | 告警阈值 |
|--------|----------|----------|
| Nginx服务 | 进程状态 | 服务停止 |
| MySQL服务 | 连接状态 | 连接失败 |
| PHP-FPM服务 | 进程状态 | 服务停止 |
| WordPress网站 | HTTP状态码 | 非200状态 |
| 磁盘使用率 | 根分区使用率 | >90% |
| 内存使用率 | 系统内存使用率 | >80% |
| 系统负载 | 1分钟平均负载 | >70% |

## 定时任务
安装脚本自动配置定时任务：
- 每5分钟执行一次监控检查
- 每天凌晨清理旧日志

查看定时任务：
crontab -l | grep wp-check-service
## 日志管理
监控系统生成以下日志文件：

| 日志文件 | 说明 | 位置 |
|----------|------|------|
| service_status.log | 监控状态日志 | /var/log/monitoring/ |
| service_alerts.log | 告警日志 | /var/log/monitoring/ |
| cron.log | 定时任务日志 | /var/log/monitoring/ |

查看日志：
tail -f /var/log/monitoring/service_status.log
## 故障排除

### 常见问题
1. **脚本权限问题**
chmod +x monitoring-system/scripts/*.sh
2. **定时任务未执行**
sudo systemctl status cron
sudo tail -f /var/log/syslog | grep CRON
3. **MySQL连接失败**
检查MySQL服务状态
systemctl status mysql
测试MySQL连接
mysql -u root -p
### 获取帮助
如有问题，请查看：
1. 监控日志：`/var/log/monitoring/`
2. 系统日志：`journalctl -xe`
3. 项目文档：`README.md`

## 扩展功能
监控系统支持以下扩展：
1. 邮件告警：配置SMTP发送告警邮件
2. Webhook告警：集成钉钉、企业微信等
3. 自定义监控项：添加新的监控检查
4. 性能报表：生成性能分析报告

## 更新日志
- v1.0.0 (2024-04) 初始版本发布
- 基础服务监控
- 网站可用性监控
- 系统资源监控
- 分级告警系统
