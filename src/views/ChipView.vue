<template>
  <div class="chip-view">
    <div class="view-header">
      <h2>{{ langStore.t('chip.title') }}</h2>
      <button @click="refreshChipInfo" class="btn btn-primary">
        🔄 {{ langStore.t('profile.refresh') }}
      </button>
    </div>

    <div v-if="esimStore.loading" class="loading">
      {{ langStore.t('common.loading') }}
    </div>

    <div v-else-if="!esimStore.chipInfo" class="empty-state">
      无法读取芯片信息
    </div>

    <div v-else class="chip-info-card">
      <div class="info-section">
        <h3>基本信息</h3>
        <div class="info-grid">
          <div class="info-item">
            <span class="label">{{ langStore.t('chip.eid') }}:</span>
            <span class="value">{{ esimStore.chipInfo.eid }}</span>
            <button @click="copyToClipboard(esimStore.chipInfo.eid)" class="copy-btn">📋</button>
          </div>
          <div class="info-item">
            <span class="label">{{ langStore.t('chip.manufacturer') }}:</span>
            <span class="value">{{ esimStore.chipInfo.manufacturer || 'N/A' }}</span>
          </div>
          <div class="info-item">
            <span class="label">{{ langStore.t('chip.model') }}:</span>
            <span class="value">{{ esimStore.chipInfo.model || 'N/A' }}</span>
          </div>
        </div>
      </div>

      <div class="info-section">
        <h3>{{ langStore.t('chip.certificate') }}</h3>
        <button @click="viewCertificate" class="btn btn-secondary">
          {{ langStore.t('chip.viewCertificate') }}
        </button>
      </div>

      <div v-if="showCertificate" class="certificate-section">
        <pre>{{ certificateData }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useEsimStore } from '../stores/esim'
import { useLanguageStore } from '../stores/language'

const esimStore = useEsimStore()
const langStore = useLanguageStore()

const showCertificate = ref(false)
const certificateData = ref('')

onMounted(() => {
  refreshChipInfo()
})

async function refreshChipInfo() {
  try {
    await esimStore.fetchChipInfo()
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function viewCertificate() {
  showCertificate.value = !showCertificate.value
  if (showCertificate.value && !certificateData.value) {
    // TODO: 获取证书数据
    certificateData.value = 'Certificate data...'
  }
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    alert(langStore.t('message.copySuccess'))
  })
}
</script>

<style scoped lang="scss">
.chip-view {
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

.loading, .empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
}

.chip-info-card {
  background-color: var(--card-bg);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 24px;
}

.info-section {
  margin-bottom: 24px;
  
  &:last-child {
    margin-bottom: 0;
  }
  
  h3 {
    margin: 0 0 16px 0;
    font-size: 18px;
    color: var(--text-primary);
  }
}

.info-grid {
  display: grid;
  gap: 16px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background-color: var(--hover-bg);
  border-radius: 6px;
  
  .label {
    font-weight: 500;
    color: var(--text-secondary);
    min-width: 100px;
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

.certificate-section {
  margin-top: 16px;
  padding: 16px;
  background-color: var(--hover-bg);
  border-radius: 6px;
  
  pre {
    margin: 0;
    font-size: 12px;
    color: var(--text-primary);
    white-space: pre-wrap;
    word-break: break-all;
  }
}
</style>

