#!/bin/bash

# Docker 轻量级部署 - 针对低内存服务器优化

set -e

echo "=========================================="
echo "MiniLPA Web Docker 部署（轻量级）"
echo "=========================================="
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
fi

# 1. 检查 Docker
echo "1. 检查 Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安装"
else
    echo "正在安装 Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker 安装完成"
fi
echo ""

# 2. 清理旧容器和镜像
echo "2. 清理旧资源..."
docker stop minilpa-web 2>/dev/null || true
docker rm minilpa-web 2>/dev/null || true
docker rmi minilpa-web:latest 2>/dev/null || true
docker system prune -f
echo "✅ 完成"
echo ""

# 3. 构建镜像（不使用缓存）
echo "3. 构建 Docker 镜像（需要 5-8 分钟）..."
cd /www/wwwroot/minilpa-web
docker build --no-cache -t minilpa-web:latest . || {
    echo "❌ 构建失败！"
    exit 1
}
echo "✅ 构建完成"
echo ""

# 4. 启动容器（内存限制）
echo "4. 启动容器（限制内存 700MB）..."
docker run -d \
  --name minilpa-web \
  --restart unless-stopped \
  --memory="700m" \
  --memory-swap="700m" \
  --cpus="1.0" \
  -p 3001:3001 \
  -p 8080:8080 \
  minilpa-web:latest || {
    echo "❌ 启动失败！"
    exit 1
}
echo "✅ 容器已启动"
echo ""

# 5. 等待服务启动
echo "5. 等待服务启动（20 秒）..."
for i in {1..20}; do
    echo -n "."
    sleep 1
done
echo ""
echo "✅ 完成"
echo ""

# 6. 检查容器状态
echo "6. 检查容器状态..."
if docker ps | grep -q minilpa-web; then
    echo "✅ 容器正在运行"
    docker ps | grep minilpa-web
else
    echo "❌ 容器未运行！查看日志："
    docker logs minilpa-web
    exit 1
fi
echo ""

# 7. 测试服务
echo "7. 测试服务..."
sleep 3

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 后端 API 正常 (HTTP $HTTP_CODE)"
else
    echo "⚠️  后端 API 未响应 (HTTP $HTTP_CODE)"
    echo "等待更长时间..."
    sleep 10
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ 后端 API 正常 (HTTP $HTTP_CODE)"
    else
        echo "❌ 后端 API 异常，查看日志："
        docker logs --tail 50 minilpa-web
    fi
fi

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 前端服务正常 (HTTP $HTTP_CODE)"
else
    echo "⚠️  前端服务未响应 (HTTP $HTTP_CODE)"
fi
echo ""

# 8. 清理构建缓存
echo "8. 清理 Docker 缓存..."
docker system prune -f
echo "✅ 完成"
echo ""

echo "=========================================="
echo "🎉 部署完成！"
echo "=========================================="
echo ""
echo "容器信息："
docker ps | grep minilpa-web
echo ""
echo "资源限制："
echo "  内存：700MB"
echo "  CPU：1 核"
echo ""
echo "当前资源使用："
df -h / | grep -v Filesystem
free -h | grep Mem
echo ""
echo "服务地址："
echo "  前端: http://localhost:8080"
echo "  后端: http://localhost:3001"
echo "  网站: http://esim.haoyiseo.com"
echo ""
echo "⚠️  读卡器状态："
echo "  当前使用模拟数据"
echo "  读卡器到货后，数据会显示空（正常）"
echo "  需要切换到硬件版本：运行 ./switch-to-hardware.sh"
echo ""
echo "常用命令："
echo "  docker logs -f minilpa-web    # 查看日志"
echo "  docker restart minilpa-web    # 重启服务"
echo "  docker stats minilpa-web      # 查看资源"
echo "  docker exec -it minilpa-web sh  # 进入容器"
echo ""
echo "下一步："
echo "1. 在宝塔面板配置 Nginx"
echo "2. 开放端口：80, 443, 3001, 8080"
echo "3. 访问网站：http://esim.haoyiseo.com"
echo ""
echo "=========================================="

