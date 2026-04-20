# WordPress自动化部署脚本

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu 22.04](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://ubuntu.com/)
[![GitHub Stars](https://img.shields.io/github/stars/mohen857/auto-deploy-wordpress.svg)](https://github.com/mohen857/auto-deploy-wordpress/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/mohen857/auto-deploy-wordpress.svg)](https://github.com/mohen857/auto-deploy-wordpress/network)
[![GitHub Issues](https://img.shields.io/github/issues/mohen857/auto-deploy-wordpress.svg)](https://github.com/mohen857/auto-deploy-wordpress/issues)

一个在 Ubuntu 22.04 服务器上一键自动化部署 LNMP + WordPress 环境的 Shell 脚本。

## ✨ 特性
- 🚀 **5分钟快速部署**：从裸机到完整 WordPress 站点
- 🔧 **全自动配置**：无需人工干预，一键完成
- 🔄 **幂等执行**：可重复运行，安全可靠
- 📝 **详细日志**：完整的操作记录和错误追踪
- 🔐 **安全加固**：自动配置 MySQL 安全策略

## 🏗️ 技术栈
- **操作系统**: Ubuntu 22.04 LTS
- **Web服务器**: Nginx
- **数据库**: MySQL 8.0
- **编程语言**: PHP 8.1
- **应用框架**: WordPress
- **自动化工具**: Shell脚本、WP-CLI

## 📊 监控系统
本项目已集成完整的服务器监控解决方案，包含：

### 监控架构
Node Exporter (收集指标) → Prometheus (存储查询) → Grafana (可视化展示)
### 监控组件
- **Node Exporter v1.8.0+**: 实时收集服务器 CPU、内存、磁盘、网络等系统指标
- **Prometheus v2.51.0+**: 时间序列数据库，存储和查询监控指标
- **Grafana v13.0.1+**: 可视化仪表盘，提供实时监控大屏

### 监控功能
- ✅ **实时系统监控**: CPU、内存、磁盘使用率
- ✅ **网络流量监控**: 入站/出站流量统计
- ✅ **服务状态监控**: Nginx、MySQL、PHP-FPM 运行状态
- ✅ **历史数据分析**: 可回溯数周的历史监控数据
- ✅ **可定制仪表盘**: 支持自定义监控面板和告警规则

### 监控界面
- **Grafana 面板**: http://您的服务器IP:3000
- **Prometheus UI**: http://您的服务器IP:9090
- **Node Exporter 指标**: http://您的服务器IP:9100/metrics

## 🚨 业务监控系统

除了基础架构监控（Prometheus + Grafana）外，本项目还包含一个轻量级的**业务监控系统**，用于实时监控WordPress站点的健康状态。

### 监控功能
- **服务状态监控**: Nginx、MySQL、PHP-FPM运行状态
- **网站可用性监控**: HTTP状态码、响应时间检查
- **系统资源监控**: CPU、内存、磁盘使用率
- **智能告警**: 分级告警（WARNING/ERROR），本地日志记录

### 快速使用

安装业务监控系统
sudo ./monitoring-system/install_monitoring.sh
运行监控测试
wp-test-alert all
手动检查服务状态
wp-check-service
### 监控脚本位置
所有监控脚本位于 `monitoring-system/` 目录：
- `scripts/check_service.sh` - 主监控脚本
- `scripts/test_alert.sh` - 告警测试脚本
- `configs/monitor.conf.example` - 配置文件示例
- `install_monitoring.sh` - 一键安装脚本

详细文档请查看 [monitoring-system/README.md](monitoring-system/README.md)

## 🚀 快速开始

### 1. 准备服务器
- 一台 Ubuntu 22.04 的云服务器
- root 或 sudo 权限
- 开放 22(SSH)、80(HTTP)、443(HTTPS) 端口

### 2. 获取脚本
克隆项目
git clone https://github.com/mohen857/auto-deploy-wordpress.git  
cd auto-deploy-wordpress
### 3. 配置参数复制并编辑配置文件
cp deploy_config.example.sh deploy_config.sh  
nano deploy_config.sh
### 4. 执行部署
运行部署脚本
chmod +x deploy_blog.sh  
./deploy_blog.sh
## 📁 项目结构
auto-deploy-wordpress/  
├── deploy_blog.sh # 主部署脚本  
├── deploy_config.example.sh # 配置示例  
├── deploy_config.sh # 配置文件  
├── README.md # 本文件  
├── USAGE.md # 详细使用指南  
├── TROUBLESHOOTING.md # 故障排除  
├── CONTRIBUTING.md # 贡献指南  
├── LICENSE # 许可证  
├── PROJECT_SUMMARY.md # 项目总结  
├── quick_install.sh # 快速安装脚本  
└── .gitignore # Git忽略规则  
## 📊 部署流程
1. 系统更新与初始化
2. 安装配置 Nginx
3. 安装配置 MySQL
4. 安装配置 PHP
5. 创建数据库和用户
6. 下载配置 WordPress
7. 配置 Nginx 虚拟主机
8. 自动安装 WordPress
9. 验证部署结果

## 🎯 使用场景
- 个人博客快速搭建
- 企业官网批量部署
- 开发测试环境构建
- 运维自动化学习
- CI/CD 流水线集成

## 🔧 配置说明
在 `deploy_config.sh` 中配置以下参数：

| 参数 | 说明 | 示例 |
|------|------|------|
| `SERVER_IP` | 服务器公网IP | `yourip` |
| `MYSQL_ROOT_PASSWORD` | MySQL root密码 | `YourStrongPass123!` |
| `WP_DB_PASSWORD` | WordPress数据库密码 | `YourDBPass123!` |
| `WP_ADMIN_PASSWORD` | WordPress管理员密码 | `YourAdminPass123!` |

## 🆘 获取帮助
- 📖 [详细使用指南](USAGE.md)
- 🔧 [故障排除](TROUBLESHOOTING.md)
- 👥 [贡献指南](CONTRIBUTING.md)
- 🐛 [报告问题](https://github.com/mohen857/auto-deploy-wordpress/issues)

## 📄 许可证
本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献
欢迎提交 Issue 和 Pull Request！详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## ⭐️ 致谢
感谢所有为本项目做出贡献的开发者！

---
**让部署变得简单，让运维更加高效！**
