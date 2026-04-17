!/bin/bash
WordPress快速安装脚本
echo "========================================="
echo " WordPress自动化部署快速安装"
echo "========================================="
echo ""
检查是否以root运行
if [ "$EUID" -ne 0 ]; then
echo "请以root用户运行此脚本！"
echo "使用: sudo ./quick_install.sh"
exit 1
fi
检查必要工具
command -v git >/dev/null 2>&1 || {
echo "安装git..."
apt update && apt install -y git
}
克隆项目（如果是第一次运行）
if [ ! -d "auto-deploy-wordpress" ]; then
echo "下载部署脚本..."
git clone https://github.com/mohen857/auto-deploy-wordpress.git
cd auto-deploy-wordpress
else
cd auto-deploy-wordpress
echo "更新部署脚本..."
git pull
fi
配置检查
if [ ! -f "deploy_config.sh" ]; then
echo "创建配置文件..."
cp deploy_config.example.sh deploy_config.sh
echo ""
echo "请先编辑配置文件:"
echo " nano deploy_config.sh"
echo ""
echo "需要修改:"
echo " 1. SERVER_IP: 您的服务器公网IP"
echo " 2. MYSQL_ROOT_PASSWORD: MySQL root密码"
echo " 3. WP_ADMIN_PASSWORD: WordPress管理员密码"
echo ""
read -p "编辑完成后按回车键继续..." dummy
fi
检查配置是否已修改
if grep -q "YOUR_SERVER_IP_HERE" deploy_config.sh; then
echo "错误: 请先在 deploy_config.sh 中配置服务器IP！"
exit 1
fi
运行部署
chmod +x deploy_blog.sh
echo "开始部署WordPress..."
echo "这将需要5-10分钟，请耐心等待..."
echo ""
./deploy_blog.sh
