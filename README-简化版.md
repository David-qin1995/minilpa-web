# MiniLPA Web - eSIM 管理系统

基于 MiniLPA 桌面版开发的 Web 版本，提供友好的 Web 界面来管理 eSIM 配置文件。

## 快速部署

### 1. 上传代码到服务器

```bash
# 上传整个 minilpa-web 文件夹到
/www/wwwroot/minilpa-web
```

### 2. 运行部署脚本

```bash
cd /www/wwwroot/minilpa-web
chmod +x deploy.sh
./deploy.sh
```

### 3. 配置 Nginx（宝塔面板）

1. 添加网站：`esim.haoyiseo.com`
2. 复制 `nginx.conf` 内容到配置文件
3. 保存并重载 Nginx

### 4. 开放端口（宝塔安全面板）

- 80 (HTTP)
- 443 (HTTPS)
- 3001 (后端 API)
- 8080 (前端静态)

### 5. 访问网站

`http://esim.haoyiseo.com`

---

## 主要功能

- ✅ eSIM 配置文件管理
- ✅ 通知管理
- ✅ 芯片信息查看
- ✅ 多语言支持（中/英/日）
- ✅ 深色/浅色主题
- ✅ 拖拽上传二维码

---

## 常用命令

```bash
# 查看日志
docker logs -f minilpa-web

# 重启服务
docker restart minilpa-web

# 停止服务
docker stop minilpa-web

# 完全重建
./rebuild.sh
```

---

## 技术栈

- **前端**: Vue 3 + Vite + Pinia
- **后端**: Node.js + Express
- **部署**: Docker + Nginx

---

## 故障排查

如果遇到 502 错误或服务无法访问：

```bash
# 运行重建脚本
./rebuild.sh
```

查看详细文档：
- `宝塔部署指南.md` - 完整部署步骤
- `快速启动指南.md` - 5分钟快速上手

---

## 文件说明

### 核心文件
- `src/` - 前端源代码
- `server/` - 后端源代码
- `package.json` - 依赖配置
- `Dockerfile` - Docker 镜像配置

### 部署文件
- `deploy.sh` - 首次部署脚本
- `rebuild.sh` - 完全重建脚本
- `nginx.conf` - Nginx 配置模板
- `docker-compose.yml` - Docker Compose 配置

### 文档
- `README-简化版.md` - 本文件
- `宝塔部署指南.md` - 详细部署指南
- `快速启动指南.md` - 快速上手
- `项目说明.md` - 技术说明

---

## 端口说明

- **80/443**: Nginx HTTP/HTTPS
- **3001**: 后端 API 服务
- **8080**: 前端静态文件服务

---

## 联系支持

遇到问题请查看文档或联系技术支持。

---

**MIT License**

