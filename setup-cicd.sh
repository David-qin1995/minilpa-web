#!/bin/bash

# 设置 CI/CD 自动部署

echo "=========================================="
echo "设置 GitHub CI/CD 自动部署"
echo "=========================================="
echo ""

# 1. 检查 Git
echo "1. 检查 Git..."
if ! command -v git &> /dev/null; then
    echo "正在安装 Git..."
    yum install -y git
fi
echo "✅ Git 已安装: $(git --version)"
echo ""

# 2. 初始化 Git 仓库（如果还没有）
echo "2. 初始化 Git 仓库..."
cd /www/wwwroot/minilpa-web

if [ ! -d ".git" ]; then
    git init
    echo "✅ Git 仓库已初始化"
else
    echo "✅ Git 仓库已存在"
fi
echo ""

# 3. 生成 SSH 密钥（用于 GitHub Actions）
echo "3. 生成 SSH 密钥..."
SSH_KEY_PATH="/root/.ssh/minilpa_deploy"

if [ ! -f "$SSH_KEY_PATH" ]; then
    ssh-keygen -t rsa -b 4096 -C "minilpa-deploy" -f "$SSH_KEY_PATH" -N ""
    echo "✅ SSH 密钥已生成"
else
    echo "✅ SSH 密钥已存在"
fi
echo ""

# 4. 配置 SSH 访问
echo "4. 配置 SSH 访问..."
if ! grep -q "$(cat $SSH_KEY_PATH.pub)" /root/.ssh/authorized_keys 2>/dev/null; then
    cat "$SSH_KEY_PATH.pub" >> /root/.ssh/authorized_keys
    echo "✅ 公钥已添加到 authorized_keys"
else
    echo "✅ 公钥已在 authorized_keys 中"
fi
echo ""

# 5. 显示需要配置的信息
echo "=========================================="
echo "✅ CI/CD 设置完成！"
echo "=========================================="
echo ""
echo "📝 下一步：在 GitHub 仓库配置以下 Secrets"
echo "=========================================="
echo ""
echo "1. 进入 GitHub 仓库设置："
echo "   Settings -> Secrets and variables -> Actions -> New repository secret"
echo ""
echo "2. 添加以下 Secrets："
echo ""
echo "   SECRET_NAME: SERVER_HOST"
echo "   VALUE: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP')"
echo ""
echo "   SECRET_NAME: SERVER_USER"
echo "   VALUE: root"
echo ""
echo "   SECRET_NAME: SERVER_PORT"
echo "   VALUE: 22"
echo ""
echo "   SECRET_NAME: SSH_PRIVATE_KEY"
echo "   VALUE:"
echo "   ============ 复制下面的内容 ============"
cat "$SSH_KEY_PATH"
echo "   ========================================"
echo ""
echo "=========================================="
echo "🎯 完成后，每次 git push 都会自动部署！"
echo "=========================================="
echo ""
echo "测试命令："
echo "  git add ."
echo "  git commit -m 'test ci/cd'"
echo "  git push origin main"
echo ""

