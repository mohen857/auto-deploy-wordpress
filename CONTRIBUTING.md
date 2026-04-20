# 贡献指南

感谢您考虑为 WordPress 自动化部署项目做出贡献！

## 如何贡献

### 1. 报告问题
如果您发现了 bug 或有功能建议，请先检查是否已有相关 issue。

### 2. 提交 Pull Request
1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

### 3. 代码规范
- 使用有意义的变量名
- 添加适当的注释
- 遵循现有的代码风格
- 确保脚本能够幂等执行

### 4. 测试
请在提交前测试您的更改：
- 在干净的 Ubuntu 22.04 环境中测试
- 验证脚本能够成功完成部署
- 检查是否有语法错误

## 开发环境
- Ubuntu 22.04 LTS
- Bash 5.1
- Git

## 项目结构
auto-deploy-wordpress/  
├── deploy_blog.sh # 主部署脚本  
├── deploy_config.example.sh # 配置示例  
├── README.md # 项目说明  
├── USAGE.md # 使用指南  
├── TROUBLESHOOTING.md # 故障排除  
└── CONTRIBUTING.md # 贡献指南
## 联系方式
如有问题，请通过以下方式联系：
- 创建 Issue
- 发送邮件到 [2823293517@qq.com]
