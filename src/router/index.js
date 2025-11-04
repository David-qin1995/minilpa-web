import { createRouter, createWebHistory } from 'vue-router'
import ProfileView from '../views/ProfileView.vue'
import NotificationView from '../views/NotificationView.vue'
import ChipView from '../views/ChipView.vue'
import SettingsView from '../views/SettingsView.vue'

const routes = [
  {
    path: '/',
    redirect: '/profiles'
  },
  {
    path: '/profiles',
    name: 'Profiles',
    component: ProfileView
  },
  {
    path: '/notifications',
    name: 'Notifications',
    component: NotificationView
  },
  {
    path: '/chip',
    name: 'Chip',
    component: ChipView
  },
  {
    path: '/settings',
    name: 'Settings',
    component: SettingsView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router

