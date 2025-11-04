<template>
  <header class="app-header">
    <div class="header-content">
      <div class="logo">
        <img src="/logo.svg" alt="MiniLPA" />
        <h1>{{ langStore.t('app.title') }}</h1>
      </div>

      <nav class="nav-menu">
        <router-link to="/profiles" :class="{ active: route.path === '/profiles' }">
          {{ langStore.t('nav.profiles') }}
        </router-link>
        <router-link to="/notifications" :class="{ active: route.path === '/notifications' }">
          {{ langStore.t('nav.notifications') }}
        </router-link>
        <router-link to="/chip" :class="{ active: route.path === '/chip' }">
          {{ langStore.t('nav.chip') }}
        </router-link>
        <router-link to="/settings" :class="{ active: route.path === '/settings' }">
          {{ langStore.t('nav.settings') }}
        </router-link>
      </nav>

      <div class="header-actions">
        <button @click="themeStore.toggleTheme()" class="icon-btn" :title="langStore.t('settings.theme')">
          <span v-if="themeStore.isDark">🌙</span>
          <span v-else>☀️</span>
        </button>
        <select v-model="currentLang" @change="changeLang" class="lang-select">
          <option value="zh-CN">简体中文</option>
          <option value="en-US">English</option>
          <option value="ja-JP">日本語</option>
        </select>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useThemeStore } from '../stores/theme'
import { useLanguageStore } from '../stores/language'

const route = useRoute()
const themeStore = useThemeStore()
const langStore = useLanguageStore()
const currentLang = ref(langStore.currentLanguage)

onMounted(() => {
  langStore.initLanguage()
  currentLang.value = langStore.currentLanguage
})

function changeLang() {
  langStore.setLanguage(currentLang.value)
}
</script>

<style scoped lang="scss">
.app-header {
  background-color: var(--header-bg);
  border-bottom: 1px solid var(--border-color);
  padding: 0 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.header-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 60px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  
  img {
    width: 32px;
    height: 32px;
  }
  
  h1 {
    font-size: 20px;
    font-weight: 600;
    margin: 0;
    color: var(--text-primary);
  }
}

.nav-menu {
  display: flex;
  gap: 8px;
  
  a {
    padding: 8px 16px;
    border-radius: 6px;
    text-decoration: none;
    color: var(--text-secondary);
    font-weight: 500;
    transition: all 0.2s ease;
    
    &:hover {
      background-color: var(--hover-bg);
      color: var(--text-primary);
    }
    
    &.active {
      background-color: var(--primary-color);
      color: white;
    }
  }
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.icon-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 6px;
  transition: background-color 0.2s ease;
  
  &:hover {
    background-color: var(--hover-bg);
  }
}

.lang-select {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid var(--border-color);
  background-color: var(--input-bg);
  color: var(--text-primary);
  cursor: pointer;
  font-size: 14px;
  
  &:focus {
    outline: none;
    border-color: var(--primary-color);
  }
}
</style>

