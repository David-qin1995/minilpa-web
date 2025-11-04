import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useThemeStore = defineStore('theme', () => {
  const theme = ref('light')
  const isDark = computed(() => theme.value === 'dark')

  function initTheme() {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      theme.value = savedTheme
    } else {
      // 检测系统主题
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      theme.value = prefersDark ? 'dark' : 'light'
    }
    applyTheme()
  }

  function toggleTheme() {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
    applyTheme()
    localStorage.setItem('theme', theme.value)
  }

  function setTheme(newTheme) {
    theme.value = newTheme
    applyTheme()
    localStorage.setItem('theme', theme.value)
  }

  function applyTheme() {
    document.documentElement.setAttribute('data-theme', theme.value)
  }

  return {
    theme,
    isDark,
    initTheme,
    toggleTheme,
    setTheme
  }
})

