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
    
    // 接收在线人数更新（按 IP 统计）
    socket.on('online-count', (count) => {
      console.log('在线人数更新:', count, '(按 IP 统计)')
      onlineCount.value = count
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
  
  return {
    onlineCount,
    isConnected,
    connect,
    disconnect
  }
})

