import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../api'

export const useEsimStore = defineStore('esim', () => {
  const profiles = ref([])
  const notifications = ref([])
  const chipInfo = ref(null)
  const loading = ref(false)

  async function fetchProfiles() {
    try {
      loading.value = true
      const response = await api.getProfiles()
      profiles.value = response.data
    } catch (error) {
      console.error('获取配置文件失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function fetchNotifications() {
    try {
      loading.value = true
      const response = await api.getNotifications()
      notifications.value = response.data
    } catch (error) {
      console.error('获取通知失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function fetchChipInfo() {
    try {
      loading.value = true
      const response = await api.getChipInfo()
      chipInfo.value = response.data
    } catch (error) {
      console.error('获取芯片信息失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function downloadProfile(activationCode) {
    try {
      loading.value = true
      const response = await api.downloadProfile(activationCode)
      await fetchProfiles()
      return response.data
    } catch (error) {
      console.error('下载配置文件失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function enableProfile(iccid) {
    try {
      loading.value = true
      await api.enableProfile(iccid)
      await fetchProfiles()
    } catch (error) {
      console.error('启用配置文件失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function disableProfile(iccid) {
    try {
      loading.value = true
      await api.disableProfile(iccid)
      await fetchProfiles()
    } catch (error) {
      console.error('禁用配置文件失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function deleteProfile(iccid) {
    try {
      loading.value = true
      await api.deleteProfile(iccid)
      await fetchProfiles()
    } catch (error) {
      console.error('删除配置文件失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function processNotification(seqNumber, operation) {
    try {
      loading.value = true
      await api.processNotification(seqNumber, operation)
      await fetchNotifications()
    } catch (error) {
      console.error('处理通知失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  return {
    profiles,
    notifications,
    chipInfo,
    loading,
    fetchProfiles,
    fetchNotifications,
    fetchChipInfo,
    downloadProfile,
    enableProfile,
    disableProfile,
    deleteProfile,
    processNotification
  }
})

