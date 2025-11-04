#!/bin/bash

# MiniLPA Web 硬件版本部署脚本
# 使用 PM2 直接运行，支持真实读卡器

set -e

echo "=========================================="
echo "MiniLPA Web 硬件版本部署"
echo "=========================================="
echo ""

# 1. 检查 PCSC 服务
echo "1. 检查 PCSC 服务..."
if systemctl is-active --quiet pcscd; then
    echo "✅ PCSC 服务正在运行"
else
    echo "⚠️  PCSC 服务未运行，正在启动..."
    systemctl start pcscd 2>/dev/null || echo "❌ 无法启动 PCSC 服务"
    systemctl enable pcscd 2>/dev/null
fi
echo ""

# 2. 检查 lpac
echo "2. 检查 lpac..."
if command -v lpac &> /dev/null; then
    echo "✅ lpac 已安装"
    lpac --version 2>/dev/null || echo "版本信息不可用"
else
    echo "❌ lpac 未安装！"
    echo ""
    echo "请先安装 lpac，参考：硬件集成指南.md"
    echo "快速安装："
    echo "  yum install -y git cmake curl-devel pcsclite-devel"
    echo "  cd /tmp && git clone https://github.com/estkme-group/lpac.git"
    echo "  cd lpac && mkdir build && cd build && cmake .. && make && make install"
    echo ""
    exit 1
fi
echo ""

# 3. 检查读卡器
echo "3. 检查读卡器..."
if timeout 5 pcsc_scan -n 2>&1 | grep -q "Reader"; then
    echo "✅ 读卡器已连接"
else
    echo "⚠️  未检测到读卡器（可能未插入或驱动未安装）"
fi
echo ""

# 4. 测试 lpac
echo "4. 测试 lpac 连接..."
if timeout 10 lpac chip info &> /dev/null; then
    echo "✅ lpac 工作正常"
    echo ""
    lpac chip info 2>/dev/null || true
else
    echo "⚠️  lpac 无法读取芯片"
    echo ""
    echo "可能的原因："
    echo "  - 读卡器未插入"
    echo "  - eSIM 卡未插入"
    echo "  - PCSC 服务未正常运行"
    echo ""
    echo "继续部署应用..."
fi
echo ""

# 5. 检查 Node.js
echo "5. 检查 Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo "✅ Node.js 已安装: $NODE_VERSION"
else
    echo "❌ Node.js 未安装，正在安装..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
    echo "✅ Node.js 安装完成"
fi
echo ""

# 6. 安装 PM2
echo "6. 检查 PM2..."
if command -v pm2 &> /dev/null; then
    echo "✅ PM2 已安装"
else
    echo "正在安装 PM2..."
    npm install -g pm2
    echo "✅ PM2 安装完成"
fi
echo ""

# 7. 部署应用
echo "7. 部署应用..."
cd /www/wwwroot/minilpa-web

echo "安装依赖..."
npm install

echo "构建前端..."
npm run build

echo "✅ 构建完成"
echo ""

# 8. 配置使用硬件服务
echo "8. 配置硬件集成..."
if [ -f "server/services/lpa-hardware.js" ]; then
    # 备份原文件
    cp server/services/lpa.js server/services/lpa-mock.js.bak 2>/dev/null || true
    # 使用硬件版本
    cp server/services/lpa-hardware.js server/services/lpa.js
    echo "✅ 已切换到硬件版本"
else
    echo "⚠️  硬件服务文件不存在，使用模拟版本"
fi
echo ""

# 9. 停止旧进程
echo "9. 停止旧进程..."
pm2 stop minilpa-backend 2>/dev/null || true
pm2 stop minilpa-frontend 2>/dev/null || true
pm2 delete minilpa-backend 2>/dev/null || true
pm2 delete minilpa-frontend 2>/dev/null || true
echo "✅ 完成"
echo ""

# 10. 启动新进程
echo "10. 启动服务..."
pm2 start server/index.js --name minilpa-backend --log /www/wwwlogs/minilpa-backend.log
pm2 start server/server-static.js --name minilpa-frontend --log /www/wwwlogs/minilpa-frontend.log

# 保存配置
pm2 save

# 设置开机自启
pm2 startup | grep -v "PM2" | bash || true

echo "✅ 服务已启动"
echo ""

# 11. 等待服务启动
echo "11. 等待服务启动（10 秒）..."
for i in {1..10}; do
    echo -n "."
    sleep 1
done
echo ""
echo "✅ 完成"
echo ""

# 12. 验证服务
echo "12. 验证服务..."
sleep 2

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 后端 API 正常 (HTTP $HTTP_CODE)"
else
    echo "❌ 后端 API 异常 (HTTP $HTTP_CODE)"
fi

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 前端服务正常 (HTTP $HTTP_CODE)"
else
    echo "❌ 前端服务异常 (HTTP $HTTP_CODE)"
fi
echo ""

# 13. 重载 Nginx
echo "13. 重载 Nginx..."
if nginx -t 2>/dev/null; then
    systemctl reload nginx
    echo "✅ Nginx 已重载"
else
    echo "⚠️  Nginx 配置有误，请检查"
fi
echo ""

# 完成
echo "=========================================="
echo "🎉 部署完成！"
echo "=========================================="
echo ""
echo "服务状态："
pm2 list
echo ""
echo "服务地址："
echo "  前端: http://localhost:8080"
echo "  后端: http://localhost:3001"
echo "  网站: http://esim.haoyiseo.com"
echo ""
echo "常用命令："
echo "  pm2 list                  # 查看进程列表"
echo "  pm2 logs minilpa-backend  # 查看后端日志"
echo "  pm2 logs minilpa-frontend # 查看前端日志"
echo "  pm2 restart all           # 重启所有服务"
echo "  pm2 stop all              # 停止所有服务"
echo ""
echo "硬件测试："
echo "  lpac chip info            # 查看芯片信息"
echo "  lpac profile list         # 查看配置文件"
echo "  pcsc_scan                 # 扫描读卡器"
echo ""
echo "=========================================="

