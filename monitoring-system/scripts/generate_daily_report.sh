#!/bin/bash
# 生成每日监控报告
# 使用: ./generate_daily_report.sh

REPORT_DATE=$(date '+%Y-%m-%d')
REPORT_FILE="/var/log/monitoring/daily_report_${REPORT_DATE}.md"
STATUS_LOG="/var/log/monitoring/service_status.log"

echo "# 服务器监控日报 - $REPORT_DATE" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 1. 今日告警统计" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 统计告警数量
TOTAL_ALERTS=$(grep -c "ALERT\|ERROR\|WARNING" "$STATUS_LOG" 2>/dev/null || echo 0)
echo "- 今日总告警数: $TOTAL_ALERTS" >> "$REPORT_FILE"

# 按类型统计
ERROR_COUNT=$(grep -c "ERROR" "$STATUS_LOG" 2>/dev/null || echo 0)
WARNING_COUNT=$(grep -c "WARNING" "$STATUS_LOG" 2>/dev/null || echo 0)
echo "- 严重错误(ERROR): $ERROR_COUNT" >> "$REPORT_FILE"
echo "- 警告(WARNING): $WARNING_COUNT" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "## 2. 服务可用性" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 计算服务可用性
TOTAL_CHECKS=$(grep -c "检查 Nginx 服务状态\|检查网站状态\|检查 MySQL 服务状态" "$STATUS_LOG" 2>/dev/null || echo 1)
SUCCESS_CHECKS=$(grep -c "✅" "$STATUS_LOG" 2>/dev/null || echo 0)
AVAILABILITY=$(echo "scale=2; $SUCCESS_CHECKS * 100 / $TOTAL_CHECKS" | bc)
echo "- 服务可用性: ${AVAILABILITY}%" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "## 3. 资源使用情况" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 获取平均资源使用
echo "- 平均磁盘使用率: $(df -h / | awk 'NR==2 {print $5}')" >> "$REPORT_FILE"
echo "- 平均内存使用率: $(free -m | awk 'NR==2 {printf "%.1f%%", $3 * 100/$2}')" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "## 4. 详细日志" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```bash' >> "$REPORT_FILE"
tail -50 "$STATUS_LOG" >> "$REPORT_FILE" 2>/dev/null
echo '```' >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*报告生成时间: $(date)*" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "## 4. 详细日志" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```bash' >> "$REPORT_FILE"
tail -50 "$STATUS_LOG" >> "$REPORT_FILE" 2>/dev/null
echo '```' >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*报告生成时间: $(date)*" >> "$REPORT_FILE"

echo "每日报告已生成: $REPORT_FILE"
cat "$REPORT_FILE"
