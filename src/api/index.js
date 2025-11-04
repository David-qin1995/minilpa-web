import axios from 'axios'

const instance = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
instance.interceptors.request.use(
  config => {
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
instance.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    console.error('API 错误:', error)
    return Promise.reject(error)
  }
)

const api = {
  // 配置文件管理
  getProfiles: () => instance.get('/profiles'),
  downloadProfile: (activationCode) => instance.post('/profiles/download', { activationCode }),
  enableProfile: (iccid) => instance.post(`/profiles/${iccid}/enable`),
  disableProfile: (iccid) => instance.post(`/profiles/${iccid}/disable`),
  deleteProfile: (iccid) => instance.delete(`/profiles/${iccid}`),
  setProfileNickname: (iccid, nickname) => instance.patch(`/profiles/${iccid}`, { nickname }),

  // 通知管理
  getNotifications: () => instance.get('/notifications'),
  processNotification: (seqNumber, operation) => 
    instance.post('/notifications/process', { seqNumber, operation }),
  removeNotification: (seqNumber) => instance.delete(`/notifications/${seqNumber}`),

  // 芯片信息
  getChipInfo: () => instance.get('/chip/info'),
  getChipCertificate: () => instance.get('/chip/certificate'),

  // 二维码解析
  parseQRCode: (imageData) => instance.post('/qrcode/parse', { imageData })
}

export default api

