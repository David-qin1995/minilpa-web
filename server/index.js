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

// 在线用户管理
let onlineUsers = new Set()

// Socket.io 连接处理
io.on('connection', (socket) => {
  // 用户上线
  onlineUsers.add(socket.id)
  console.log(`用户 ${socket.id} 已连接，当前在线人数: ${onlineUsers.size}`)
  
  // 广播在线人数
  io.emit('online-count', onlineUsers.size)
  
  // 监听配置变更
  socket.on('config-change', (data) => {
    console.log('配置变更:', data)
    // 广播给其他用户
    socket.broadcast.emit('config-updated', data)
  })
  
  // 监听 profile 操作
  socket.on('profile-action', (data) => {
    console.log('Profile 操作:', data)
    // 广播给所有用户
    io.emit('profile-changed', data)
  })
  
  // 用户断开连接
  socket.on('disconnect', () => {
    onlineUsers.delete(socket.id)
    console.log(`用户 ${socket.id} 已断开，当前在线人数: ${onlineUsers.size}`)
    // 广播在线人数
    io.emit('online-count', onlineUsers.size)
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

