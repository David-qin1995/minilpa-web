#!/bin/bash

echo "=========================================="
echo "重新构建并启动 Docker 容器"
echo "=========================================="
echo ""

# 1. 停止并删除旧容器
echo "步骤 1: 停止并删除旧容器..."
docker-compose down
echo ""

# 2. 清理旧镜像
echo "步骤 2: 清理旧镜像..."
docker rmi minilpa-web_minilpa-web 2>/dev/null || echo "没有旧镜像需要清理"
echo ""

# 3. 重新构建（不使用缓存）
echo "步骤 3: 重新构建镜像（这可能需要几分钟）..."
docker-compose build --no-cache
echo ""

# 4. 启动容器
echo "步骤 4: 启动容器..."
docker-compose up -d
echo ""

# 5. 等待服务启动
echo "步骤 5: 等待服务启动（10 秒）..."
sleep 10
echo ""

# 6. 检查状态
echo "步骤 6: 检查容器状态..."
docker ps | grep minilpa-web
echo ""

# 7. 查看日志
echo "步骤 7: 查看启动日志..."
echo "=========================================="
docker logs --tail 30 minilpa-web
echo "=========================================="
echo ""

# 8. 测试健康检查
echo "步骤 8: 测试服务健康..."
sleep 5
curl -s http://localhost:3001/api/health | jq '.' 2>/dev/null || curl -s http://localhost:3001/api/health
echo ""
echo ""

# 9. 测试 WebSocket
echo "步骤 9: 测试 WebSocket 端点..."
curl -s "http://localhost:3001/socket.io/?EIO=4&transport=polling" | head -c 200
echo ""
echo ""

echo "=========================================="
echo "✅ 重建完成"
echo "=========================================="
echo ""
echo "访问测试："
echo "- 本地: http://localhost:8080"
echo "- 域名: http://esim.haoyiseo.com"
echo ""
echo "查看实时日志："
echo "docker logs -f minilpa-web"
echo ""

