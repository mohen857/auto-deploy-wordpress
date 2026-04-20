#!/bin/bash
# WordPress监控系统安装脚本
# 使用: sudo ./monitoring-system/install_monitoring.sh

set -e  # 遇到错误时停止

echo "=== WordPress监控系统安装脚本 ==="
echo ""

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用root用户运行: sudo $0"
    exit 1
fi

# 1. 安装依赖
echo "1. 安装系统依赖..."
apt update
apt install -y curl bc mysql-client

# 2. 复制脚本到系统目录
echo "2. 安装监控脚本..."
mkdir -p /opt/wordpress-monitoring/{scripts,configs}
cp -r monitoring-system/scripts/* /opt/wordpress-monitoring/scripts/
chmod +x /opt/wordpress-monitoring/scripts/*.sh

# 3. 创建符号链接
echo "3. 创建命令快捷方式..."
ln -sf /opt/wordpress-monitoring/scripts/check_service.sh /usr/local/bin/wp-check-service
ln -sf /opt/wordpress-monitoring/scripts/test_alert.sh /usr/local/bin/wp-test-alert

# 4. 创建日志目录
echo "4. 创建日志目录..."
mkdir -p /var/log/monitoring
chmod 755 /var/log/monitoring

# 5. 配置定时任务
echo "5. 配置定时任务..."
if ! crontab -l 2>/dev/null | grep -q "wp-check-service"; then
    (crontab -l 2>/dev/null; echo "# WordPress监控系统定时任务") | crontab -
    (crontab -l; echo "*/5 * * * * /usr/local/bin/wp-check-service >> /var/log/monitoring/cron.log 2>&1") | crontab -
    echo "定时任务已添加: 每5分钟执行一次监控"
else
    echo "定时任务已存在，跳过配置"
fi

# 6. 创建日志轮转配置
echo "6. 配置日志轮转..."
cat > /etc/logrotate.d/wordpress-monitoring << 'LOGROTATE'
/var/log/monitoring/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
LOGROTATE
echo ""
echo "✅ WordPress监控系统安装完成！"
echo ""
echo "使用说明:"
echo "1. 复制配置文件: cp monitoring-system/configs/monitor.conf.example /opt/wordpress-monitoring/configs/monitor.conf"
echo "2. 编辑配置: nano /opt/wordpress-monitoring/configs/monitor.conf"
echo "3. 运行测试: wp-test-alert all"
echo "4. 手动监控: wp-check-service"
echo ""
echo "日志位置: /var/log/monitoring/"
echo "安装时间: $(date)"
