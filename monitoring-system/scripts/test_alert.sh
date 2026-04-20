#!/bin/bash
# 测试告警系统
# 使用: ./test_alert.sh [test_type]

TEST_TYPE="${1:-all}"

echo "测试告警系统: $TEST_TYPE"
echo "当前时间: $(date)"
echo ""
case "$TEST_TYPE" in
    "nginx")
        echo "模拟 Nginx 服务停止..."
        systemctl stop nginx
        sleep 2
        ./check_service.sh
        systemctl start nginx
        ;;
        
    "website")
        echo "模拟网站不可访问..."
        # 临时修改监控脚本中的URL
        sed -i 's|WEBSITE_URL="http://localhost"|WEBSITE_URL="http://localhost:9999"|' check_service.sh
        ./check_service.sh
        sed -i 's|WEBSITE_URL="http://localhost:9999"|WEBSITE_URL="http://localhost"|' check_service.sh
        ;;
        
    "disk")
        echo "模拟磁盘空间不足..."
        # 临时修改阈值
        sed -i 's/DISK_THRESHOLD=90/DISK_THRESHOLD=1/' check_service.sh
        ./check_service.sh
        sed -i 's/DISK_THRESHOLD=1/DISK_THRESHOLD=90/' check_service.sh
        ;;
        
    "all")
        echo "运行所有测试..."
        echo ""
        echo "1. 测试 Nginx 告警..."
        sudo systemctl stop nginx
        ./check_service.sh | grep -A5 "🚨"
        sudo systemctl start nginx
        sleep 3
        
        echo ""
        echo "2. 测试网站告警..."
        sed -i 's|WEBSITE_URL="http://localhost"|WEBSITE_URL="http://localhost:9999"|' check_service.sh
        ./check_service.sh | grep -A5 "🚨"
        sed -i 's|WEBSITE_URL="http://localhost:9999"|WEBSITE_URL="http://localhost"|' check_service.sh
        sleep 3
        
        echo ""
        echo "3. 测试磁盘告警..."
        sed -i 's/DISK_THRESHOLD=90/DISK_THRESHOLD=1/' check_service.sh
        ./check_service.sh | grep -A5 "🚨"
        sed -i 's/DISK_THRESHOLD=1/DISK_THRESHOLD=90/' check_service.sh
        ;;
        
    *)
        echo "用法: $0 [nginx|website|disk|all]"
        ;;
esac
echo ""
echo "测试完成。查看告警日志: /var/log/monitoring/service_alerts.log"
