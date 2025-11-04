import express from 'express'
import { LPAService } from '../services/lpa.js'

const router = express.Router()
const lpaService = new LPAService()

// 获取所有配置文件
router.get('/', async (req, res, next) => {
  try {
    const profiles = await lpaService.getProfiles()
    res.json({
      success: true,
      data: profiles
    })
  } catch (error) {
    next(error)
  }
})

// 下载配置文件
router.post('/download', async (req, res, next) => {
  try {
    const { activationCode } = req.body
    
    if (!activationCode) {
      return res.status(400).json({
        success: false,
        message: '激活码不能为空'
      })
    }
    
    const result = await lpaService.downloadProfile(activationCode)
    res.json({
      success: true,
      data: result,
      message: '配置文件下载成功'
    })
  } catch (error) {
    next(error)
  }
})

// 启用配置文件
router.post('/:iccid/enable', async (req, res, next) => {
  try {
    const { iccid } = req.params
    await lpaService.enableProfile(iccid)
    res.json({
      success: true,
      message: '配置文件已启用'
    })
  } catch (error) {
    next(error)
  }
})

// 禁用配置文件
router.post('/:iccid/disable', async (req, res, next) => {
  try {
    const { iccid } = req.params
    await lpaService.disableProfile(iccid)
    res.json({
      success: true,
      message: '配置文件已禁用'
    })
  } catch (error) {
    next(error)
  }
})

// 删除配置文件
router.delete('/:iccid', async (req, res, next) => {
  try {
    const { iccid } = req.params
    await lpaService.deleteProfile(iccid)
    res.json({
      success: true,
      message: '配置文件已删除'
    })
  } catch (error) {
    next(error)
  }
})

// 设置昵称
router.patch('/:iccid', async (req, res, next) => {
  try {
    const { iccid } = req.params
    const { nickname } = req.body
    await lpaService.setNickname(iccid, nickname)
    res.json({
      success: true,
      message: '昵称已更新'
    })
  } catch (error) {
    next(error)
  }
})

export { router as profileRouter }

