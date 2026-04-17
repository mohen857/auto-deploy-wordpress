# WordPress自动化部署脚本使用指南

## 快速开始

### 第一步：准备服务器
1. 购买一台Ubuntu 22.04 LTS的云服务器
2. 确保有root或sudo权限
3. 开放服务器的22(SSH)、80(HTTP)、443(HTTPS)端口

### 第二步：获取部署脚本
# 通过SSH连接到服务器
ssh root@您的服务器IP

# 下载部署脚本
wget https://raw.githubusercontent.com/mohen857/auto-deploy-wordpress/main/deploy_blog.sh
wget https://raw.githubusercontent.com/mohen857/auto-deploy-wordpress/main/deploy_config.example.sh

# 或者克隆整个项目
git clone https://github.com/mohen857/auto-deploy-wordpress.git
cd auto-deploy-wordpress
第三步：配置参数
# 复制配置文件示例
cp deploy_config.example.sh deploy_config.sh

# 编辑配置文件
nano deploy_config.sh
在配置文件中修改以下关键信息：
SERVER_IP: 您的服务器公网IP
MYSQL_ROOT_PASSWORD: MySQL root密码（强密码）
WP_DB_PASSWORD: WordPress数据库密码
WP_ADMIN_PASSWORD: WordPress管理员密码
WP_ADMIN_EMAIL: 管理员邮箱
第四步：执行部署
# 赋予执行权限
chmod +x deploy_blog.sh

# 运行部署脚本
./deploy_blog.sh
第五步：访问网站
部署完成后，访问以下地址：
网站首页: http://您的服务器IP
后台管理: http://您的服务器IP/wp-admin
使用配置文件中设置的管理员账号登录
## 配置说明

### 必要配置
| 配置项 | 说明 | 示例 |
|--------|------|------|
| `SERVER_IP` | 服务器公网IP | `yourid` |
| `MYSQL_ROOT_PASSWORD` | MySQL root密码 | `My@StrongPass123` |
| `WP_ADMIN_PASSWORD` | WordPress管理员密码 | `Admin@Secure456` |

### 可选配置
| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `WP_DB_NAME` | WordPress数据库名 | `wordpress` |
| `WP_DB_USER` | WordPress数据库用户 | `wordpressuser` |
| `WP_ADMIN_USER` | WordPress管理员用户名 | `admin` |
| `WP_SITE_TITLE` | 网站标题 | `我的自动化部署博客` |
| `PHP_VERSION` | PHP版本 | `8.1` |

## 脚本功能

### 1. 系统初始化
- 更新系统软件包
- 设置非交互安装模式
- 安装必要工具

### 2. LNMP环境部署
- 安装配置Nginx
- 安装配置MySQL 8.0
- 安装配置PHP 8.1及扩展
- 自动设置MySQL安全

### 3. WordPress部署
- 自动下载最新版WordPress
- 创建数据库和用户
- 配置wp-config.php
- 自动完成WordPress安装

### 4. 服务配置
- 配置Nginx虚拟主机
- 设置文件权限
- 重启相关服务

## 故障排除

### 常见问题

#### 1. 脚本执行权限不足
chmod +x deploy_blog.sh
#### 2. 配置文件不存在
cp deploy_config.example.sh deploy_config.sh
nano deploy_config.sh
#### 3. MySQL连接失败
- 检查MySQL服务是否运行: `systemctl status mysql`
- 检查root密码是否正确
- 检查是否有其他MySQL实例冲突

#### 4. 网站无法访问
- 检查Nginx状态: `systemctl status nginx`
- 检查80端口是否开放: `netstat -tlnp | grep :80`
- 查看Nginx错误日志: `tail -f /var/log/nginx/error.log`

## 安全建议

1. **修改默认密码**：部署完成后立即修改所有密码
2. **配置防火墙**：只开放必要端口
3. **定期备份**：设置数据库和文件自动备份
4. **启用HTTPS**：使用Let's Encrypt免费SSL证书
5. **更新软件**：定期更新系统和WordPress

## 后续操作

### 1. 配置HTTPS
安装Certbot
apt install certbot python3-certbot-nginx -y
获取SSL证书
certbot --nginx -d 您的域名
### 2. 设置备份
备份数据库
mysqldump -u root -p wordpress > wordpress_backup.sql
备份网站文件
tar -czf wordpress_files_backup.tar.gz /var/www/wordpress
## 技术支持
如遇问题，请检查：
1. 脚本日志文件
2. 系统日志: `journalctl -xe`
3. Nginx错误日志: `/var/log/nginx/error.log`
4. MySQL错误日志: `/var/log/mysql/error.log`
