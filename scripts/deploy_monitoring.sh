#!/bin/bash

###############################################################################
# 监控系统一键自动化部署脚本
# 功能：部署 Node Exporter + Prometheus + Grafana
# 作者：Your Name
# 使用：以 root 用户运行 `./deploy_monitoring.sh`
###############################################################################

set -e  # 遇到任何错误即停止执行
# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 配置变量
PROMETHEUS_VERSION="2.51.0"
NODE_EXPORTER_VERSION="1.8.0"
GRAFANA_VERSION="13.0.1"  # 指定版本，或留空安装最新版
SERVER_IP="8.136.131.96"  # 【重要】请修改为您的服务器公网IP


info "开始部署监控系统 (Prometheus + Node Exporter + Grafana)..."
info "服务器IP: ${SERVER_IP}"
info "当前时间: $(date)"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    error "请使用 root 用户运行此脚本 (sudo ./deploy_monitoring.sh)"
fi

# 1. 安装 Node Exporter
info "1. 安装 Node Exporter..."
cd /tmp
NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
if [ ! -f "$NODE_EXPORTER_TAR" ]; then
    wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}" || error "下载 Node Exporter 失败"
fi
tar -xzf "$NODE_EXPORTER_TAR"
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
sudo useradd -rs /bin/false node_exporter 2>/dev/null || warn "用户 node_exporter 可能已存在"


# 创建 Node Exporter 系统服务
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
info "Node Exporter 安装完成，运行在 :9100"

# 2. 安装 Prometheus
info "2. 安装 Prometheus..."
cd /tmp
PROMETHEUS_TAR="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
if [ ! -f "$PROMETHEUS_TAR" ]; then
    wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR}" || error "下载 Prometheus 失败"
fi
tar -xzf "$PROMETHEUS_TAR"
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64" /opt/prometheus
sudo useradd -rs /bin/false prometheus 2>/dev/null || warn "用户 prometheus 可能已存在"
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus /opt/prometheus

# 创建 Prometheus 配置文件
sudo tee /opt/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["localhost:9100"]
        labels:
          instance: "monitored-server"
EOF

# 创建 Prometheus 系统服务
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
  --config.file=/opt/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.listen-address=0.0.0.0:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
info "Prometheus 安装完成，运行在 :9090"

# 3. 安装 Grafana
info "3. 安装 Grafana (此步骤可能较慢，请耐心等待)..."
sudo apt-get update
sudo apt-get install -y software-properties-common wget
# 添加 Grafana 官方 GPG 密钥和仓库
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/grafana.gpg
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
info "Grafana 安装完成，运行在 :3000"

# 4. 配置 Grafana 数据源和仪表盘 (通过 API 自动配置)
info "4. 配置 Grafana..."
sleep 10  # 等待 Grafana 完全启动
# 注意：以下 API 调用需要 Grafana 已启动。首次登录会要求改密，因此自动导入可能受限。
# 这里提供手动配置指南：
info "请手动完成以下 Grafana 配置："
info "  1. 访问 http://${SERVER_IP}:3000"
info "  2. 使用 admin/admin 登录，并按提示修改密码。"
info "  3. 添加数据源：选择 Prometheus，URL 填写 http://localhost:9090"
info "  4. 导入仪表盘：点击左侧 '+' -> Import，输入仪表盘 ID 8919 或 1860"
info "  5. 选择 Prometheus 数据源，点击 Import。"

# 5. 防火墙和安全组提示
info "5. 安全配置提醒："
warn "请在阿里云/腾讯云控制台的安全组中，添加以下入站规则："
echo "  - 端口 3000 (Grafana): 来源建议设置为您的办公IP/32 (如 $(curl -s ifconfig.me)/32)"
echo "  - 端口 9090 (Prometheus UI): 来源建议设置为 127.0.0.1/32 或您的IP/32 (非公开)"
echo "  - 端口 9100 (Node Exporter): 来源建议设置为 127.0.0.1/32 (非公开)"
info "如果您在本地，可以临时用以下命令测试端口："
echo "  curl -I http://${SERVER_IP}:3000"

# 6. 验证服务状态
info "6. 验证服务状态..."
for service in node_exporter prometheus grafana-server; do
    if systemctl is-active --quiet $service; then
        info "  ✅ $service 正在运行"
    else
        warn "  ❌ $service 未运行，请检查: sudo systemctl status $service"
    fi
done

info "=========================================="
info "监控系统基础部署完成！"
info "=========================================="
info "访问地址："
info "  - Grafana 面板: http://${SERVER_IP}:3000  (admin / 您设置的密码)"
info "  - Prometheus UI: http://${SERVER_IP}:9090"
info "  - Node Exporter 指标: http://${SERVER_IP}:9100/metrics"
info ""
warn "后续安全加固建议："
info "  1. 为 Grafana 配置域名和 HTTPS (使用 certbot)。"
info "  2. 配置 Prometheus Alertmanager 实现告警。"
info "  3. 定期备份 Grafana 仪表盘和 Prometheus 数据。"
info ""
info "部署完成时间: $(date)"
