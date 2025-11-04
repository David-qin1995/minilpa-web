import { spawn } from 'child_process'

/**
 * LPA 硬件服务类 - 真实读卡器版本
 * 
 * 使用 lpac 工具与物理读卡器通信
 */
export class LPAService {
  constructor() {
    // lpac 可执行文件路径
    this.lpacPath = process.env.LPAC_PATH || '/usr/local/bin/lpac'
  }
  
  /**
   * 执行 lpac 命令
   * @param {Array} args 命令参数
   * @returns {Promise<string>} 命令输出
   */
  async execLpac(args) {
    return new Promise((resolve, reject) => {
      console.log(`执行命令: ${this.lpacPath} ${args.join(' ')}`)
      
      const lpac = spawn(this.lpacPath, args)
      let stdout = ''
      let stderr = ''
      
      lpac.stdout.on('data', (data) => {
        stdout += data.toString()
      })
      
      lpac.stderr.on('data', (data) => {
        stderr += data.toString()
      })
      
      lpac.on('close', (code) => {
        if (code === 0) {
          console.log('命令执行成功')
          resolve(stdout)
        } else {
          console.error('命令执行失败:', stderr)
          reject(new Error(`lpac 执行失败 (code ${code}): ${stderr}`))
        }
      })
      
      lpac.on('error', (err) => {
        console.error('命令执行错误:', err)
        reject(new Error(`无法执行 lpac: ${err.message}`))
      })
    })
  }
  
  /**
   * 获取所有配置文件
   */
  async getProfiles() {
    try {
      const output = await this.execLpac(['profile', 'list'])
      return this.parseProfiles(output)
    } catch (error) {
      console.error('获取配置文件失败:', error)
      throw new Error('无法获取配置文件列表')
    }
  }
  
  /**
   * 解析配置文件列表输出
   * 根据 lpac 的实际输出格式调整
   */
  parseProfiles(output) {
    const profiles = []
    const lines = output.split('\n')
    
    // lpac 输出示例（需要根据实际情况调整）:
    // ICCID: 89860123456789012345
    // Name: China Mobile eSIM
    // State: enabled
    // ---
    
    let currentProfile = {}
    
    for (const line of lines) {
      const trimmed = line.trim()
      
      if (trimmed.startsWith('ICCID:')) {
        if (currentProfile.iccid) {
          profiles.push(currentProfile)
        }
        currentProfile = {
          iccid: trimmed.replace('ICCID:', '').trim(),
          name: '',
          provider: '',
          state: 'unknown'
        }
      } else if (trimmed.startsWith('Name:')) {
        currentProfile.name = trimmed.replace('Name:', '').trim()
      } else if (trimmed.startsWith('Provider:') || trimmed.startsWith('Operator:')) {
        currentProfile.provider = trimmed.replace(/Provider:|Operator:/, '').trim()
      } else if (trimmed.startsWith('State:') || trimmed.startsWith('Status:')) {
        const state = trimmed.replace(/State:|Status:/, '').trim().toLowerCase()
        currentProfile.state = state.includes('enable') ? 'enabled' : 'disabled'
      } else if (trimmed === '---' && currentProfile.iccid) {
        profiles.push(currentProfile)
        currentProfile = {}
      }
    }
    
    // 添加最后一个配置文件
    if (currentProfile.iccid) {
      profiles.push(currentProfile)
    }
    
    console.log(`解析到 ${profiles.length} 个配置文件`)
    return profiles
  }
  
  /**
   * 下载配置文件
   */
  async downloadProfile(activationCode) {
    if (!this.validateActivationCode(activationCode)) {
      throw new Error('无效的激活码格式')
    }
    
    try {
      console.log('开始下载配置文件:', activationCode)
      const output = await this.execLpac([
        'profile', 
        'download', 
        '-a', 
        activationCode
      ])
      
      console.log('下载成功:', output)
      
      // 等待一下让配置文件安装完成
      await this.delay(2000)
      
      // 重新获取配置文件列表
      const profiles = await this.getProfiles()
      
      // 返回最新的配置文件
      return profiles[profiles.length - 1]
    } catch (error) {
      console.error('下载配置文件失败:', error)
      throw new Error(`下载失败: ${error.message}`)
    }
  }
  
  /**
   * 启用配置文件
   */
  async enableProfile(iccid) {
    try {
      console.log('启用配置文件:', iccid)
      await this.execLpac(['profile', 'enable', iccid])
      console.log('启用成功')
    } catch (error) {
      console.error('启用配置文件失败:', error)
      throw new Error(`启用失败: ${error.message}`)
    }
  }
  
  /**
   * 禁用配置文件
   */
  async disableProfile(iccid) {
    try {
      console.log('禁用配置文件:', iccid)
      await this.execLpac(['profile', 'disable', iccid])
      console.log('禁用成功')
    } catch (error) {
      console.error('禁用配置文件失败:', error)
      throw new Error(`禁用失败: ${error.message}`)
    }
  }
  
  /**
   * 删除配置文件
   */
  async deleteProfile(iccid) {
    try {
      console.log('删除配置文件:', iccid)
      await this.execLpac(['profile', 'delete', iccid])
      console.log('删除成功')
    } catch (error) {
      console.error('删除配置文件失败:', error)
      throw new Error(`删除失败: ${error.message}`)
    }
  }
  
  /**
   * 设置昵称
   */
  async setNickname(iccid, nickname) {
    try {
      console.log('设置昵称:', iccid, nickname)
      await this.execLpac(['profile', 'nickname', iccid, nickname])
      console.log('昵称设置成功')
    } catch (error) {
      console.error('设置昵称失败:', error)
      throw new Error(`设置昵称失败: ${error.message}`)
    }
  }
  
  /**
   * 获取通知列表
   */
  async getNotifications() {
    try {
      const output = await this.execLpac(['notification', 'list'])
      return this.parseNotifications(output)
    } catch (error) {
      console.error('获取通知失败:', error)
      // 如果不支持通知功能，返回空数组
      return []
    }
  }
  
  /**
   * 解析通知列表
   */
  parseNotifications(output) {
    const notifications = []
    const lines = output.split('\n')
    
    // 根据 lpac 的实际输出格式解析
    // 示例格式可能类似:
    // SeqNumber: 1
    // Operation: install
    // ICCID: 89860123456789012345
    // ---
    
    let currentNotification = {}
    
    for (const line of lines) {
      const trimmed = line.trim()
      
      if (trimmed.startsWith('SeqNumber:') || trimmed.startsWith('Seq:')) {
        if (currentNotification.seqNumber) {
          notifications.push(currentNotification)
        }
        currentNotification = {
          seqNumber: parseInt(trimmed.replace(/SeqNumber:|Seq:/, '').trim()),
          operation: '',
          iccid: '',
          timestamp: new Date().toISOString()
        }
      } else if (trimmed.startsWith('Operation:')) {
        currentNotification.operation = trimmed.replace('Operation:', '').trim()
      } else if (trimmed.startsWith('ICCID:')) {
        currentNotification.iccid = trimmed.replace('ICCID:', '').trim()
      } else if (trimmed === '---' && currentNotification.seqNumber) {
        notifications.push(currentNotification)
        currentNotification = {}
      }
    }
    
    if (currentNotification.seqNumber) {
      notifications.push(currentNotification)
    }
    
    console.log(`解析到 ${notifications.length} 个通知`)
    return notifications
  }
  
  /**
   * 处理通知
   */
  async processNotification(seqNumber, operation) {
    try {
      console.log('处理通知:', seqNumber)
      await this.execLpac(['notification', 'process', String(seqNumber)])
      console.log('通知处理成功')
    } catch (error) {
      console.error('处理通知失败:', error)
      throw new Error(`处理通知失败: ${error.message}`)
    }
  }
  
  /**
   * 移除通知
   */
  async removeNotification(seqNumber) {
    try {
      console.log('删除通知:', seqNumber)
      await this.execLpac(['notification', 'remove', String(seqNumber)])
      console.log('通知删除成功')
    } catch (error) {
      console.error('删除通知失败:', error)
      throw new Error(`删除通知失败: ${error.message}`)
    }
  }
  
  /**
   * 获取芯片信息
   */
  async getChipInfo() {
    try {
      const output = await this.execLpac(['chip', 'info'])
      return this.parseChipInfo(output)
    } catch (error) {
      console.error('获取芯片信息失败:', error)
      throw new Error('无法获取芯片信息')
    }
  }
  
  /**
   * 解析芯片信息
   */
  parseChipInfo(output) {
    // 解析 lpac chip info 的输出
    const eidMatch = output.match(/EID[:\s]+(\w+)/i)
    const manuMatch = output.match(/Manufacturer[:\s]+(.+)/i)
    const modelMatch = output.match(/Model[:\s]+(.+)/i)
    
    const chipInfo = {
      eid: eidMatch ? eidMatch[1].trim() : '',
      manufacturer: manuMatch ? manuMatch[1].trim() : 'Unknown',
      model: modelMatch ? modelMatch[1].trim() : 'Unknown'
    }
    
    console.log('芯片信息:', chipInfo)
    return chipInfo
  }
  
  /**
   * 获取芯片证书
   */
  async getChipCertificate() {
    try {
      const output = await this.execLpac(['chip', 'certificate'])
      return {
        certificate: output
      }
    } catch (error) {
      console.error('获取证书失败:', error)
      return {
        certificate: '无法获取证书信息'
      }
    }
  }
  
  /**
   * 验证激活码格式
   */
  validateActivationCode(code) {
    // LPA 激活码格式: LPA:1$SM-DP+地址$匹配ID
    // 或简化格式: 1$SM-DP+地址$匹配ID
    return code.startsWith('LPA:') || code.startsWith('1$')
  }
  
  /**
   * 延迟函数
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}

