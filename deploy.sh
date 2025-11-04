#!/bin/bash

# MiniLPA Web 部署脚本
# 用于在宝塔 CentOS7 环境中部署应用

set -e

echo "=========================================="
echo "MiniLPA Web 部署脚本"
echo "=========================================="
echo ""

# 配置变量
APP_NAME="minilpa-web"
DOCKER_IMAGE="${APP_NAME}:latest"
CONTAINER_NAME="${APP_NAME}"

# 1. 检查 Docker 是否安装
echo "1. 检查 Docker 安装..."
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker 安装完成"
else
    echo "✅ Docker 已安装"
fi
echo ""

# 2. 停止并删除旧容器
echo "2. 停止并删除旧容器..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true
echo "✅ 完成"
echo ""

# 3. 删除旧镜像
echo "3. 删除旧镜像..."
docker rmi ${DOCKER_IMAGE} 2>/dev/null || true
echo "✅ 完成"
echo ""

# 4. 构建新镜像
echo "4. 构建 Docker 镜像（需要 3-5 分钟）..."
docker build --no-cache -t ${DOCKER_IMAGE} . || {
    echo "❌ 构建失败！"
    exit 1
}
echo "✅ 构建完成"
echo ""

# 5. 运行容器
echo "5. 启动容器..."
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 3001:3001 \
  -p 8080:8080 \
  ${DOCKER_IMAGE} || {
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
if docker ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ 容器正在运行"
else
    echo "❌ 容器未运行！"
    docker logs ${CONTAINER_NAME}
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

# 9. 部署成功
echo "=========================================="
echo "🎉 部署成功！"
echo "=========================================="
echo ""
echo "服务地址："
echo "  前端: http://localhost:8080"
echo "  后端: http://localhost:3001"
echo "  网站: http://esim.haoyiseo.com"
echo ""
echo "常用命令："
echo "  查看日志: docker logs -f ${CONTAINER_NAME}"
echo "  重启服务: docker restart ${CONTAINER_NAME}"
echo "  停止服务: docker stop ${CONTAINER_NAME}"
echo "  进入容器: docker exec -it ${CONTAINER_NAME} sh"
echo ""
echo "=========================================="

