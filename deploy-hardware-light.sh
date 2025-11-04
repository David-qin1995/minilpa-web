#!/bin/bash

# 轻量级硬件版本部署 - 针对低内存服务器优化

set -e

echo "=========================================="
echo "MiniLPA Web 硬件版本部署（轻量级）"
echo "=========================================="
echo ""
echo "此版本针对低内存服务器优化"
echo "使用 PM2 直接运行，不使用 Docker"
echo ""

# 检查资源
echo "当前资源："
df -h / | grep -v Filesystem
free -h | grep Mem
echo ""

# 警告
AVAILABLE_MEM=$(free -m | grep Mem | awk '{print $7}')
if [ "$AVAILABLE_MEM" -lt 500 ]; then
    echo "⚠️  警告：可用内存不足 500MB"
    echo "建议先运行: ./cleanup-system.sh"
    echo ""
    read -p "是否继续部署？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 1. 检查 PCSC 服务
echo "1. 检查 PCSC 服务..."
if systemctl is-active --quiet pcscd; then
    echo "✅ PCSC 服务运行中"
else
    systemctl start pcscd 2>/dev/null || echo "⚠️  PCSC 服务启动失败"
fi
echo ""

# 2. 检查 lpac
echo "2. 检查 lpac..."
if command -v lpac &> /dev/null; then
    echo "✅ lpac 已安装"
else
    echo "❌ lpac 未安装！请先运行: ./install-lpac-gcc.sh"
    exit 1
fi
echo ""

# 3. 检查 Node.js
echo "3. 检查 Node.js..."
if command -v node &> /dev/null; then
    echo "✅ Node.js 已安装: $(node -v)"
else
    echo "正在安装 Node.js 18（轻量级方式）..."
    # 修复镜像源
    ./fix-centos-repo.sh >/dev/null 2>&1 || true
    # 安装
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - >/dev/null 2>&1
    yum install -y nodejs
    echo "✅ Node.js 安装完成"
fi
echo ""

# 4. 安装依赖（生产模式）
echo "4. 安装依赖..."
cd /www/wwwroot/minilpa-web
npm install --production --no-optional
echo "✅ 完成"
echo ""

# 5. 构建前端（清理旧文件）
echo "5. 构建前端..."
rm -rf dist
npm run build
echo "✅ 完成"
echo ""

# 6. 配置硬件服务
echo "6. 配置硬件集成..."
if [ -f "server/services/lpa-hardware.js" ]; then
    cp server/services/lpa-hardware.js server/services/lpa.js
    echo "✅ 已切换到硬件版本"
else
    echo "⚠️  使用默认服务（模拟数据）"
fi
echo ""

# 7. 安装 PM2
echo "7. 安装 PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2 --registry=https://registry.npmmirror.com
fi
echo "✅ 完成"
echo ""

# 8. 停止旧服务
echo "8. 停止旧服务..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true
docker stop minilpa-web 2>/dev/null || true
echo "✅ 完成"
echo ""

# 9. 启动服务（内存优化）
echo "9. 启动服务..."
# 限制 Node.js 内存使用
export NODE_OPTIONS="--max-old-space-size=512"

pm2 start server/index.js \
  --name minilpa-backend \
  --max-memory-restart 300M \
  --log /www/wwwlogs/minilpa-backend.log

pm2 start server/server-static.js \
  --name minilpa-frontend \
  --max-memory-restart 200M \
  --log /www/wwwlogs/minilpa-frontend.log

echo "✅ 服务已启动"
echo ""

# 10. 保存配置
echo "10. 保存 PM2 配置..."
pm2 save
pm2 startup systemd -u root --hp /root | tail -1 | bash || true
echo "✅ 完成"
echo ""

# 11. 等待启动
echo "11. 等待服务启动..."
sleep 10
echo "✅ 完成"
echo ""

# 12. 验证服务
echo "12. 验证服务..."
if pm2 list | grep -q "online"; then
    echo "✅ 服务运行正常"
    pm2 list
else
    echo "❌ 服务启动失败"
    pm2 logs --lines 20
    exit 1
fi
echo ""

# 13. 测试 API
echo "13. 测试 API..."
sleep 2
if curl -s http://localhost:3001/api/health | grep -q "ok"; then
    echo "✅ 后端 API 正常"
else
    echo "⚠️  后端 API 未响应（读卡器未连接时正常）"
fi
echo ""

# 14. 清理构建文件
echo "14. 清理临时文件..."
npm cache clean --force 2>/dev/null || true
echo "✅ 完成"
echo ""

echo "=========================================="
echo "🎉 部署完成！"
echo "=========================================="
echo ""
echo "服务状态："
pm2 list
echo ""
echo "资源使用："
df -h / | grep -v Filesystem
free -h | grep Mem
echo ""
echo "服务地址："
echo "  前端: http://localhost:8080"
echo "  后端: http://localhost:3001"
echo "  网站: http://esim.haoyiseo.com"
echo ""
echo "⚠️  读卡器状态："
if timeout 5 lpac chip info &>/dev/null; then
    echo "  ✅ 读卡器已连接并工作正常"
else
    echo "  ⚠️  读卡器未连接或 eSIM 卡未插入"
    echo "  插入读卡器后服务会自动工作"
fi
echo ""
echo "常用命令："
echo "  pm2 list                   # 查看进程"
echo "  pm2 logs minilpa-backend   # 查看后端日志"
echo "  pm2 restart all            # 重启服务"
echo "  pm2 monit                  # 监控资源"
echo ""
echo "读卡器到货后："
echo "1. 插入读卡器和 eSIM 卡"
echo "2. 运行: lpac chip info"
echo "3. 刷新网站即可使用"
echo ""
echo "=========================================="

