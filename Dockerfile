# MiniLPA Web - 生产环境 Dockerfile

# 阶段 1: 构建前端
FROM node:18-alpine AS frontend-builder

WORKDIR /app

COPY package*.json ./
COPY vite.config.js ./
COPY index.html ./

RUN npm install

COPY src ./src
COPY public ./public

RUN npm run build

# 阶段 2: 生产环境
FROM node:18-alpine

WORKDIR /app

# 复制后端代码
COPY server ./server
COPY package*.json ./

# 安装生产依赖
RUN npm install --production

# 从构建阶段复制前端构建产物
COPY --from=frontend-builder /app/dist ./dist

# 安装 express（用于静态文件服务）
RUN npm install express

# 暴露端口
EXPOSE 3001 8080

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=3001
ENV STATIC_PORT=8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 直接启动服务（后端 + 前端）
CMD ["sh", "-c", "node server/index.js & node server/server-static.js & wait"]

