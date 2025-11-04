<template>
  <div class="settings-view">
    <div class="view-header">
      <h2>{{ langStore.t('settings.title') }}</h2>
    </div>

    <div class="settings-content">
      <div class="setting-section">
        <h3>{{ langStore.t('settings.theme') }}</h3>
        <div class="setting-item">
          <label>
            <input type="radio" value="light" v-model="selectedTheme" @change="changeTheme" />
            {{ langStore.t('settings.themeLight') }}
          </label>
          <label>
            <input type="radio" value="dark" v-model="selectedTheme" @change="changeTheme" />
            {{ langStore.t('settings.themeDark') }}
          </label>
          <label>
            <input type="radio" value="auto" v-model="selectedTheme" @change="changeTheme" />
            {{ langStore.t('settings.themeAuto') }}
          </label>
        </div>
      </div>

      <div class="setting-section">
        <h3>{{ langStore.t('settings.language') }}</h3>
        <div class="setting-item">
          <select v-model="selectedLang" @change="changeLang" class="setting-select">
            <option value="zh-CN">简体中文</option>
            <option value="en-US">English</option>
            <option value="ja-JP">日本語</option>
          </select>
        </div>
      </div>

      <div class="setting-section">
        <h3>{{ langStore.t('settings.behavior') }}</h3>
        <div class="setting-item">
          <label class="checkbox-label">
            <input type="checkbox" v-model="settings.autoSendNotification" />
            {{ langStore.t('settings.autoSendNotification') }}
          </label>
          <label class="checkbox-label">
            <input type="checkbox" v-model="settings.autoRemoveNotification" />
            {{ langStore.t('settings.autoRemoveNotification') }}
          </label>
          <label class="checkbox-label">
            <input type="checkbox" v-model="settings.confirmDelete" />
            {{ langStore.t('settings.confirmDelete') }}
          </label>
        </div>
      </div>

      <div class="setting-actions">
        <button @click="saveSettings" class="btn btn-primary">
          {{ langStore.t('common.save') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useThemeStore } from '../stores/theme'
import { useLanguageStore } from '../stores/language'

const themeStore = useThemeStore()
const langStore = useLanguageStore()

const selectedTheme = ref('auto')
const selectedLang = ref('zh-CN')
const settings = ref({
  autoSendNotification: false,
  autoRemoveNotification: false,
  confirmDelete: true
})

onMounted(() => {
  loadSettings()
})

function loadSettings() {
  selectedTheme.value = localStorage.getItem('theme') || 'auto'
  selectedLang.value = langStore.currentLanguage
  
  const savedSettings = localStorage.getItem('settings')
  if (savedSettings) {
    try {
      settings.value = JSON.parse(savedSettings)
    } catch (e) {
      console.error('加载设置失败:', e)
    }
  }
}

function changeTheme() {
  if (selectedTheme.value === 'auto') {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    themeStore.setTheme(prefersDark ? 'dark' : 'light')
  } else {
    themeStore.setTheme(selectedTheme.value)
  }
  localStorage.setItem('theme', selectedTheme.value)
}

function changeLang() {
  langStore.setLanguage(selectedLang.value)
}

function saveSettings() {
  localStorage.setItem('settings', JSON.stringify(settings.value))
  alert(langStore.t('common.success'))
}
</script>

<style scoped lang="scss">
.settings-view {
  padding: 20px;
}

.view-header {
  margin-bottom: 24px;
  
  h2 {
    margin: 0;
    color: var(--text-primary);
  }
}

.settings-content {
  max-width: 800px;
}

.setting-section {
  background-color: var(--card-bg);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 20px;
  
  h3 {
    margin: 0 0 16px 0;
    font-size: 18px;
    color: var(--text-primary);
  }
}

.setting-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
  
  label {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px;
    border-radius: 6px;
    cursor: pointer;
    transition: background-color 0.2s ease;
    color: var(--text-primary);
    
    &:hover {
      background-color: var(--hover-bg);
    }
  }
  
  input[type="radio"],
  input[type="checkbox"] {
    cursor: pointer;
  }
}

.setting-select {
  padding: 10px 16px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  background-color: var(--input-bg);
  color: var(--text-primary);
  font-size: 14px;
  cursor: pointer;
  
  &:focus {
    outline: none;
    border-color: var(--primary-color);
  }
}

.checkbox-label {
  user-select: none;
}

.setting-actions {
  margin-top: 24px;
}
</style>

