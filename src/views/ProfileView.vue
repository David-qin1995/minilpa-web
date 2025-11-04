<template>
  <div class="profile-view">
    <div class="view-header">
      <h2>{{ langStore.t('profile.title') }}</h2>
      <button @click="refreshProfiles" class="btn btn-primary">
        🔄 {{ langStore.t('profile.refresh') }}
      </button>
    </div>

    <div class="download-section">
      <div 
        class="drop-area" 
        :class="{ 'drag-over': isDragOver }"
        @drop="handleDrop"
        @dragover.prevent="isDragOver = true"
        @dragleave="isDragOver = false"
        @paste="handlePaste"
      >
        <input 
          v-model="activationCode" 
          type="text" 
          :placeholder="langStore.t('profile.downloadPlaceholder')"
          class="activation-input"
        />
        <button @click="downloadProfile" class="btn btn-success" :disabled="!activationCode || esimStore.loading">
          {{ langStore.t('profile.downloadBtn') }}
        </button>
      </div>
    </div>

    <div class="search-box">
      <input 
        v-model="searchQuery" 
        type="text" 
        :placeholder="langStore.t('profile.search')"
        class="search-input"
      />
    </div>

    <div v-if="esimStore.loading" class="loading">
      {{ langStore.t('common.loading') }}
    </div>

    <div v-else-if="filteredProfiles.length === 0" class="empty-state">
      {{ langStore.t('profile.noProfiles') }}
    </div>

    <div v-else class="profile-list">
      <div v-for="profile in filteredProfiles" :key="profile.iccid" class="profile-card">
        <div class="profile-header">
          <div class="profile-icon">📱</div>
          <div class="profile-info">
            <h3>{{ profile.name || profile.iccid }}</h3>
            <p class="provider">{{ profile.provider }}</p>
          </div>
          <span :class="['status-badge', profile.state]">
            {{ profile.state === 'enabled' ? langStore.t('profile.status_enabled') : langStore.t('profile.status_disabled') }}
          </span>
        </div>

        <div class="profile-details">
          <div class="detail-item">
            <span class="label">{{ langStore.t('profile.iccid') }}:</span>
            <span class="value">{{ profile.iccid }}</span>
            <button @click="copyToClipboard(profile.iccid)" class="copy-btn" title="复制">📋</button>
          </div>
        </div>

        <div class="profile-actions">
          <button 
            v-if="profile.state === 'disabled'" 
            @click="enableProfile(profile.iccid)" 
            class="btn btn-sm btn-success"
          >
            {{ langStore.t('profile.enable') }}
          </button>
          <button 
            v-if="profile.state === 'enabled'" 
            @click="disableProfile(profile.iccid)" 
            class="btn btn-sm btn-warning"
          >
            {{ langStore.t('profile.disable') }}
          </button>
          <button @click="editNickname(profile)" class="btn btn-sm btn-secondary">
            {{ langStore.t('profile.edit') }}
          </button>
          <button @click="deleteProfile(profile.iccid)" class="btn btn-sm btn-danger">
            {{ langStore.t('profile.delete') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useEsimStore } from '../stores/esim'
import { useLanguageStore } from '../stores/language'
import { useOnlineStore } from '../stores/online'

const esimStore = useEsimStore()
const langStore = useLanguageStore()
const onlineStore = useOnlineStore()

const activationCode = ref('')
const searchQuery = ref('')
const isDragOver = ref(false)

const filteredProfiles = computed(() => {
  if (!searchQuery.value) return esimStore.profiles
  const query = searchQuery.value.toLowerCase()
  return esimStore.profiles.filter(p => 
    p.name?.toLowerCase().includes(query) || 
    p.iccid.toLowerCase().includes(query) ||
    p.provider?.toLowerCase().includes(query)
  )
})

onMounted(() => {
  refreshProfiles()
  
  // 监听其他用户的操作
  window.addEventListener('profile-changed', handleProfileChanged)
})

onUnmounted(() => {
  window.removeEventListener('profile-changed', handleProfileChanged)
})

function handleProfileChanged(event) {
  console.log('检测到其他用户的操作:', event.detail)
  // 刷新 profile 列表
  refreshProfiles()
}

async function refreshProfiles() {
  try {
    await esimStore.fetchProfiles()
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function downloadProfile() {
  if (!activationCode.value) return
  
  try {
    await esimStore.downloadProfile(activationCode.value)
    // 广播操作给其他用户
    onlineStore.emitProfileAction('download', { activationCode: activationCode.value })
    activationCode.value = ''
    alert(langStore.t('message.downloadSuccess'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function enableProfile(iccid) {
  try {
    await esimStore.enableProfile(iccid)
    // 广播操作给其他用户
    onlineStore.emitProfileAction('enable', { iccid })
    alert(langStore.t('message.enableSuccess'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function disableProfile(iccid) {
  try {
    await esimStore.disableProfile(iccid)
    // 广播操作给其他用户
    onlineStore.emitProfileAction('disable', { iccid })
    alert(langStore.t('message.disableSuccess'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function deleteProfile(iccid) {
  if (!confirm(langStore.t('message.deleteConfirm'))) return
  
  try {
    await esimStore.deleteProfile(iccid)
    // 广播操作给其他用户
    onlineStore.emitProfileAction('delete', { iccid })
    alert(langStore.t('message.deleteSuccess'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

function editNickname(profile) {
  const newName = prompt(langStore.t('profile.edit'), profile.name)
  if (newName !== null && newName !== profile.name) {
    // TODO: 实现昵称修改
    console.log('Edit nickname:', profile.iccid, newName)
  }
}

function handleDrop(e) {
  e.preventDefault()
  isDragOver.value = false
  
  const files = e.dataTransfer.files
  if (files.length > 0) {
    const file = files[0]
    if (file.type.startsWith('image/')) {
      parseQRCode(file)
    }
  }
  
  const text = e.dataTransfer.getData('text')
  if (text && text.startsWith('LPA:')) {
    activationCode.value = text
  }
}

function handlePaste(e) {
  const items = e.clipboardData?.items
  if (!items) return
  
  for (let item of items) {
    if (item.type.startsWith('image/')) {
      const file = item.getAsFile()
      if (file) {
        parseQRCode(file)
        e.preventDefault()
      }
    }
  }
}

async function parseQRCode(file) {
  // TODO: 实现二维码解析
  console.log('Parse QR code:', file.name)
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    alert(langStore.t('message.copySuccess'))
  })
}
</script>

<style scoped lang="scss">
.profile-view {
  padding: 20px;
}

.view-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  
  h2 {
    margin: 0;
    color: var(--text-primary);
  }
}

.download-section {
  margin-bottom: 24px;
}

.drop-area {
  display: flex;
  gap: 12px;
  padding: 20px;
  border: 2px dashed var(--border-color);
  border-radius: 8px;
  background-color: var(--card-bg);
  transition: all 0.2s ease;
  
  &.drag-over {
    border-color: var(--primary-color);
    background-color: var(--primary-color-light);
  }
}

.activation-input {
  flex: 1;
  padding: 10px 16px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  background-color: var(--input-bg);
  color: var(--text-primary);
  
  &:focus {
    outline: none;
    border-color: var(--primary-color);
  }
}

.search-box {
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 10px 16px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  background-color: var(--input-bg);
  color: var(--text-primary);
  
  &:focus {
    outline: none;
    border-color: var(--primary-color);
  }
}

.loading, .empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
}

.profile-list {
  display: grid;
  gap: 16px;
}

.profile-card {
  background-color: var(--card-bg);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.profile-icon {
  font-size: 32px;
}

.profile-info {
  flex: 1;
  
  h3 {
    margin: 0 0 4px 0;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .provider {
    margin: 0;
    font-size: 14px;
    color: var(--text-secondary);
  }
}

.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  
  &.enabled {
    background-color: #d4edda;
    color: #155724;
  }
  
  &.disabled {
    background-color: #f8d7da;
    color: #721c24;
  }
}

.profile-details {
  margin-bottom: 16px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
  
  .label {
    font-weight: 500;
    color: var(--text-secondary);
  }
  
  .value {
    flex: 1;
    font-family: monospace;
    color: var(--text-primary);
  }
}

.copy-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  opacity: 0.6;
  transition: opacity 0.2s ease;
  
  &:hover {
    opacity: 1;
  }
}

.profile-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
</style>

