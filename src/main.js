import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './styles/main.scss'
import { useOnlineStore } from './stores/online'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.mount('#app')

// 初始化 WebSocket 连接
const onlineStore = useOnlineStore()
onlineStore.connect()

// 页面卸载时断开连接
window.addEventListener('beforeunload', () => {
  onlineStore.disconnect()
})

