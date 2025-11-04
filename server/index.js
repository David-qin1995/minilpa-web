import express from 'express'
import { createServer } from 'http'
import { Server } from 'socket.io'
import cors from 'cors'
import { profileRouter } from './routes/profiles.js'
import { notificationRouter } from './routes/notifications.js'
import { chipRouter } from './routes/chip.js'
import { qrcodeRouter } from './routes/qrcode.js'

const app = express()
const httpServer = createServer(app)
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
})

const PORT = process.env.PORT || 3001

// 在线用户管理（按 IP 统计）
const onlineUsers = new Map() // Map<ip, Set<socketId>>

// 获取客户端真实 IP
function getClientIP(socket) {
  // 优先从 x-forwarded-for 获取（通过代理/负载均衡时）
  const forwarded = socket.handshake.headers['x-forwarded-for']
  if (forwarded) {
    return forwarded.split(',')[0].trim()
  }
  // 从 x-real-ip 获取
  const realIP = socket.handshake.headers['x-real-ip']
  if (realIP) {
    return realIP
  }
  // 直接连接的 IP
  return socket.handshake.address
}

// Socket.io 连接处理
io.on('connection', (socket) => {
  // 获取客户端 IP
  const clientIP = getClientIP(socket)
  
  // 添加到在线用户
  if (!onlineUsers.has(clientIP)) {
    onlineUsers.set(clientIP, new Set())
  }
  onlineUsers.get(clientIP).add(socket.id)
  
  // 统计在线 IP 数量
  const onlineCount = onlineUsers.size
  
  console.log(`用户连接 [IP: ${clientIP}] [Socket: ${socket.id}]`)
  console.log(`当前在线人数: ${onlineCount} (按 IP 统计)`)
  
  // 广播在线人数（按 IP 统计）
  io.emit('online-count', onlineCount)
  
  // 用户断开连接
  socket.on('disconnect', () => {
    // 从该 IP 的连接集合中移除
    if (onlineUsers.has(clientIP)) {
      onlineUsers.get(clientIP).delete(socket.id)
      
      // 如果该 IP 没有任何连接了，移除该 IP
      if (onlineUsers.get(clientIP).size === 0) {
        onlineUsers.delete(clientIP)
      }
    }
    
    const onlineCount = onlineUsers.size
    console.log(`用户断开 [IP: ${clientIP}] [Socket: ${socket.id}]`)
    console.log(`当前在线人数: ${onlineCount} (按 IP 统计)`)
    
    // 广播在线人数
    io.emit('online-count', onlineCount)
  })
})

// 导出 io 供其他路由使用
export { io }

// 中间件
app.use(cors())
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// 日志中间件
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`)
  next()
})

// API 路由
app.use('/api/profiles', profileRouter)
app.use('/api/notifications', notificationRouter)
app.use('/api/chip', chipRouter)
app.use('/api/qrcode', qrcodeRouter)

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// 错误处理
app.use((err, req, res, next) => {
  console.error('错误:', err)
  res.status(500).json({
    success: false,
    message: err.message || '服务器内部错误'
  })
})

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在'
  })
})

httpServer.listen(PORT, () => {
  console.log(`后端服务运行在端口 ${PORT}`)
  console.log(`健康检查: http://localhost:${PORT}/api/health`)
  console.log(`WebSocket 服务已启动`)
})

