<template>
  <div class="overview-grid" role="main" aria-label="Service Status Overview">
    <!-- Grid Header -->
    <div class="grid-header">
      <h1 class="grid-title">Control Center Overview</h1>
      <div class="stats-summary" aria-live="polite">
        <div class="stat-item">
          <span class="stat-value">{{ Object.keys(services).length }}</span>
          <span class="stat-label">Services</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ summary.activeIncidents || 0 }}</span>
          <span class="stat-label">Active Incidents</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ summary.totalIncidents || 0 }}</span>
          <span class="stat-label">Total Incidents</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ summary.correlatedGroups || 0 }}</span>
          <span class="stat-label">Correlated Groups</span>
        </div>
      </div>
    </div>

    <!-- Dense Grid (Plausible-style) -->
    <div class="dense-grid" role="grid" aria-label="Service Status Dense Grid">
      <div class="grid-headers" role="row">
        <div class="header-cell" role="columnheader">Service</div>
        <div class="header-cell" role="columnheader">Status</div>
        <div class="header-cell" role="columnheader">Last Deploy</div>
        <div class="header-cell" role="columnheader">Last Commit</div>
        <div class="header-cell" role="columnheader">Uptime</div>
        <div class="header-cell" role="columnheader">Incidents</div>
        <div class="header-cell" role="columnheader">Actions</div>
      </div>

      <div
        v-for="(serviceData, serviceName, index) in services"
        :key="serviceName"
        class="grid-row"
        role="row"
        :class="[
          `status-${getServiceStatus(serviceData)}`,
          { 'selected': selectedIndex === index }
        ]"
        @click="selectProject(serviceName, serviceData, index)"
      >
        <div class="grid-cell service-cell" role="gridcell">
          <div class="status-dot" :class="`status-${getServiceStatus(serviceData)}`"></div>
          <span class="service-name">{{ serviceName }}</span>
        </div>

        <div class="grid-cell status-cell" role="gridcell">
          <span class="status-text">{{ getServiceStatus(serviceData) }}</span>
        </div>

        <div class="grid-cell deploy-cell" role="gridcell">
          <div class="deploy-info">
            <div class="deploy-sparkline">📊</div>
            <time class="deploy-time" :datetime="getDeployTime(serviceData)">
              {{ formatRelativeTime(getDeployTime(serviceData)) }}
            </time>
          </div>
        </div>

        <div class="grid-cell commit-cell" role="gridcell">
          <div class="commit-info">
            <code class="commit-sha">{{ getCommitSha(serviceData) }}</code>
            <div class="verified-badge" v-if="isCommitVerified(serviceData)">✓</div>
          </div>
        </div>

        <div class="grid-cell uptime-cell" role="gridcell">
          <span class="uptime-percentage">{{ getUptime(serviceData) }}%</span>
        </div>

        <div class="grid-cell incidents-cell" role="gridcell">
          <span class="incidents-count" :class="{ 'has-incidents': getIncidentCount(serviceData) > 0 }">
            {{ getIncidentCount(serviceData) }}
          </span>
        </div>

        <div class="grid-cell actions-cell" role="gridcell">
          <button
            class="action-btn primary"
            @click="focusService(serviceName)"
            :aria-label="`Focus on ${serviceName} service`"
          >
            Focus
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state" aria-live="polite">
      <div class="spinner"></div>
      <span>Loading service overview...</span>
    </div>

    <!-- Error State -->
    <div v-if="error" class="error-state" role="alert" aria-live="assertive">
      <h3>Failed to load service overview</h3>
      <p>{{ error }}</p>
      <button class="retry-btn" @click="loadOverviewData">Retry</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

// Props
const props = defineProps({
  selectedIndex: {
    type: Number,
    default: 0
  }
})

// Emits
const emit = defineEmits(['project-selected'])

// State
const loading = ref(false)
const error = ref(null)
const services = ref({})
const summary = ref({})
const lastUpdate = ref(null)

// Auto-refresh interval
let refreshInterval = null

// Data loading with real backend integration
const loadOverviewData = async () => {
  loading.value = true
  error.value = null

  try {
    const response = await fetch('http://localhost:3001/api/overview')
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    const data = await response.json()
    services.value = data.services || {}
    summary.value = data.summary || {}
    lastUpdate.value = new Date().toISOString()

  } catch (err) {
    error.value = err.message
    console.error('Overview data loading error:', err)

    // Fallback to minimal mock data on complete failure
    services.value = {
      'control-center-backend': 'operational',
      'ecosystem-dashboard': 'not-configured',
      'declaration-app': 'not-configured'
    }
    summary.value = {
      totalIncidents: 0,
      activeIncidents: 0,
      acknowledgedIncidents: 0,
      correlatedGroups: 0
    }
  } finally {
    loading.value = false
  }
}

// Service status logic
const getServiceStatus = (serviceData) => {
  if (typeof serviceData === 'string') return serviceData
  if (serviceData?.status) return serviceData.status
  return 'unknown'
}

const getServiceStatusColor = (status) => {
  const statusMap = {
    'operational': 'healthy',
    'not-configured': 'warning',
    'error': 'critical',
    'unknown': 'unknown'
  }
  return statusMap[status] || 'unknown'
}

const getDeployTime = (serviceData) => {
  if (serviceData?.lastDeploy) return serviceData.lastDeploy
  return new Date().toISOString() // Mock data
}

const getCommitSha = (serviceData) => {
  if (serviceData?.lastCommit) return serviceData.lastCommit.slice(0, 7)
  return 'abc1234' // Mock data
}

const isCommitVerified = (serviceData) => {
  return serviceData?.verified || false
}

const getUptime = (serviceData) => {
  if (serviceData?.uptime) return serviceData.uptime
  return '99.9' // Mock data
}

const getIncidentCount = (serviceData) => {
  if (serviceData?.incidents) return serviceData.incidents
  return 0
}

// Time formatting
const formatRelativeTime = (timestamp) => {
  if (!timestamp) return 'Never'

  const now = new Date()
  const time = new Date(timestamp)
  const diffMs = now - time
  const diffMins = Math.floor(diffMs / (1000 * 60))

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins}m ago`
  const diffHours = Math.floor(diffMins / 60)
  if (diffHours < 24) return `${diffHours}h ago`
  return `${Math.floor(diffHours / 24)}d ago`
}

// DSHB-059: Project selection for drill-down
const selectProject = (serviceName, serviceData, index) => {
  console.log('Project selected for drill-down:', serviceName)

  const project = {
    name: serviceName,
    status: getServiceStatus(serviceData),
    data: serviceData,
    index: index
  }

  emit('project-selected', project)
}

const getProjectList = () => {
  return Object.keys(services.value).map((serviceName, index) => ({
    name: serviceName,
    status: getServiceStatus(services.value[serviceName]),
    data: services.value[serviceName],
    index: index
  }))
}

// Service interaction (legacy - kept for compatibility)
const focusService = (serviceName) => {
  console.log('Focusing on service:', serviceName)
  // Future: Emit event for parent to handle service focus
}

// Lifecycle
onMounted(() => {
  loadOverviewData()

  // Auto-refresh every 30 seconds
  refreshInterval = setInterval(loadOverviewData, 30000)
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})

// Expose data for testing and drill-down integration
defineExpose({
  loadOverviewData,
  getProjectList,
  services,
  summary,
  loading,
  error
})
</script>

<style scoped>
.overview-grid {
  padding: 1.5rem;
  background: #fafafa;
  min-height: 100vh;
}

.grid-header {
  margin-bottom: 2rem;
}

.grid-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 1rem 0;
}

.stats-summary {
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem 1.5rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  min-width: 120px;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #2563eb;
}

.stat-label {
  font-size: 0.875rem;
  color: #64748b;
  margin-top: 0.25rem;
  text-align: center;
}

/* Dense Grid */
.dense-grid {
  background: white;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow-x: auto;
}

.grid-headers {
  display: grid;
  grid-template-columns: 2fr 1fr 1.5fr 1.5fr 1fr 1fr 1fr;
  background: #f8fafc;
  border-bottom: 2px solid #e2e8f0;
  font-weight: 600;
  color: #374151;
}

.header-cell {
  padding: 1rem;
  border-right: 1px solid #e2e8f0;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.header-cell:last-child {
  border-right: none;
}

.grid-row {
  display: grid;
  grid-template-columns: 2fr 1fr 1.5fr 1.5fr 1fr 1fr 1fr;
  border-bottom: 1px solid #e2e8f0;
  transition: background-color 0.2s ease;
  cursor: pointer;
}

.grid-row:hover {
  background: #f8fafc;
}

.grid-row.selected {
  background: #dbeafe;
  border-color: #2563eb;
  box-shadow: inset 3px 0 0 #2563eb;
}

.grid-row:last-child {
  border-bottom: none;
}

.grid-cell {
  padding: 1rem;
  border-right: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  font-size: 0.875rem;
}

.grid-cell:last-child {
  border-right: none;
}

/* Service Cell */
.service-cell {
  gap: 0.5rem;
}

.status-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-dot.status-operational {
  background: #10b981;
}

.status-dot.status-not-configured {
  background: #f59e0b;
}

.status-dot.status-error {
  background: #ef4444;
}

.status-dot.status-unknown {
  background: #9ca3af;
}

.service-name {
  font-weight: 500;
  color: #374151;
}

/* Status Cell */
.status-text {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: capitalize;
}

.status-operational .status-text {
  background: #d1fae5;
  color: #065f46;
}

.status-not-configured .status-text {
  background: #fef3c7;
  color: #92400e;
}

.status-error .status-text {
  background: #fee2e2;
  color: #991b1b;
}

.status-unknown .status-text {
  background: #f3f4f6;
  color: #374151;
}

/* Deploy Cell */
.deploy-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.deploy-sparkline {
  font-size: 0.75rem;
}

.deploy-time {
  color: #6b7280;
  font-size: 0.75rem;
}

/* Commit Cell */
.commit-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.commit-sha {
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.75rem;
  background: #f3f4f6;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  color: #374151;
}

.verified-badge {
  color: #10b981;
  font-weight: 600;
}

/* Uptime Cell */
.uptime-percentage {
  font-weight: 500;
  color: #374151;
}

/* Incidents Cell */
.incidents-count {
  font-weight: 500;
  color: #6b7280;
}

.incidents-count.has-incidents {
  color: #ef4444;
  background: #fee2e2;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

/* Actions Cell */
.action-btn {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
}

.action-btn.primary {
  background: #2563eb;
  color: white;
}

.action-btn.primary:hover {
  background: #1d4ed8;
}

.action-btn.primary:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

/* Loading State */
.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 2rem;
  color: #6b7280;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #e5e7eb;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Error State */
.error-state {
  background: #fee2e2;
  border: 1px solid #fecaca;
  border-radius: 8px;
  padding: 1.5rem;
  margin: 1rem 0;
  color: #991b1b;
}

.error-state h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.125rem;
  font-weight: 600;
}

.error-state p {
  margin: 0 0 1rem 0;
}

.retry-btn {
  background: #dc2626;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.retry-btn:hover {
  background: #b91c1c;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .grid-headers,
  .grid-row {
    grid-template-columns: 2fr 1fr 1fr 1fr 1fr 1fr 1fr;
  }
}

@media (max-width: 768px) {
  .overview-grid {
    padding: 1rem;
  }

  .stats-summary {
    justify-content: center;
  }

  .dense-grid {
    overflow-x: scroll;
  }

  .grid-headers,
  .grid-row {
    min-width: 800px;
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