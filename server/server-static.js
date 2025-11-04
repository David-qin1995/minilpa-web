import express from 'express'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.STATIC_PORT || 8080

// 静态文件服务
app.use(express.static(path.join(__dirname, '../dist')))

// SPA 路由支持
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../dist/index.html'))
})

app.listen(PORT, () => {
  console.log(`前端静态文件服务运行在端口 ${PORT}`)
})

