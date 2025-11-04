import { defineStore } from 'pinia'
import { ref } from 'vue'
import { io } from 'socket.io-client'

export const useOnlineStore = defineStore('online', () => {
  // 在线人数
  const onlineCount = ref(0)
  
  // Socket 连接状态
  const isConnected = ref(false)
  
  // Socket 实例
  let socket = null
  
  // 连接 WebSocket
  const connect = () => {
    if (socket?.connected) {
      return
    }
    
    // 连接到后端 WebSocket
    const socketUrl = import.meta.env.PROD 
      ? window.location.origin 
      : 'http://localhost:3001'
    
    socket = io(socketUrl, {
      transports: ['websocket', 'polling']
    })
    
    // 连接成功
    socket.on('connect', () => {
      console.log('WebSocket 已连接')
      isConnected.value = true
    })
    
    // 接收在线人数更新
    socket.on('online-count', (count) => {
      console.log('在线人数更新:', count)
      onlineCount.value = count
    })
    
    // 接收配置更新
    socket.on('config-updated', (data) => {
      console.log('配置已更新:', data)
      // 可以触发页面刷新或显示通知
    })
    
    // 接收 profile 变更
    socket.on('profile-changed', (data) => {
      console.log('Profile 已变更:', data)
      // 触发 profile 列表刷新
      window.dispatchEvent(new CustomEvent('profile-changed', { detail: data }))
    })
    
    // 断开连接
    socket.on('disconnect', () => {
      console.log('WebSocket 已断开')
      isConnected.value = false
    })
    
    // 连接错误
    socket.on('connect_error', (error) => {
      console.error('WebSocket 连接错误:', error)
      isConnected.value = false
    })
  }
  
  // 断开连接
  const disconnect = () => {
    if (socket) {
      socket.disconnect()
      socket = null
    }
  }
  
  // 发送配置变更
  const emitConfigChange = (data) => {
    if (socket?.connected) {
      socket.emit('config-change', data)
    }
  }
  
  // 发送 profile 操作
  const emitProfileAction = (action, profile) => {
    if (socket?.connected) {
      socket.emit('profile-action', { action, profile, timestamp: Date.now() })
    }
  }
  
  return {
    onlineCount,
    isConnected,
    connect,
    disconnect,
    emitConfigChange,
    emitProfileAction
  }
})

