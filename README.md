# MiniLPA Web - eSIM 管理系统

这是 MiniLPA 的 Web 版本，提供了友好的 Web 界面来管理 eSIM 配置文件。

## 功能特性

- ✅ eSIM 配置文件管理（下载、启用、禁用、删除）
- ✅ 通知管理
- ✅ 芯片信息查看
- ✅ 多语言支持（简体中文、English、日本語）
- ✅ 深色/浅色主题切换
- ✅ 拖拽和粘贴激活码/二维码
- ✅ 响应式设计

## 技术栈

- **前端**: Vue 3 + Vite + Pinia + Vue Router
- **后端**: Node.js + Express
- **部署**: Docker + Nginx
- **样式**: SCSS

## 本地开发

### 前置要求

- Node.js 18+
- npm 或 yarn

### 安装依赖

```bash
npm install
```

### 开发模式

启动前端开发服务器（端口 3000）：
```bash
npm run dev
```

启动后端服务器（端口 3001）：
```bash
npm run server
```

### 构建生产版本

```bash
npm run build
```

## Docker 部署

### 方法一：使用 Docker Compose（推荐）

```bash
docker-compose up -d
```

### 方法二：使用 Dockerfile

构建镜像：
```bash
docker build -t minilpa-web .
```

运行容器：
```bash
docker run -d \
  --name minilpa-web \
  -p 3001:3001 \
  -p 8080:8080 \
  minilpa-web
```

## 宝塔部署指南

### 1. 准备服务器环境

确保您的 CentOS 7 服务器已经安装了：
- 宝塔面板（最新版本）
- Docker（可通过宝塔商店安装）

### 2. 上传代码

将整个 `minilpa-web` 目录上传到服务器，例如：
```bash
/www/wwwroot/minilpa-web
```

### 3. 使用部署脚本

给脚本执行权限并运行：
```bash
cd /www/wwwroot/minilpa-web
chmod +x deploy.sh
./deploy.sh
```

### 4. 配置 Nginx

在宝塔面板中：

1. 点击「网站」→「添加站点」
2. 域名填写：`esim.haoyiseo.com`
3. 根目录随意选择（我们使用反向代理）
4. PHP 版本选择「纯静态」
5. 创建后，点击「设置」→「配置文件」
6. 将 `nginx.conf` 的内容复制进去
7. 保存并重启 Nginx

### 5. 配置 SSL（可选）

在宝塔面板中：
1. 点击网站的「SSL」
2. 选择「Let's Encrypt」
3. 申请免费证书
4. 强制 HTTPS

### 6. 防火墙设置

确保以下端口开放：
- 80 (HTTP)
- 443 (HTTPS)
- 3001 (后端 API)
- 8080 (前端静态文件)

在宝塔面板：安全 → 添加端口规则

### 7. 验证部署

访问：`http://esim.haoyiseo.com`

检查健康状态：
```bash
curl http://localhost:3001/api/health
```

查看容器日志：
```bash
docker logs -f minilpa-web
```

## 目录结构

```
minilpa-web/
├── src/                    # 前端源代码
│   ├── api/               # API 接口
│   ├── components/        # Vue 组件
│   ├── locales/           # 多语言文件
│   ├── router/            # 路由配置
│   ├── stores/            # Pinia 状态管理
│   ├── styles/            # 样式文件
│   ├── views/             # 页面组件
│   ├── App.vue            # 根组件
│   └── main.js            # 入口文件
├── server/                # 后端源代码
│   ├── routes/            # API 路由
│   ├── services/          # 业务逻辑
│   └── index.js           # 服务器入口
├── public/                # 静态资源
├── Dockerfile             # Docker 配置
├── docker-compose.yml     # Docker Compose 配置
├── nginx.conf             # Nginx 配置
├── deploy.sh              # 部署脚本
├── package.json           # 依赖配置
├── vite.config.js         # Vite 配置
└── README.md              # 项目文档
```

## API 接口文档

### 配置文件管理

- `GET /api/profiles` - 获取所有配置文件
- `POST /api/profiles/download` - 下载配置文件
- `POST /api/profiles/:iccid/enable` - 启用配置文件
- `POST /api/profiles/:iccid/disable` - 禁用配置文件
- `DELETE /api/profiles/:iccid` - 删除配置文件
- `PATCH /api/profiles/:iccid` - 设置昵称

### 通知管理

- `GET /api/notifications` - 获取所有通知
- `POST /api/notifications/process` - 处理通知
- `DELETE /api/notifications/:seqNumber` - 删除通知

### 芯片信息

- `GET /api/chip/info` - 获取芯片信息
- `GET /api/chip/certificate` - 获取芯片证书

### 工具

- `POST /api/qrcode/parse` - 解析二维码

## 常见问题

### 1. 如何连接物理读卡器？

当前版本使用模拟数据。要连接真实的读卡器，需要：

1. 安装 PCSC 服务：
   ```bash
   yum install pcsc-lite pcsc-lite-ccid
   systemctl start pcscd
   systemctl enable pcscd
   ```

2. 安装 lpac 工具：
   ```bash
   # 参考 https://github.com/estkme-group/lpac
   ```

3. 修改 `server/services/lpa.js` 以调用实际的 lpac 命令

### 2. 如何更新应用？

```bash
cd /www/wwwroot/minilpa-web
git pull  # 如果使用 Git
./deploy.sh
```

### 3. 如何查看日志？

```bash
# 查看容器日志
docker logs -f minilpa-web

# 查看 Nginx 日志
tail -f /www/wwwlogs/esim.haoyiseo.com.log
```

### 4. 如何备份数据？

```bash
# 备份数据目录
tar -czf minilpa-backup-$(date +%Y%m%d).tar.gz /www/wwwroot/minilpa-web/data
```

## 注意事项

⚠️ **重要提示**：

1. 当前版本使用模拟数据进行演示
2. 要使用真实的 eSIM 管理功能，需要：
   - 物理读卡器设备
   - PCSC 服务支持
   - lpac 或类似的 LPA 工具
3. 建议在生产环境中启用 HTTPS
4. 定期备份重要数据

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

如有问题，请联系技术支持。

# CI/CD Test
