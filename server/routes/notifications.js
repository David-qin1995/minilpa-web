import express from 'express'
import { LPAService } from '../services/lpa.js'

const router = express.Router()
const lpaService = new LPAService()

// 获取所有通知
router.get('/', async (req, res, next) => {
  try {
    const notifications = await lpaService.getNotifications()
    res.json({
      success: true,
      data: notifications
    })
  } catch (error) {
    next(error)
  }
})

// 处理通知
router.post('/process', async (req, res, next) => {
  try {
    const { seqNumber, operation } = req.body
    
    if (!seqNumber) {
      return res.status(400).json({
        success: false,
        message: '序列号不能为空'
      })
    }
    
    await lpaService.processNotification(seqNumber, operation)
    res.json({
      success: true,
      message: '通知已处理'
    })
  } catch (error) {
    next(error)
  }
})

// 删除通知
router.delete('/:seqNumber', async (req, res, next) => {
  try {
    const { seqNumber } = req.params
    await lpaService.removeNotification(seqNumber)
    res.json({
      success: true,
      message: '通知已删除'
    })
  } catch (error) {
    next(error)
  }
})

export { router as notificationRouter }

