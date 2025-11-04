import { defineStore } from 'pinia'
import { ref } from 'vue'
import zh_CN from '../locales/zh_CN.js'
import en_US from '../locales/en_US.js'
import ja_JP from '../locales/ja_JP.js'

const messages = {
  'zh-CN': zh_CN,
  'en-US': en_US,
  'ja-JP': ja_JP
}

export const useLanguageStore = defineStore('language', () => {
  const currentLanguage = ref('zh-CN')

  function initLanguage() {
    const savedLang = localStorage.getItem('language')
    if (savedLang && messages[savedLang]) {
      currentLanguage.value = savedLang
    } else {
      // 检测浏览器语言
      const browserLang = navigator.language
      if (messages[browserLang]) {
        currentLanguage.value = browserLang
      }
    }
  }

  function setLanguage(lang) {
    if (messages[lang]) {
      currentLanguage.value = lang
      localStorage.setItem('language', lang)
    }
  }

  function t(key) {
    const keys = key.split('.')
    let value = messages[currentLanguage.value]
    
    for (const k of keys) {
      if (value && typeof value === 'object') {
        value = value[k]
      } else {
        return key
      }
    }
    
    return value || key
  }

  return {
    currentLanguage,
    initLanguage,
    setLanguage,
    t
  }
})

