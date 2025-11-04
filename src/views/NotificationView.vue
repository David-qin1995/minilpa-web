<template>
  <div class="notification-view">
    <div class="view-header">
      <h2>{{ langStore.t('notification.title') }}</h2>
      <div class="header-actions">
        <button @click="selectAll" class="btn btn-secondary">
          {{ langStore.t('notification.selectAll') }}
        </button>
        <button @click="removeAll" class="btn btn-danger">
          {{ langStore.t('notification.removeAll') }}
        </button>
      </div>
    </div>

    <div v-if="esimStore.loading" class="loading">
      {{ langStore.t('common.loading') }}
    </div>

    <div v-else-if="esimStore.notifications.length === 0" class="empty-state">
      {{ langStore.t('notification.noNotifications') }}
    </div>

    <div v-else class="notification-list">
      <div 
        v-for="notification in esimStore.notifications" 
        :key="notification.seqNumber" 
        class="notification-card"
        :class="{ 'selected': selectedNotifications.includes(notification.seqNumber) }"
        @click="toggleSelection(notification.seqNumber)"
      >
        <div class="notification-header">
          <input 
            type="checkbox" 
            :checked="selectedNotifications.includes(notification.seqNumber)"
            @click.stop="toggleSelection(notification.seqNumber)"
            class="notification-checkbox"
          />
          <div class="notification-icon">🔔</div>
          <div class="notification-info">
            <h3>{{ langStore.t('notification.profileManagement') }}</h3>
            <p>{{ langStore.t('notification.seqNumber') }}: {{ notification.seqNumber }}</p>
          </div>
        </div>

        <div class="notification-details">
          <p>{{ langStore.t('notification.operation') }}: {{ notification.operation }}</p>
          <p v-if="notification.iccid">ICCID: {{ notification.iccid }}</p>
        </div>

        <div class="notification-actions">
          <button @click.stop="processNotification(notification.seqNumber)" class="btn btn-sm btn-primary">
            {{ langStore.t('notification.process') }}
          </button>
          <button @click.stop="removeNotification(notification.seqNumber)" class="btn btn-sm btn-danger">
            {{ langStore.t('notification.remove') }}
          </button>
        </div>
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

const selectedNotifications = ref([])

onMounted(() => {
  refreshNotifications()
})

async function refreshNotifications() {
  try {
    await esimStore.fetchNotifications()
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

function toggleSelection(seqNumber) {
  const index = selectedNotifications.value.indexOf(seqNumber)
  if (index > -1) {
    selectedNotifications.value.splice(index, 1)
  } else {
    selectedNotifications.value.push(seqNumber)
  }
}

function selectAll() {
  if (selectedNotifications.value.length === esimStore.notifications.length) {
    selectedNotifications.value = []
  } else {
    selectedNotifications.value = esimStore.notifications.map(n => n.seqNumber)
  }
}

async function processNotification(seqNumber) {
  try {
    await esimStore.processNotification(seqNumber, 'process')
    alert(langStore.t('message.notificationProcessed'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function removeNotification(seqNumber) {
  try {
    await esimStore.processNotification(seqNumber, 'remove')
    alert(langStore.t('message.notificationRemoved'))
  } catch (error) {
    alert(langStore.t('common.error'))
  }
}

async function removeAll() {
  if (!confirm('确定要删除所有通知吗？')) return
  
  for (const notification of esimStore.notifications) {
    try {
      await removeNotification(notification.seqNumber)
    } catch (error) {
      console.error('删除通知失败:', notification.seqNumber)
    }
  }
}
</script>

<style scoped lang="scss">
.notification-view {
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

.header-actions {
  display: flex;
  gap: 12px;
}

.loading, .empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
}

.notification-list {
  display: grid;
  gap: 16px;
}

.notification-card {
  background-color: var(--card-bg);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }
  
  &.selected {
    border-color: var(--primary-color);
    background-color: var(--primary-color-light);
  }
}

.notification-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.notification-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.notification-icon {
  font-size: 32px;
}

.notification-info {
  flex: 1;
  
  h3 {
    margin: 0 0 4px 0;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  p {
    margin: 0;
    font-size: 14px;
    color: var(--text-secondary);
  }
}

.notification-details {
  margin-bottom: 16px;
  padding: 12px;
  background-color: var(--hover-bg);
  border-radius: 6px;
  
  p {
    margin: 4px 0;
    font-size: 14px;
    color: var(--text-primary);
  }
}

.notification-actions {
  display: flex;
  gap: 8px;
}
</style>

