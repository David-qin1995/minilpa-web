#!/bin/bash

# 切换到硬件版本 - 读卡器到货后执行

set -e

echo "=========================================="
echo "切换到硬件版本"
echo "=========================================="
echo ""

# 检查读卡器
echo "1. 检查读卡器..."
if timeout 5 lpac chip info &>/dev/null; then
    echo "✅ 读卡器已连接并工作正常"
    lpac chip info
else
    echo "❌ 未检测到读卡器！"
    echo ""
    echo "请确认："
    echo "  1. 读卡器已插入 USB 端口"
    echo "  2. eSIM 卡已插入读卡器"
    echo "  3. PCSC 服务运行正常: systemctl status pcscd"
    echo ""
    read -p "是否仍要继续部署？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

echo "⚠️  注意：Docker 容器无法直接访问 USB 读卡器"
echo ""
echo "硬件版本需要使用 PM2 部署（不使用 Docker）"
echo ""
read -p "是否继续？将停止 Docker 并使用 PM2 部署 (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi
echo ""

# 2. 停止 Docker 版本
echo "2. 停止 Docker 版本..."
docker stop minilpa-web 2>/dev/null || true
docker rm minilpa-web 2>/dev/null || true
echo "✅ 完成"
echo ""

# 3. 修复镜像源（如果需要）
echo "3. 确保镜像源正确..."
./fix-centos-repo.sh >/dev/null 2>&1 || true
echo "✅ 完成"
echo ""

# 4. 使用二进制 Node.js（避免 glibc 问题）
echo "4. 安装 Node.js（二进制版本）..."
if ! command -v node &> /dev/null; then
    echo "下载 Node.js 16 二进制版本（兼容 CentOS 7）..."
    cd /tmp
    wget https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.xz
    tar -xf node-v16.20.2-linux-x64.tar.xz
    rm -rf /opt/node
    mv node-v16.20.2-linux-x64 /opt/node
    ln -sf /opt/node/bin/node /usr/local/bin/node
    ln -sf /opt/node/bin/npm /usr/local/bin/npm
    ln -sf /opt/node/bin/npx /usr/local/bin/npx
    rm -f node-v16.20.2-linux-x64.tar.xz
    echo "✅ Node.js 16 安装完成"
else
    echo "✅ Node.js 已安装: $(node -v)"
fi
echo ""

# 5. 安装依赖
echo "5. 安装依赖..."
cd /www/wwwroot/minilpa-web
npm install --production
echo "✅ 完成"
echo ""

# 6. 构建前端
echo "6. 构建前端..."
npm run build
echo "✅ 完成"
echo ""

# 7. 配置硬件服务
echo "7. 配置硬件服务..."
if [ -f "server/services/lpa-hardware.js" ]; then
    cp server/services/lpa-hardware.js server/services/lpa.js
    echo "✅ 已切换到硬件版本"
fi
echo ""

# 8. 安装 PM2
echo "8. 安装 PM2..."
npm install -g pm2
echo "✅ 完成"
echo ""

# 9. 启动服务
echo "9. 启动服务..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

pm2 start server/index.js --name minilpa-backend --max-memory-restart 300M
pm2 start server/server-static.js --name minilpa-frontend --max-memory-restart 200M
pm2 save
pm2 startup | tail -1 | bash || true
echo "✅ 完成"
echo ""

# 10. 验证
echo "10. 验证服务..."
sleep 5
pm2 list
echo ""

# 11. 测试读卡器
echo "11. 测试读卡器连接..."
if curl -s http://localhost:3001/api/chip/info | grep -q "eid"; then
    echo "✅ 读卡器连接成功！"
    curl -s http://localhost:3001/api/chip/info
else
    echo "⚠️  读卡器未连接或服务未就绪"
    echo "稍后刷新网页查看"
fi
echo ""

echo "=========================================="
echo "🎉 切换完成！"
echo "=========================================="
echo ""
echo "硬件版本已启动，使用 PM2 管理"
echo ""
echo "服务状态："
pm2 list
echo ""
echo "常用命令："
echo "  pm2 list                   # 查看进程"
echo "  pm2 logs minilpa-backend   # 查看日志"
echo "  pm2 restart all            # 重启服务"
echo "  lpac chip info             # 测试读卡器"
echo ""
echo "现在访问网站，应该能看到真实的 eSIM 数据！"
echo "http://esim.haoyiseo.com"
echo ""
echo "=========================================="

