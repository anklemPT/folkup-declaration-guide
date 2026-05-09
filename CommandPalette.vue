<template>
  <!-- DSHB-056 Command Palette - Enhanced Alice v2.0 Level 3 Implementation -->
  <div
    v-if="isOpen"
    class="command-palette-overlay"
    @click.self="closePalette"
    @keydown.esc="closePalette"
  >
    <div class="command-palette" role="dialog" aria-modal="true" aria-labelledby="command-palette-title">
      <!-- Header -->
      <div class="command-palette__header">
        <h2 id="command-palette-title" class="sr-only">Command Palette</h2>
        <div class="command-palette__search-container">
          <svg class="command-palette__search-icon" width="16" height="16" viewBox="0 0 16 16" aria-hidden="true">
            <path d="M6.5 0C2.91 0 0 2.91 0 6.5S2.91 13 6.5 13c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L17.49 16l-4.99-5H11.7l-.28-.27C12.41 9.59 13 8.11 13 6.5 13 2.91 10.09 0 6.5 0zm0 2C8.99 2 11 4.01 11 6.5S8.99 11 6.5 11 2 8.99 2 6.5 4.01 2 6.5 2z" fill="currentColor"/>
          </svg>
          <input
            ref="searchInput"
            v-model="searchQuery"
            type="text"
            class="command-palette__search-input"
            placeholder="Search projects, actions, incidents..."
            autocomplete="off"
            autocapitalize="off"
            spellcheck="false"
            aria-describedby="search-help"
            @keydown="handleKeyDown"
          />
          <span id="search-help" class="sr-only">Use arrow keys to navigate, Enter to execute, Escape to close</span>
        </div>
      </div>

      <!-- Results -->
      <div class="command-palette__content" role="listbox" aria-label="Search results">
        <div v-if="loading" class="command-palette__loading" aria-live="polite">
          <div class="command-palette__spinner"></div>
          <span>Searching...</span>
        </div>

        <div v-else-if="filteredResults.length === 0 && searchQuery" class="command-palette__no-results" aria-live="polite">
          <span>No results found for "{{ searchQuery }}"</span>
          <p class="command-palette__help-text">Try searching for projects, actions, incidents, or log entries</p>
        </div>

        <div v-else-if="searchQuery === ''" class="command-palette__recent" aria-live="polite">
          <div class="command-palette__section">
            <h3 class="command-palette__section-title">Recent Actions</h3>
            <div class="command-palette__items">
              <button
                v-for="(item, index) in recentItems"
                :key="`recent-${index}`"
                :class="['command-palette__item', { 'command-palette__item--active': selectedIndex === index }]"
                @click="executeCommand(item)"
                @mouseenter="selectedIndex = index"
              >
                <div class="command-palette__item-icon">
                  <component :is="getIcon(item.type)" />
                </div>
                <div class="command-palette__item-content">
                  <div class="command-palette__item-title">{{ item.title }}</div>
                  <div class="command-palette__item-subtitle">{{ item.subtitle }}</div>
                </div>
                <div class="command-palette__item-badge" v-if="item.badge">{{ item.badge }}</div>
              </button>
            </div>
          </div>
        </div>

        <div v-else class="command-palette__results">
          <!-- Projects Section -->
          <div v-if="projectResults.length > 0" class="command-palette__section">
            <h3 class="command-palette__section-title">Projects</h3>
            <div class="command-palette__items">
              <button
                v-for="(project, index) in projectResults"
                :key="`project-${project.id}`"
                :class="['command-palette__item', { 'command-palette__item--active': selectedIndex === getGlobalIndex('project', index) }]"
                @click="executeCommand(project)"
                @mouseenter="selectedIndex = getGlobalIndex('project', index)"
                role="option"
                :aria-selected="selectedIndex === getGlobalIndex('project', index)"
              >
                <div class="command-palette__item-icon">
                  <StatusIcon :status="project.status" />
                </div>
                <div class="command-palette__item-content">
                  <div class="command-palette__item-title">{{ project.name }}</div>
                  <div class="command-palette__item-subtitle">{{ project.description }}</div>
                </div>
                <div class="command-palette__item-meta">
                  <span class="command-palette__item-uptime">{{ project.uptime }}%</span>
                </div>
              </button>
            </div>
          </div>

          <!-- Actions Section -->
          <div v-if="actionResults.length > 0" class="command-palette__section">
            <h3 class="command-palette__section-title">Actions</h3>
            <div class="command-palette__items">
              <button
                v-for="(action, index) in actionResults"
                :key="`action-${action.id}`"
                :class="['command-palette__item', { 'command-palette__item--active': selectedIndex === getGlobalIndex('action', index) }]"
                @click="executeCommand(action)"
                @mouseenter="selectedIndex = getGlobalIndex('action', index)"
                role="option"
                :aria-selected="selectedIndex === getGlobalIndex('action', index)"
              >
                <div class="command-palette__item-icon">
                  <ActionIcon :type="action.type" />
                </div>
                <div class="command-palette__item-content">
                  <div class="command-palette__item-title">{{ action.title }}</div>
                  <div class="command-palette__item-subtitle">{{ action.description }}</div>
                </div>
                <div class="command-palette__item-shortcut" v-if="action.shortcut">{{ action.shortcut }}</div>
              </button>
            </div>
          </div>

          <!-- Incidents Section -->
          <div v-if="incidentResults.length > 0" class="command-palette__section">
            <h3 class="command-palette__section-title">Recent Incidents</h3>
            <div class="command-palette__items">
              <button
                v-for="(incident, index) in incidentResults"
                :key="`incident-${incident.id}`"
                :class="['command-palette__item', { 'command-palette__item--active': selectedIndex === getGlobalIndex('incident', index) }]"
                @click="executeCommand(incident)"
                @mouseenter="selectedIndex = getGlobalIndex('incident', index)"
                role="option"
                :aria-selected="selectedIndex === getGlobalIndex('incident', index)"
              >
                <div class="command-palette__item-icon">
                  <IncidentIcon :severity="incident.severity" />
                </div>
                <div class="command-palette__item-content">
                  <div class="command-palette__item-title">{{ incident.title }}</div>
                  <div class="command-palette__item-subtitle">{{ incident.project }} • {{ formatTime(incident.timestamp) }}</div>
                </div>
                <div class="command-palette__item-badge" :class="`badge--${incident.severity}`">{{ incident.severity }}</div>
              </button>
            </div>
          </div>

          <!-- Log Searches Section -->
          <div v-if="logResults.length > 0" class="command-palette__section">
            <h3 class="command-palette__section-title">Log Searches</h3>
            <div class="command-palette__items">
              <button
                v-for="(log, index) in logResults"
                :key="`log-${log.id}`"
                :class="['command-palette__item', { 'command-palette__item--active': selectedIndex === getGlobalIndex('log', index) }]"
                @click="executeCommand(log)"
                @mouseenter="selectedIndex = getGlobalIndex('log', index)"
                role="option"
                :aria-selected="selectedIndex === getGlobalIndex('log', index)"
              >
                <div class="command-palette__item-icon">
                  <LogIcon />
                </div>
                <div class="command-palette__item-content">
                  <div class="command-palette__item-title">{{ log.query }}</div>
                  <div class="command-palette__item-subtitle">{{ log.container }} • {{ log.matchCount }} matches</div>
                </div>
                <div class="command-palette__item-meta">{{ formatTime(log.lastMatch) }}</div>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="command-palette__footer">
        <div class="command-palette__shortcuts">
          <kbd>↑↓</kbd> to navigate
          <kbd>Enter</kbd> to select
          <kbd>Esc</kbd> to close
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'

// Component Icons (inline SVG components for WCAG compliance)
const StatusIcon = {
  props: ['status'],
  template: `
    <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true">
      <circle cx="6" cy="6" r="6" :fill="getStatusColor(status)" />
    </svg>
  `,
  methods: {
    getStatusColor(status) {
      const colors = {
        'ok': '#10b981', // sage
        'warn': '#f59e0b', // gold-wcag
        'down': '#dc2626', // bordeaux
        'unknown': '#6b7280' // gray
      }
      return colors[status] || colors.unknown
    }
  }
}

const ActionIcon = {
  props: ['type'],
  template: `
    <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor" aria-hidden="true">
      <path v-if="type === 'navigate'" d="M8 2l4 4-4 4v-3H2V5h6V2z" />
      <path v-else-if="type === 'acknowledge'" d="M13 3L6 10 1 5l1.5-1.5L6 7l5.5-5.5L13 3z" />
      <path v-else-if="type === 'copy'" d="M4 2h6c1.1 0 2 .9 2 2v8c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2zm0 2v8h6V4H4z" />
      <path v-else d="M7 2c2.8 0 5 2.2 5 5s-2.2 5-5 5-5-2.2-5-5 2.2-5 5-5z" />
    </svg>
  `
}

const IncidentIcon = {
  props: ['severity'],
  template: `
    <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor" aria-hidden="true">
      <path v-if="severity === 'P0'" d="M7 0l1.5 5H14l-4 3 1.5 5L7 10 2.5 13 4 8 0 5h5.5L7 0z" />
      <path v-else d="M7 1l1 3h3l-2.5 2 1 3L7 7.5 4.5 9l1-3L3 4h3L7 1z" />
    </svg>
  `
}

const LogIcon = {
  template: `
    <svg width="14" height="14" viewBox="0 0 14 14" fill="currentColor" aria-hidden="true">
      <path d="M2 3h10v2H2V3zm0 3h10v2H2V6zm0 3h7v2H2V9z" />
    </svg>
  `
}

// Props and Emits
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'command-executed'])

// Reactive State
const searchInput = ref(null)
const searchQuery = ref('')
const selectedIndex = ref(0)
const loading = ref(false)

// Mock Data (to be replaced with API calls)
const projects = ref([
  {
    id: 'dashboard',
    name: 'Control Center',
    description: 'Main dashboard and monitoring',
    status: 'ok',
    uptime: 99.9,
    type: 'project'
  },
  {
    id: 'docs',
    name: 'Documentation',
    description: 'FolkUp documentation site',
    status: 'warn',
    uptime: 95.2,
    type: 'project'
  },
  {
    id: 'api',
    name: 'Core API',
    description: 'Main backend services',
    status: 'ok',
    uptime: 99.8,
    type: 'project'
  }
])

const actions = ref([
  {
    id: 'focus-panel-1',
    title: 'Focus Panel 1',
    description: 'Navigate to first project panel',
    type: 'navigate',
    shortcut: 'Cmd+1',
    category: 'navigation'
  },
  {
    id: 'acknowledge-incident',
    title: 'Acknowledge Incident',
    description: 'Mark incident as acknowledged',
    type: 'acknowledge',
    category: 'incident-management'
  },
  {
    id: 'copy-context',
    title: 'Copy Context for Claude',
    description: 'Copy incident context to clipboard',
    type: 'copy',
    shortcut: 'Cmd+Shift+C',
    category: 'productivity'
  }
])

const incidents = ref([
  {
    id: 'inc-001',
    title: 'API Response Time Spike',
    project: 'Core API',
    severity: 'P1',
    timestamp: new Date(Date.now() - 1000 * 60 * 15), // 15 minutes ago
    type: 'incident'
  },
  {
    id: 'inc-002',
    title: 'SSL Certificate Expiring',
    project: 'Documentation',
    severity: 'P0',
    timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
    type: 'incident'
  }
])

const logs = ref([
  {
    id: 'log-001',
    query: 'error 500',
    container: 'api-server',
    matchCount: 23,
    lastMatch: new Date(Date.now() - 1000 * 60 * 5), // 5 minutes ago
    type: 'log'
  },
  {
    id: 'log-002',
    query: 'certificate',
    container: 'nginx',
    matchCount: 7,
    lastMatch: new Date(Date.now() - 1000 * 60 * 30), // 30 minutes ago
    type: 'log'
  }
])

const recentItems = ref([
  {
    id: 'recent-001',
    title: 'Control Center',
    subtitle: 'Recently accessed',
    type: 'project',
    badge: '2m ago'
  },
  {
    id: 'recent-002',
    title: 'Acknowledge Incident',
    subtitle: 'Recently used action',
    type: 'action',
    badge: '5m ago'
  }
])

// Computed Properties
const filteredResults = computed(() => {
  if (!searchQuery.value.trim()) return []

  const query = searchQuery.value.toLowerCase()
  return [
    ...projectResults.value,
    ...actionResults.value,
    ...incidentResults.value,
    ...logResults.value
  ]
})

const projectResults = computed(() => {
  if (!searchQuery.value.trim()) return []
  const query = searchQuery.value.toLowerCase()
  return projects.value.filter(project =>
    project.name.toLowerCase().includes(query) ||
    project.description.toLowerCase().includes(query)
  )
})

const actionResults = computed(() => {
  if (!searchQuery.value.trim()) return []
  const query = searchQuery.value.toLowerCase()
  return actions.value.filter(action =>
    action.title.toLowerCase().includes(query) ||
    action.description.toLowerCase().includes(query) ||
    action.category.toLowerCase().includes(query)
  )
})

const incidentResults = computed(() => {
  if (!searchQuery.value.trim()) return []
  const query = searchQuery.value.toLowerCase()
  return incidents.value.filter(incident =>
    incident.title.toLowerCase().includes(query) ||
    incident.project.toLowerCase().includes(query) ||
    incident.severity.toLowerCase().includes(query)
  )
})

const logResults = computed(() => {
  if (!searchQuery.value.trim()) return []
  const query = searchQuery.value.toLowerCase()
  return logs.value.filter(log =>
    log.query.toLowerCase().includes(query) ||
    log.container.toLowerCase().includes(query)
  )
})

// Methods
const getGlobalIndex = (section, index) => {
  let globalIndex = 0

  if (section === 'project') return globalIndex + index
  globalIndex += projectResults.value.length

  if (section === 'action') return globalIndex + index
  globalIndex += actionResults.value.length

  if (section === 'incident') return globalIndex + index
  globalIndex += incidentResults.value.length

  if (section === 'log') return globalIndex + index

  return globalIndex
}

const getTotalResultsCount = () => {
  if (!searchQuery.value) return recentItems.value.length
  return projectResults.value.length + actionResults.value.length +
         incidentResults.value.length + logResults.value.length
}

const getItemAtIndex = (index) => {
  if (!searchQuery.value) return recentItems.value[index]

  let currentIndex = 0

  // Projects
  if (index < projectResults.value.length) {
    return projectResults.value[index]
  }
  currentIndex += projectResults.value.length

  // Actions
  if (index < currentIndex + actionResults.value.length) {
    return actionResults.value[index - currentIndex]
  }
  currentIndex += actionResults.value.length

  // Incidents
  if (index < currentIndex + incidentResults.value.length) {
    return incidentResults.value[index - currentIndex]
  }
  currentIndex += incidentResults.value.length

  // Logs
  if (index < currentIndex + logResults.value.length) {
    return logResults.value[index - currentIndex]
  }

  return null
}

const handleKeyDown = (event) => {
  const totalResults = getTotalResultsCount()

  switch (event.key) {
    case 'ArrowDown':
      event.preventDefault()
      selectedIndex.value = Math.min(selectedIndex.value + 1, totalResults - 1)
      break
    case 'ArrowUp':
      event.preventDefault()
      selectedIndex.value = Math.max(selectedIndex.value - 1, 0)
      break
    case 'Enter':
      event.preventDefault()
      const selectedItem = getItemAtIndex(selectedIndex.value)
      if (selectedItem) {
        executeCommand(selectedItem)
      }
      break
    case 'Escape':
      closePalette()
      break
  }
}

const executeCommand = async (item) => {
  // Add to recent items if not already there
  const existingIndex = recentItems.value.findIndex(recent => recent.id === item.id)
  if (existingIndex === -1) {
    recentItems.value.unshift({
      id: item.id,
      title: item.title || item.name,
      subtitle: `Recently ${item.type === 'project' ? 'accessed' : 'used'}`,
      type: item.type,
      badge: 'now'
    })
    // Keep only 10 recent items
    if (recentItems.value.length > 10) {
      recentItems.value = recentItems.value.slice(0, 10)
    }
  }

  // Execute the command
  switch (item.type) {
    case 'project':
      // Navigate to project
      emit('command-executed', { type: 'navigate', target: `/project/${item.id}` })
      break
    case 'action':
      // Execute action
      emit('command-executed', { type: 'action', action: item.id })
      break
    case 'incident':
      // Navigate to incident
      emit('command-executed', { type: 'navigate', target: `/incident/${item.id}` })
      break
    case 'log':
      // Open log search
      emit('command-executed', { type: 'log-search', query: item.query, container: item.container })
      break
  }

  closePalette()
}

const closePalette = () => {
  emit('close')
}

const getIcon = (type) => {
  switch (type) {
    case 'project': return StatusIcon
    case 'action': return ActionIcon
    case 'incident': return IncidentIcon
    case 'log': return LogIcon
    default: return ActionIcon
  }
}

const formatTime = (timestamp) => {
  const now = new Date()
  const diff = now - timestamp
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))

  if (minutes < 60) return `${minutes}m ago`
  if (hours < 24) return `${hours}h ago`
  return `${days}d ago`
}

// Lifecycle
watch(() => props.isOpen, (newValue) => {
  if (newValue) {
    nextTick(() => {
      searchInput.value?.focus()
    })
  } else {
    searchQuery.value = ''
    selectedIndex.value = 0
  }
})

watch(searchQuery, () => {
  selectedIndex.value = 0
})

// Global Keyboard Shortcut Handler
const handleGlobalKeyDown = (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
    event.preventDefault()
    if (!props.isOpen) {
      emit('close') // This will trigger parent to open
    } else {
      closePalette()
    }
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleGlobalKeyDown)

  // Load data (replace with actual API calls)
  loadData()
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleGlobalKeyDown)
})

const loadData = async () => {
  loading.value = true
  try {
    // Mock API calls - replace with actual Control Center API calls
    // const projectsResponse = await fetch('/api/overview')
    // const incidentsResponse = await fetch('/api/incidents')

    // For now, using mock data
    await new Promise(resolve => setTimeout(resolve, 200)) // Simulate API delay

    // In real implementation:
    // projects.value = await projectsResponse.json()
    // incidents.value = await incidentsResponse.json()
  } catch (error) {
    console.error('Failed to load command palette data:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* DSHB-056 Command Palette Styles - WCAG 2.1 AA Compliant */

.command-palette-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 10vh 1rem 1rem;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.command-palette {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  border: 1px solid #e5e7eb;
  width: 100%;
  max-width: 640px;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.command-palette__header {
  border-bottom: 1px solid #e5e7eb;
  padding: 1rem;
}

.command-palette__search-container {
  position: relative;
  display: flex;
  align-items: center;
}

.command-palette__search-icon {
  position: absolute;
  left: 12px;
  color: #6b7280;
  pointer-events: none;
}

.command-palette__search-input {
  width: 100%;
  border: none;
  outline: none;
  padding: 12px 12px 12px 40px;
  font-size: 16px;
  line-height: 1.5;
  background: transparent;
  color: #111827;
}

.command-palette__search-input::placeholder {
  color: #6b7280;
}

.command-palette__content {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem 0;
}

.command-palette__loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  padding: 2rem;
  color: #6b7280;
}

.command-palette__spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #e5e7eb;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.command-palette__no-results {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
}

.command-palette__help-text {
  font-size: 14px;
  margin-top: 0.5rem;
  opacity: 0.8;
}

.command-palette__section {
  margin-bottom: 1rem;
}

.command-palette__section-title {
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 0.5rem 1rem 0.25rem;
  margin: 0;
}

.command-palette__items {
  display: flex;
  flex-direction: column;
}

.command-palette__item {
  display: flex;
  align-items: center;
  width: 100%;
  padding: 0.75rem 1rem;
  border: none;
  background: none;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.15s ease;
  min-height: 44px; /* WCAG touch target minimum */
}

.command-palette__item:hover,
.command-palette__item--active {
  background-color: #f3f4f6;
}

.command-palette__item:focus {
  outline: 2px solid #3b82f6;
  outline-offset: -2px;
}

.command-palette__item-icon {
  margin-right: 0.75rem;
  display: flex;
  align-items: center;
  color: #6b7280;
}

.command-palette__item-content {
  flex: 1;
  min-width: 0;
}

.command-palette__item-title {
  font-weight: 500;
  color: #111827;
  margin-bottom: 0.125rem;
}

.command-palette__item-subtitle {
  font-size: 14px;
  color: #6b7280;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.command-palette__item-meta {
  margin-left: 0.75rem;
  font-size: 12px;
  color: #9ca3af;
}

.command-palette__item-uptime {
  font-weight: 500;
}

.command-palette__item-shortcut {
  margin-left: 0.75rem;
  font-size: 12px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.command-palette__item-badge {
  margin-left: 0.75rem;
  font-size: 11px;
  font-weight: 500;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  background: #e5e7eb;
  color: #374151;
}

.badge--P0 {
  background: #fecaca;
  color: #dc2626;
}

.badge--P1 {
  background: #fed7aa;
  color: #ea580c;
}

.command-palette__recent {
  padding: 0;
}

.command-palette__footer {
  border-top: 1px solid #e5e7eb;
  padding: 0.75rem 1rem;
  background: #f9fafb;
}

.command-palette__shortcuts {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 12px;
  color: #6b7280;
}

.command-palette__shortcuts kbd {
  background: #ffffff;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  padding: 0.25rem 0.5rem;
  font-family: ui-monospace, SFMono-Regular, monospace;
  font-size: 11px;
  margin-right: 0.25rem;
}

/* Screen Reader Only */
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

/* Dark Mode Support (Optional) */
@media (prefers-color-scheme: dark) {
  .command-palette {
    background: #1f2937;
    border-color: #374151;
    color: #f9fafb;
  }

  .command-palette__search-input {
    color: #f9fafb;
  }

  .command-palette__search-input::placeholder {
    color: #9ca3af;
  }

  .command-palette__item--active,
  .command-palette__item:hover {
    background-color: #374151;
  }

  .command-palette__item-title {
    color: #f9fafb;
  }

  .command-palette__footer {
    background: #111827;
    border-color: #374151;
  }

  .command-palette__shortcuts kbd {
    background: #374151;
    border-color: #4b5563;
    color: #f9fafb;
  }
}

/* Responsive Design */
@media (max-width: 640px) {
  .command-palette-overlay {
    padding: 5vh 0.5rem 1rem;
  }

  .command-palette {
    max-height: 85vh;
  }

  .command-palette__item {
    padding: 1rem;
  }

  .command-palette__shortcuts {
    flex-wrap: wrap;
  }
}

/* High Contrast Mode */
@media (prefers-contrast: high) {
  .command-palette {
    border-width: 2px;
  }

  .command-palette__item:focus {
    outline-width: 3px;
  }

  .command-palette__item--active {
    background-color: #000000;
    color: #ffffff;
  }
}

/* Reduced Motion */
@media (prefers-reduced-motion: reduce) {
  .command-palette__spinner {
    animation: none;
  }

  .command-palette__item {
    transition: none;
  }

  .command-palette-overlay {
    backdrop-filter: none;
  }
}
</style>