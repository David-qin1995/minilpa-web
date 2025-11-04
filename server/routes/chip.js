import express from 'express'
import { LPAService } from '../services/lpa.js'

const router = express.Router()
const lpaService = new LPAService()

// 获取芯片信息
router.get('/info', async (req, res, next) => {
  try {
    const chipInfo = await lpaService.getChipInfo()
    res.json({
      success: true,
      data: chipInfo
    })
  } catch (error) {
    next(error)
  }
})

// 获取芯片证书
router.get('/certificate', async (req, res, next) => {
  try {
    const certificate = await lpaService.getChipCertificate()
    res.json({
      success: true,
      data: certificate
    })
  } catch (error) {
    next(error)
  }
})

export { router as chipRouter }

