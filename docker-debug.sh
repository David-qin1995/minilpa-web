#!/bin/bash

echo "=========================================="
echo "Docker 部署在线人数功能诊断"
echo "=========================================="
echo ""

# 1. 检查容器是否运行
echo "1. 检查 Docker 容器状态..."
if docker ps | grep -q minilpa-web; then
    echo "✅ 容器正在运行"
    docker ps | grep minilpa-web
else
    echo "❌ 容器未运行"
    echo "请先启动容器: docker-compose up -d"
    exit 1
fi
echo ""

# 2. 检查端口
echo "2. 检查端口映射..."
docker port minilpa-web
echo ""

# 3. 检查容器日志
echo "3. 查看容器日志（最近 20 行）..."
echo "=========================================="
docker logs --tail 20 minilpa-web
echo "=========================================="
echo ""

# 4. 检查 WebSocket 连接
echo "4. 测试 WebSocket 端点..."
curl -s http://localhost:3001/socket.io/?EIO=4&transport=polling
echo ""
echo ""

# 5. 检查后端健康
echo "5. 检查后端健康状态..."
curl -s http://localhost:3001/api/health | jq '.' 2>/dev/null || curl -s http://localhost:3001/api/health
echo ""
echo ""

# 6. 进入容器检查
echo "6. 检查容器内依赖..."
docker exec minilpa-web sh -c "npm list socket.io socket.io-client 2>/dev/null | head -20"
echo ""

# 7. 检查 Nginx 配置
echo "7. 检查 Nginx 是否配置了 WebSocket 代理..."
if [ -f "/www/server/panel/vhost/nginx/esim.haoyiseo.com.conf" ]; then
    echo "Nginx 配置文件存在"
    if grep -q "location /socket.io/" "/www/server/panel/vhost/nginx/esim.haoyiseo.com.conf"; then
        echo "✅ 已配置 /socket.io/ 路径"
    else
        echo "❌ 未配置 /socket.io/ 路径"
        echo "需要添加 WebSocket 代理配置"
    fi
else
    echo "⚠️  未找到 Nginx 配置文件"
fi
echo ""

echo "=========================================="
echo "诊断完成"
echo "=========================================="
echo ""
echo "常见问题解决："
echo "1. 如果容器日志没有 'WebSocket 服务已启动'："
echo "   → 重新构建镜像: docker-compose build --no-cache"
echo ""
echo "2. 如果依赖未安装："
echo "   → 修改 Dockerfile 后重新构建"
echo ""
echo "3. 如果 Nginx 未配置 WebSocket："
echo "   → 添加 nginx.conf 中的 /socket.io/ 配置"
echo ""
echo "4. 如果浏览器控制台显示连接错误："
echo "   → 检查防火墙是否开放端口"
echo ""

