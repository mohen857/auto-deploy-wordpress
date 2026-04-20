#!/bin/bash

###############################################################################
# 业务服务监控脚本
# 功能：检查 Nginx、网站状态、磁盘使用率，并发送告警
# 使用：1. 直接运行: ./check_service.sh
#      2. 设置定时任务: crontab -e
###############################################################################

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志文件配置
LOG_DIR="/var/log/monitoring"
ALERT_LOG="$LOG_DIR/service_alerts.log"
STATUS_LOG="$LOG_DIR/service_status.log"
mkdir -p "$LOG_DIR"


# 配置参数
WEBSITE_URL="http://localhost"  # 监控的网站URL
DISK_THRESHOLD=90               # 磁盘使用率告警阈值(%)

# 获取当前时间
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 初始化告警标志
ALERT_FLAG=0
ALERT_MESSAGES=()

###############################################################################
# 功能函数
###############################################################################

log_info() {
    echo "[$TIMESTAMP] INFO: $1" | tee -a "$STATUS_LOG"
}

log_warning() {
    echo "[$TIMESTAMP] WARNING: $1" | tee -a "$STATUS_LOG" >> "$ALERT_LOG"
    ALERT_MESSAGES+=("$1")
    ALERT_FLAG=1
}

log_error() {
    echo "[$TIMESTAMP] ERROR: $1" | tee -a "$STATUS_LOG" >> "$ALERT_LOG"
    ALERT_MESSAGES+=("$1")
    ALERT_FLAG=1
}

send_alert() {
    local alert_message="$1"
    local alert_level="$2"

    case "$alert_level" in
        "WARNING")
            echo -e "${YELLOW}[$TIMESTAMP] WARNING: $alert_message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}[$TIMESTAMP] ERROR: $alert_message${NC}"
            ;;
        *)
            echo -e "${BLUE}[$TIMESTAMP] INFO: $alert_message${NC}"
            ;;
    esac
}


###############################################################################
# 1. 检查 Nginx 服务状态
###############################################################################

check_nginx_service() {
    log_info "检查 Nginx 服务状态..."
    
    if systemctl is-active --quiet nginx; then
        log_info "✅ Nginx 服务正在运行"
        return 0
    else
        log_error "❌ Nginx 服务未运行！"
        send_alert "Nginx 服务已停止运行" "ERROR"
        
        # 尝试自动重启
        log_info "尝试重启 Nginx 服务..."
        if systemctl restart nginx; then
            log_info "✅ Nginx 服务重启成功"
        else
            log_error "❌ Nginx 服务重启失败"
        fi
        return 1
    fi
}

###############################################################################
# 2. 检查网站 HTTP 状态
###############################################################################


check_website_status() {
    log_info "检查网站状态: $WEBSITE_URL"
    
    # 使用 curl 检查 HTTP 状态码
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$WEBSITE_URL")
    
    if [ "$HTTP_STATUS" = "200" ]; then
        log_info "✅ 网站状态正常 (HTTP 200)"
        return 0
    elif [ "$HTTP_STATUS" = "000" ]; then
        log_error "❌ 网站无法访问 (连接超时/拒绝)"
        send_alert "网站无法访问，连接被拒绝" "ERROR"
        return 1
    elif [ "$HTTP_STATUS" = "404" ]; then
        log_error "❌ 网站返回 404 页面不存在"
        send_alert "网站返回 404 错误" "ERROR"
        return 1
    elif [ "$HTTP_STATUS" = "502" ] || [ "$HTTP_STATUS" = "503" ] || [ "$HTTP_STATUS" = "504" ]; then
        log_error "❌ 网站返回 $HTTP_STATUS 网关错误"
        send_alert "网站返回 $HTTP_STATUS 网关错误" "ERROR"
        return 1
    else
        log_warning "⚠️ 网站返回非 200 状态码: $HTTP_STATUS"
        send_alert "网站返回异常状态码: $HTTP_STATUS" "WARNING"
        return 2
    fi
}


###############################################################################
# 3. 检查磁盘使用率
###############################################################################


check_disk_usage() {
    log_info "检查磁盘使用率..."
    
    # 获取根分区使用率
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -lt "$DISK_THRESHOLD" ]; then
        log_info "✅ 磁盘使用率正常: ${DISK_USAGE}%"
        return 0
    elif [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ] && [ "$DISK_USAGE" -lt 95 ]; then
        log_warning "⚠️ 磁盘使用率较高: ${DISK_USAGE}% (阈值: ${DISK_THRESHOLD}%)"
        send_alert "磁盘使用率已达到 ${DISK_USAGE}%" "WARNING"
        return 1
    else
        log_error "❌ 磁盘使用率严重超标: ${DISK_USAGE}% (阈值: ${DISK_THRESHOLD}%)"
        send_alert "磁盘使用率严重超标: ${DISK_USAGE}%" "ERROR"
        
        # 查找大文件
        log_info "查找大文件（前10个）:"
        find / -type f -size +100M 2>/dev/null | head -10 | while read file; do
            log_info "  - $file ($(du -h "$file" 2>/dev/null | cut -f1))"
        done
        return 2
    fi
}

###############################################################################
# 4. 检查 MySQL 服务状态
###############################################################################

check_mysql_service() {
    log_info "检查 MySQL 服务状态..."
    
    if systemctl is-active --quiet mysql; then
        log_info "✅ MySQL 服务正在运行"
        
        # 获取MySQL密码（修复密码获取逻辑）
        CONFIG_FILE="/root/projects/auto-deploy-wordpress/deploy_config.sh"
        if [ -f "$CONFIG_FILE" ]; then
            # 从配置文件中提取密码
            MYSQL_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d "'\"")
        else
            MYSQL_PASSWORD=""
        fi
        
        if [ -z "$MYSQL_PASSWORD" ]; then
            log_warning "⚠️ 无法获取MySQL密码，跳过连接检查"
            return 0
        fi
        
        # 非交互式检查MySQL连接
        if mysqladmin --defaults-file="$HOME/.my.cnf" ping --silent 2>/dev/null; then
            log_info "✅ MySQL 连接正常"
            return 0
        else
            log_warning "⚠️ MySQL 服务运行但连接异常"
            send_alert "MySQL 服务连接异常" "WARNING"
            return 1
        fi
    else
        log_error "❌ MySQL 服务未运行！"
        send_alert "MySQL 服务已停止运行" "ERROR"
        return 2
    fi
}

###############################################################################
# 5. 检查 PHP-FPM 服务状态
###############################################################################

check_php_fpm_service() {
    log_info "检查 PHP-FPM 服务状态..."
    
    if systemctl is-active --quiet php8.1-fpm; then
        log_info "✅ PHP-FPM 服务正在运行"
        return 0
    else
        log_error "❌ PHP-FPM 服务未运行！"
        send_alert "PHP-FPM 服务已停止运行" "ERROR"
        return 1
    fi
}


###############################################################################
# 6. 检查系统负载
###############################################################################

check_system_load() {
    log_info "检查系统负载..."
    
    # 获取CPU核心数
    CPU_CORES=$(nproc)
    # 获取1分钟平均负载
    LOAD_1=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | tr -d ' ')
    # 计算负载百分比
    LOAD_PERCENT=$(echo "scale=0; $LOAD_1 * 100 / $CPU_CORES" | bc)
    
    if [ "$LOAD_PERCENT" -lt 70 ]; then
        log_info "✅ 系统负载正常: ${LOAD_1} (${LOAD_PERCENT}%)"
        return 0
    elif [ "$LOAD_PERCENT" -ge 70 ] && [ "$LOAD_PERCENT" -lt 90 ]; then
        log_warning "⚠️ 系统负载较高: ${LOAD_1} (${LOAD_PERCENT}%)"
        send_alert "系统负载较高: ${LOAD_1}" "WARNING"
        return 1
    else
        log_error "❌ 系统负载严重偏高: ${LOAD_1} (${LOAD_PERCENT}%)"
        send_alert "系统负载严重偏高: ${LOAD_1}" "ERROR"
        return 2
    fi
}


###############################################################################
# 7. 检查内存使用率
###############################################################################

check_memory_usage() {
    log_info "检查内存使用率..."
    
    # 获取内存使用率
    MEMORY_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100.0)}')
    
    if [ "$MEMORY_USAGE" -lt 80 ]; then
        log_info "✅ 内存使用率正常: ${MEMORY_USAGE}%"
        return 0
    elif [ "$MEMORY_USAGE" -ge 80 ] && [ "$MEMORY_USAGE" -lt 90 ]; then
        log_warning "⚠️ 内存使用率较高: ${MEMORY_USAGE}%"
        send_alert "内存使用率较高: ${MEMORY_USAGE}%" "WARNING"
        return 1
    else
        log_error "❌ 内存使用率严重超标: ${MEMORY_USAGE}%"
        send_alert "内存使用率严重超标: ${MEMORY_USAGE}%" "ERROR"
        return 2
    fi
}

###############################################################################
# 8. 生成监控报告
###############################################################################

generate_report() {
    log_info "生成监控报告..."
    
    echo ""
    echo "=================================================="
    echo "        服务器监控报告 - $TIMESTAMP"
    echo "=================================================="
    echo ""
    
    # 显示各项检查结果
    echo "🔧 服务状态检查:"
    echo "  Nginx服务: $(systemctl is-active nginx 2>/dev/null || echo 'Unknown')"
    echo "  MySQL服务: $(systemctl is-active mysql 2>/dev/null || echo 'Unknown')"
    echo "  PHP-FPM服务: $(systemctl is-active php8.1-fpm 2>/dev/null || echo 'Unknown')"
    echo ""
    
    echo "🌐 网站状态检查:"
    echo "  状态码: $(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$WEBSITE_URL" 2>/dev/null || echo 'N/A')"
    echo ""
    
    echo "💾 系统资源检查:"
    echo "  磁盘使用率: $(df -h / | awk 'NR==2 {print $5}')"
    echo "  内存使用率: $(free -h | grep Mem | awk '{print $3"/"$2 " (" int($3/$2 * 100) "%)"}')"
    echo "  系统负载: $(uptime | awk -F'load average:' '{print $2}')"
    echo "  CPU核心数: $(nproc)"
    echo ""
    
    if [ "$ALERT_FLAG" -eq 1 ]; then
        echo "🚨 当前告警:"
        for msg in "${ALERT_MESSAGES[@]}"; do
            echo "  - $msg"
        done
        echo ""
    else
        echo "✅ 所有检查项正常"
    fi
    
    echo "📊 最近检查记录:"
    tail -5 "$STATUS_LOG" 2>/dev/null | sed 's/^/  /'
    echo ""
    echo "=================================================="
}


###############################################################################
# 主函数
###############################################################################

main() {
    echo "开始执行服务监控检查..."
    echo "检查时间: $TIMESTAMP"
    echo ""
    
    # 执行各项检查
    check_nginx_service
    check_website_status
    check_disk_usage
    check_mysql_service
    check_php_fpm_service
    check_system_load
    check_memory_usage
    
    # 生成报告
    generate_report
    
    # 如果有告警，在报告中突出显示
    if [ "$ALERT_FLAG" -eq 1 ]; then
        echo -e "${RED}🚨 发现异常情况，请查看告警日志: $ALERT_LOG${NC}"
        echo -e "发送告警通知（可扩展为邮件/短信等）"
        
        # 这里可以添加发送邮件的代码
        # send_email_alert "${ALERT_MESSAGES[*]}"
    else
        echo -e "${GREEN}✅ 所有服务运行正常${NC}"
    fi
    
    echo ""
    echo "监控检查完成。详细日志: $STATUS_LOG"
    echo "告警日志: $ALERT_LOG"
    
    return $ALERT_FLAG
}


###############################################################################
# 脚本入口
###############################################################################

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then
    echo "请以root用户运行此脚本: sudo $0"
    exit 1
fi

# 执行主函数
main

# 返回状态码
exit $?

