#!/bin/bash

# 简化版部署脚本 - 模拟数据版本

set -e

echo "=========================================="
echo "MiniLPA Web 部署（模拟数据版本）"
echo "=========================================="
echo ""
echo "此版本使用 Docker 和模拟数据"
echo "适合在读卡器到货前先测试界面"
echo ""

# 1. 检查 Docker
echo "1. 检查 Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安装"
else
    echo "Docker 未安装，正在安装..."
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker 安装完成"
fi
echo ""

# 2. 停止旧容器
echo "2. 停止旧容器..."
docker stop minilpa-web 2>/dev/null || true
docker rm minilpa-web 2>/dev/null || true
echo "✅ 完成"
echo ""

# 3. 删除旧镜像
echo "3. 删除旧镜像..."
docker rmi minilpa-web:latest 2>/dev/null || true
echo "✅ 完成"
echo ""

# 4. 构建镜像
echo "4. 构建 Docker 镜像（需要 3-5 分钟）..."
docker build --no-cache -t minilpa-web:latest . || {
    echo "❌ 构建失败！"
    exit 1
}
echo "✅ 构建完成"
echo ""

# 5. 启动容器
echo "5. 启动容器..."
docker run -d \
  --name minilpa-web \
  --restart unless-stopped \
  -p 3001:3001 \
  -p 8080:8080 \
  minilpa-web:latest || {
    echo "❌ 启动失败！"
    exit 1
}
echo "✅ 容器已启动"
echo ""

# 6. 等待服务启动
echo "6. 等待服务启动（15 秒）..."
for i in {1..15}; do
    echo -n "."
    sleep 1
done
echo ""
echo "✅ 完成"
echo ""

# 7. 检查容器状态
echo "7. 检查容器状态..."
if docker ps | grep -q minilpa-web; then
    echo "✅ 容器正在运行"
else
    echo "❌ 容器未运行！"
    docker logs minilpa-web
    exit 1
fi
echo ""

# 8. 测试服务
echo "8. 测试服务..."
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

echo "=========================================="
echo "🎉 部署成功！"
echo "=========================================="
echo ""
echo "服务地址："
echo "  前端: http://localhost:8080"
echo "  后端: http://localhost:3001"
echo "  网站: http://esim.haoyiseo.com"
echo ""
echo "⚠️  当前使用模拟数据"
echo "    读卡器到货后运行 ./deploy-hardware.sh 切换到真实硬件"
echo ""
echo "常用命令："
echo "  docker logs -f minilpa-web     # 查看日志"
echo "  docker restart minilpa-web     # 重启服务"
echo "  docker stop minilpa-web        # 停止服务"
echo ""
echo "下一步："
echo "1. 在宝塔面板配置 Nginx（参考 nginx.conf）"
echo "2. 开放端口：80, 443, 3001, 8080"
echo "3. 访问网站：http://esim.haoyiseo.com"
echo ""
echo "=========================================="

