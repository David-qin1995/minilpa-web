import express from 'express'
import cors from 'cors'
import { profileRouter } from './routes/profiles.js'
import { notificationRouter } from './routes/notifications.js'
import { chipRouter } from './routes/chip.js'
import { qrcodeRouter } from './routes/qrcode.js'

const app = express()
const PORT = process.env.PORT || 3001

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

app.listen(PORT, () => {
  console.log(`后端服务运行在端口 ${PORT}`)
  console.log(`健康检查: http://localhost:${PORT}/api/health`)
})

