<template>
  <!-- DSHB-054 Complete Integration Dashboard -->
  <div class="dashboard-container">
    <header class="dashboard-header">
      <h1 class="dashboard-title">Control Center</h1>
      <div class="dashboard-meta">
        <time class="last-update" :datetime="lastUpdate" aria-live="polite">
          Last updated: {{ formatTime(lastUpdate) }}
        </time>
        <button
          class="refresh-btn"
          @click="refreshAll"
          :disabled="loading"
          aria-label="Refresh all dashboard data"
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" :class="{ spinning: loading }">
            <path d="M8 3a5 5 0 104.546 2.914.5.5 0 00-.908-.417A4 4 0 118 4v1z"/>
            <path d="M8 4.466V.534a.25.25 0 01.41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 018 4.466z"/>
          </svg>
          {{ loading ? 'Refreshing...' : 'Refresh' }}
        </button>
      </div>
    </header>

    <!-- Critical incident alerts at top -->
    <IncidentBanner
      @incident-acknowledged="handleIncidentAcknowledged"
      @incident-snoozed="handleIncidentSnoozed"
      @manage-incidents="openIncidentManagement"
    />

    <!-- Main overview grid OR drill-down view -->
    <OverviewGrid
      v-if="!drillDownProject"
      ref="overviewGrid"
      @project-selected="enterDrillDown"
      :selected-index="selectedProjectIndex"
    />

    <!-- DSHB-059: Deep per-project drill-down quad -->
    <DrillDownView
      v-else
      :project="drillDownProject"
      @exit-drill-down="exitDrillDown"
      ref="drillDownView"
    />

    <!-- Command palette modal (existing) -->
    <CommandPalette
      v-if="showCommandPalette"
      @close="showCommandPalette = false"
    />

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay" aria-live="polite">
      <div class="loading-spinner"></div>
      <span>Refreshing dashboard data...</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import IncidentBanner from './IncidentBanner.vue'
import OverviewGrid from './OverviewGrid.vue'
import CommandPalette from './CommandPalette.vue'
import DrillDownView from './DrillDownView.vue'

// State
const showCommandPalette = ref(false)
const loading = ref(false)
const lastUpdate = ref(new Date().toISOString())

// DSHB-059: Drill-down state
const drillDownProject = ref(null)
const selectedProjectIndex = ref(0)
const projectList = ref([])

// Refs to child components
const overviewGrid = ref(null)
const drillDownView = ref(null)

// Keyboard shortcuts
const handleKeydown = (event) => {
  // Cmd+K or Ctrl+K to open command palette
  if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
    event.preventDefault()
    showCommandPalette.value = true
  }

  // Escape to close command palette or exit drill-down
  if (event.key === 'Escape') {
    if (showCommandPalette.value) {
      showCommandPalette.value = false
    } else if (drillDownProject.value) {
      exitDrillDown()
    }
    return
  }

  // DSHB-059: Project navigation (1-4 keys)
  if (!drillDownProject.value && !showCommandPalette.value) {
    const keyNum = parseInt(event.key)
    if (keyNum >= 1 && keyNum <= 4) {
      event.preventDefault()
      selectProjectByIndex(keyNum - 1)
    }

    // Enter to enter drill-down mode for selected project
    if (event.key === 'Enter') {
      event.preventDefault()
      enterDrillDownForSelected()
    }
  }
}

// Refresh all dashboard data
const refreshAll = async () => {
  if (loading.value) return

  loading.value = true
  try {
    // Refresh overview grid data
    if (overviewGrid.value?.loadOverviewData) {
      await overviewGrid.value.loadOverviewData()
    }

    lastUpdate.value = new Date().toISOString()
  } catch (error) {
    console.error('Failed to refresh dashboard:', error)
  } finally {
    loading.value = false
  }
}

// Incident handlers
const handleIncidentAcknowledged = (incident) => {
  console.log('Incident acknowledged:', incident.id)
  // Future: Update incident status, show toast notification
}

const handleIncidentSnoozed = (incident) => {
  console.log('Incident snoozed:', incident.id)
  // Future: Update incident status, show toast notification
}

const openIncidentManagement = () => {
  console.log('Opening incident management interface')
  // Future: Navigate to dedicated incident management view
}

// DSHB-059: Drill-down methods
const enterDrillDown = (project) => {
  console.log('Entering drill-down mode for project:', project.name)
  drillDownProject.value = project
}

const exitDrillDown = () => {
  console.log('Exiting drill-down mode')
  drillDownProject.value = null
  selectedProjectIndex.value = 0
}

const selectProjectByIndex = (index) => {
  if (overviewGrid.value?.getProjectList) {
    const projects = overviewGrid.value.getProjectList()
    if (projects && index < projects.length) {
      selectedProjectIndex.value = index
      console.log('Selected project index:', index, projects[index]?.name)
    }
  }
}

const enterDrillDownForSelected = () => {
  if (overviewGrid.value?.getProjectList) {
    const projects = overviewGrid.value.getProjectList()
    const selectedProject = projects[selectedProjectIndex.value]
    if (selectedProject) {
      enterDrillDown(selectedProject)
    }
  }
}

// Time formatting
const formatTime = (timestamp) => {
  if (!timestamp) return 'Never'
  return new Date(timestamp).toLocaleTimeString()
}

// Lifecycle
onMounted(() => {
  // Add global keyboard event listener
  document.addEventListener('keydown', handleKeydown)

  // Auto-refresh every 5 minutes
  setInterval(() => {
    if (!loading.value) {
      refreshAll()
    }
  }, 5 * 60 * 1000)
})

onUnmounted(() => {
  // Remove global keyboard event listener
  document.removeEventListener('keydown', handleKeydown)
})

// Expose methods for testing
defineExpose({
  refreshAll,
  showCommandPalette
})
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: #fafafa;
  position: relative;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: white;
  border-bottom: 1px solid #e2e8f0;
  position: sticky;
  top: 0;
  z-index: 10;
}

.dashboard-title {
  font-size: 1.875rem;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0;
}

.dashboard-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.last-update {
  font-size: 0.875rem;
  color: #6b7280;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.refresh-btn:hover:not(:disabled) {
  background: #1d4ed8;
}

.refresh-btn:disabled {
  background: #9ca3af;
  cursor: not-allowed;
}

.refresh-btn:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

.refresh-btn svg.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  z-index: 1000;
  color: #374151;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Mobile responsive */
@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .dashboard-meta {
    width: 100%;
    justify-content: space-between;
  }
}

/* Screen Reader Support */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>