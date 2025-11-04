<template>
  <div id="app" :class="[themeStore.theme, { 'dark': themeStore.isDark }]">
    <Header />
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import Header from './components/Header.vue'
import { useThemeStore } from './stores/theme'

const themeStore = useThemeStore()

onMounted(() => {
  themeStore.initTheme()
})
</script>

<style scoped>
#app {
  min-height: 100vh;
  transition: background-color 0.3s ease, color 0.3s ease;
}

.main-content {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}
</style>

