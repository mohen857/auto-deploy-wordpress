WordPress自动化部署脚本
https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/Ubuntu-22.04-orange.svg
一个在 Ubuntu 22.04 服务器上一键自动化部署 LNMP + WordPress 环境的 Shell 脚本。
✨ 特性
🚀 5分钟快速部署：从裸机到完整 WordPress 站点
🔧 全自动配置：无需人工干预，一键完成
🔄 幂等执行：可重复运行，安全可靠
📝 详细日志：完整的操作记录和错误追踪
🔐 安全加固：自动配置 MySQL 安全策略
🏗️ 技术栈
操作系统: Ubuntu 22.04 LTS
Web服务器: Nginx
数据库: MySQL 8.0
编程语言: PHP 8.1
应用框架: WordPress
自动化工具: Shell脚本、WP-CLI
🚀 快速开始
1. 准备服务器
一台 Ubuntu 22.04 的云服务器
root 或 sudo 权限
开放 22(SSH)、80(HTTP)、443(HTTPS) 端口
2. 获取脚本
# 克隆项目
git clone https://github.com/mohen857/auto-deploy-wordpress.git
cd auto-deploy-wordpress
3. 配置参数
# 复制并编辑配置文件
cp deploy_config.example.sh deploy_config.sh
nano deploy_config.sh
4. 执行部署
# 运行部署脚本
chmod +x deploy_blog.sh
./deploy_blog.sh
📁 项目结构
auto-deploy-wordpress/
├── deploy_blog.sh          # 主部署脚本
├── deploy_config.example.sh # 配置示例
├── deploy_config.sh        # 配置文件
├── README.md              # 本文件
├── USAGE.md               # 详细使用指南
├── TROUBLESHOOTING.md     # 故障排除
├── CONTRIBUTING.md        # 贡献指南
└── .gitignore            # Git忽略规则
📊 部署流程
系统更新与初始化
安装配置 Nginx
安装配置 MySQL
安装配置 PHP
创建数据库和用户
下载配置 WordPress
配置 Nginx 虚拟主机
自动安装 WordPress
验证部署结果
🎯 使用场景
个人博客快速搭建
企业官网批量部署
开发测试环境构建
运维自动化学习
CI/CD 流水线集成
🔧 配置说明
在 deploy_config.sh中配置以下参数：
参数
	
说明
	
示例


SERVER_IP
	
服务器公网IP
	
8.136.131.96


MYSQL_ROOT_PASSWORD
	
MySQL root密码
	
YourStrongPass123!


WP_DB_PASSWORD
	
WordPress数据库密码
	
YourDBPass123!


WP_ADMIN_PASSWORD
	
WordPress管理员密码
	
YourAdminPass123!
🆘 获取帮助
📖 详细使用指南
🔧 故障排除
👥 贡献指南
🐛 报告问题
📄 许可证
本项目基于 MIT 许可证开源 - 查看 LICENSE文件了解详情。
🤝 贡献
欢迎提交 Issue 和 Pull Request！详见 CONTRIBUTING.md。
⭐️ 致谢
本项目基于 MIT 许可证开源 - 查看 LICENSE文件了解详情。
🤝 贡献
欢迎提交 Issue 和 Pull Request！详见 CONTRIBUTING.md。
⭐️ 致谢
感谢所有为本项目做出贡献的开发者！
本项目基于 MIT 许可证开源 - 查看 LICENSE文件了解详情。
🤝 贡献
欢迎提交 Issue 和 Pull Request！详见 CONTRIBUTING.md。
⭐️ 致谢
感谢所有为本项目做出贡献的开发者！
让部署变得简单，让运维更加高效！
