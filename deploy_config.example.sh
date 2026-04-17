#!/bin/bash
# WordPress自动化部署配置示例文件
# 请复制此文件为 deploy_config.sh 并修改实际配置

# 服务器公网IP（用于Nginx配置）
export SERVER_IP="YOUR_SERVER_IP_HERE"

# MySQL相关配置
export MYSQL_ROOT_PASSWORD="YourSecureRootPassword123!"
export WP_DB_NAME="wordpress"
export WP_DB_USER="wordpressuser"
export WP_DB_PASSWORD="YourSecureDBPassword123!"

# WordPress相关配置
export WP_ADMIN_USER="admin"
export WP_ADMIN_PASSWORD="YourSecureAdminPassword123!"
export WP_ADMIN_EMAIL="your-email@example.com"
export WP_SITE_TITLE="我的自动化部署博客"

# 网站目录配置
export WEB_ROOT="/var/www/wordpress"
export NGINX_CONF="/etc/nginx/sites-available/wordpress"

# PHP版本
export PHP_VERSION="8.1"
