#!/bin/bash

# 完全重建脚本

echo "=========================================="
echo "完全重建 MiniLPA Web"
echo "=========================================="
echo ""

# 停止并删除容器
echo "1. 停止并删除旧容器..."
docker stop minilpa-web 2>/dev/null
docker rm minilpa-web 2>/dev/null
echo "✅ 完成"
echo ""

# 删除所有相关镜像
echo "2. 删除旧镜像..."
docker images | grep minilpa-web | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null
docker rmi minilpa-web:latest 2>/dev/null
echo "✅ 完成"
echo ""

# 清理 Docker 缓存
echo "3. 清理 Docker 缓存..."
docker system prune -af
echo "✅ 完成"
echo ""

# 强制重新构建（不使用缓存）
echo "4. 重新构建镜像（不使用缓存，可能需要 5-10 分钟）..."
docker build --no-cache -t minilpa-web:latest . || {
    echo "❌ 构建失败！"
    exit 1
}
echo "✅ 构建完成"
echo ""

# 启动新容器
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

# 等待服务启动
echo "6. 等待服务启动（15 秒）..."
for i in {1..15}; do
    echo -n "."
    sleep 1
done
echo ""
echo "✅ 完成"
echo ""

# 检查容器状态
echo "7. 检查容器状态..."
if docker ps | grep -q minilpa-web; then
    echo "✅ 容器正在运行"
    docker ps | grep minilpa-web
else
    echo "❌ 容器未运行"
    docker logs minilpa-web
    exit 1
fi
echo ""

# 查看启动日志
echo "8. 查看启动日志..."
echo "----------------------------------------"
docker logs minilpa-web
echo "----------------------------------------"
echo ""

# 测试后端
echo "9. 测试后端 API..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 后端 API 正常 (HTTP $HTTP_CODE)"
    curl -s http://localhost:3001/api/health
else
    echo "❌ 后端 API 异常 (HTTP $HTTP_CODE)"
    echo "正在检查进程..."
    docker exec minilpa-web ps aux
fi
echo ""
echo ""

# 测试前端
echo "10. 测试前端服务..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 前端服务正常 (HTTP $HTTP_CODE)"
else
    echo "❌ 前端服务异常 (HTTP $HTTP_CODE)"
fi
echo ""

# 重载 Nginx
echo "11. 重载 Nginx..."
nginx -t && systemctl reload nginx
echo "✅ Nginx 已重载"
echo ""

# 完成
echo "=========================================="
echo "重建完成！"
echo "=========================================="
echo ""
echo "服务状态："
echo "- 容器: minilpa-web"
echo "- 后端: http://localhost:3001"
echo "- 前端: http://localhost:8080"
echo "- 网站: http://esim.haoyiseo.com"
echo ""
echo "查看实时日志："
echo "docker logs -f minilpa-web"
echo ""
echo "进入容器调试："
echo "docker exec -it minilpa-web sh"
echo ""
echo "=========================================="

