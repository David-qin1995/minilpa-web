# Docker 部署在线人数不显示问题排查

## 🔍 问题分析

在 Docker 环境中，在线人数不显示可能有以下原因：

1. **依赖未安装** - socket.io 未正确安装到容器中
2. **WebSocket 未启动** - 后端服务未启用 WebSocket
3. **Nginx 配置缺失** - 未配置 /socket.io/ 路径代理
4. **网络问题** - 容器网络配置问题

---

## ✅ 解决方案

### 方案 1：快速诊断（推荐）

```bash
cd /www/wwwroot/minilpa-web

# 运行诊断脚本
chmod +x docker-debug.sh
./docker-debug.sh
```

**查看输出并根据提示修复问题。**

---

### 方案 2：重新构建 Docker 镜像

```bash
cd /www/wwwroot/minilpa-web

# 运行重建脚本
chmod +x rebuild-docker.sh
./rebuild-docker.sh
```

这会：
1. ✅ 停止旧容器
2. ✅ 清理旧镜像
3. ✅ 重新构建（不使用缓存）
4. ✅ 启动新容器
5. ✅ 测试服务

---

### 方案 3：手动排查

#### 步骤 1：检查容器日志

```bash
docker logs minilpa-web
```

**应该看到：**
```
后端服务运行在端口 3001
健康检查: http://localhost:3001/api/health
WebSocket 服务已启动
```

**如果看不到 "WebSocket 服务已启动"：**
→ 依赖未安装，需要重新构建

---

#### 步骤 2：进入容器检查依赖

```bash
docker exec -it minilpa-web sh

# 在容器内执行
npm list socket.io socket.io-client

# 应该看到
# ├── socket.io@4.7.2
# └── socket.io-client@4.7.2
```

**如果没有看到：**
```bash
# 在容器内安装
npm install socket.io socket.io-client

# 退出容器
exit

# 重启容器
docker restart minilpa-web
```

---

#### 步骤 3：检查 WebSocket 端点

```bash
# 测试 WebSocket 端点是否可访问
curl "http://localhost:3001/socket.io/?EIO=4&transport=polling"

# 应该返回类似:
# 0{"sid":"...","upgrades":["websocket"],...}
```

**如果返回 404 或连接失败：**
→ WebSocket 服务未启动

---

#### 步骤 4：检查 Nginx 配置

查看 `/www/server/panel/vhost/nginx/esim.haoyiseo.com.conf`

**必须包含以下配置：**
```nginx
# WebSocket 代理（用于在线人数统计）
location /socket.io/ {
    proxy_pass http://127.0.0.1:3001;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # WebSocket 必需配置
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # 超时设置
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 3600s;
}
```

**如果没有此配置：**
1. 复制 `nginx.conf` 的内容
2. 在宝塔面板编辑网站配置
3. 添加 `/socket.io/` 配置
4. 保存并重启 Nginx

---

#### 步骤 5：检查浏览器控制台

打开 http://esim.haoyiseo.com

按 F12 打开开发者工具，查看 Console：

**正常输出：**
```
WebSocket 已连接
在线人数更新: 1 (按 IP 统计)
```

**错误输出：**
```
WebSocket 连接错误: Error: timeout
WebSocket connection to 'ws://...' failed
```

→ Nginx 配置问题或防火墙阻止

---

## 🔧 完整修复流程

### 修复步骤 1：更新 Dockerfile

已修改 `Dockerfile`：
- ✅ 从 `npm install --production` 改为 `npm install`
- ✅ 确保 socket.io 被安装

### 修复步骤 2：重新构建镜像

```bash
cd /www/wwwroot/minilpa-web

# 停止容器
docker-compose down

# 重新构建（不使用缓存）
docker-compose build --no-cache

# 启动容器
docker-compose up -d

# 查看日志
docker logs -f minilpa-web
```

**等待看到：**
```
后端服务运行在端口 3001
WebSocket 服务已启动
```

### 修复步骤 3：更新 Nginx 配置

在宝塔面板：
1. 网站 → esim.haoyiseo.com → 配置文件
2. 添加 `/socket.io/` 配置（见上面的 Nginx 配置）
3. 保存并重启 Nginx

### 修复步骤 4：测试

```bash
# 1. 测试后端
curl http://localhost:3001/api/health

# 2. 测试 WebSocket
curl "http://localhost:3001/socket.io/?EIO=4&transport=polling"

# 3. 访问网站
# http://esim.haoyiseo.com
# 查看右上角是否显示在线人数
```

---

## 📊 验证清单

- [ ] Docker 容器正在运行
- [ ] 容器日志显示 "WebSocket 服务已启动"
- [ ] 容器内 socket.io 已安装
- [ ] WebSocket 端点可访问（curl 测试）
- [ ] Nginx 配置包含 /socket.io/ 路径
- [ ] 浏览器控制台显示 "WebSocket 已连接"
- [ ] 页面右上角显示在线人数

---

## 🎯 快速修复命令

```bash
# 一键修复（在服务器上执行）
cd /www/wwwroot/minilpa-web

# 重建 Docker
./rebuild-docker.sh

# 等待构建完成后，测试访问
curl http://localhost:3001/api/health
curl "http://localhost:3001/socket.io/?EIO=4&transport=polling"

# 访问网站测试
# http://esim.haoyiseo.com
```

---

## 🐛 常见错误

### 错误 1：依赖未安装

**现象：**
```bash
docker logs minilpa-web
# Error: Cannot find module 'socket.io'
```

**解决：**
```bash
# Dockerfile 已修复，重新构建
docker-compose build --no-cache
docker-compose up -d
```

---

### 错误 2：WebSocket 连接失败

**现象：**
```
WebSocket connection failed
```

**解决：**
1. 检查 Nginx 配置是否包含 `/socket.io/`
2. 检查防火墙是否开放 3001 端口
3. 重启 Nginx

---

### 错误 3：显示 0 在线

**现象：**
- 页面显示 "0 在线"
- 指示灯是灰色的

**解决：**
1. 检查 WebSocket 连接状态
2. 查看浏览器控制台错误
3. 检查后端日志

---

## 💡 调试技巧

### 1. 实时查看日志

```bash
docker logs -f minilpa-web
```

### 2. 进入容器调试

```bash
docker exec -it minilpa-web sh

# 查看进程
ps aux

# 查看端口
netstat -tlnp

# 测试 WebSocket
curl "http://localhost:3001/socket.io/?EIO=4&transport=polling"
```

### 3. 查看 Nginx 日志

```bash
tail -f /www/wwwlogs/esim.haoyiseo.com.log
tail -f /www/wwwlogs/esim.haoyiseo.com.error.log
```

---

## ✅ 成功标志

**容器日志：**
```
后端服务运行在端口 3001
健康检查: http://localhost:3001/api/health
WebSocket 服务已启动
用户连接 [IP: xxx.xxx.xxx.xxx] [Socket: xxx]
当前在线人数: 1 (按 IP 统计)
```

**浏览器：**
- 右上角显示：`[🟢 1 在线]`
- 控制台显示：`WebSocket 已连接`

---

## 📞 还是不行？

执行诊断脚本并把输出发给我：

```bash
./docker-debug.sh > debug-output.txt
cat debug-output.txt
```

我会帮您分析具体问题！

