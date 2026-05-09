<template>
  <div id="app">
    <!-- Main Application Content -->
    <div class="app-header">
      <h1>FolkUp Control Center</h1>
      <div class="app-shortcuts">
        <kbd @click="toggleCommandPalette">{{ isWindows ? 'Ctrl' : 'Cmd' }}+K</kbd>
        <span>Open Command Palette</span>
      </div>
    </div>

    <div class="app-content">
      <div class="grid">
        <div class="card">
          <h2>Projects Overview</h2>
          <div class="project-grid">
            <div v-for="project in projects" :key="project.id" class="project-card">
              <div class="status-indicator" :class="`status--${project.status}`"></div>
              <h3>{{ project.name }}</h3>
              <p>{{ project.description }}</p>
              <div class="project-meta">
                <span>{{ project.uptime }}% uptime</span>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <h2>Recent Incidents</h2>
          <div class="incident-list">
            <div v-for="incident in incidents" :key="incident.id" class="incident-item">
              <div class="incident-severity" :class="`severity--${incident.severity}`">
                {{ incident.severity }}
              </div>
              <div class="incident-content">
                <h4>{{ incident.title }}</h4>
                <p>{{ incident.project }} • {{ formatTime(incident.timestamp) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="demo-section">
        <h2>Command Palette Demo</h2>
        <p>Press <kbd>{{ isWindows ? 'Ctrl' : 'Cmd' }}+K</kbd> to open the command palette and try searching for:</p>
        <ul>
          <li><strong>Projects:</strong> "dashboard", "docs", "api"</li>
          <li><strong>Actions:</strong> "focus", "acknowledge", "copy"</li>
          <li><strong>Incidents:</strong> "ssl", "api", "response"</li>
          <li><strong>Logs:</strong> "error", "certificate"</li>
        </ul>
        <button @click="toggleCommandPalette" class="demo-button">
          Open Command Palette
        </button>
      </div>
    </div>

    <!-- Command Palette Component -->
    <CommandPalette
      :isOpen="showCommandPalette"
      @close="showCommandPalette = false"
      @command-executed="handleCommandExecution"
    />

    <!-- Result Display -->
    <div v-if="lastCommand" class="command-result">
      <h3>Command Executed:</h3>
      <pre><code>{{ JSON.stringify(lastCommand, null, 2) }}</code></pre>
      <button @click="lastCommand = null">Clear</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import CommandPalette from './CommandPalette.vue'

// State
const showCommandPalette = ref(false)
const lastCommand = ref(null)
const isWindows = ref(false)

// Mock Data
const projects = ref([
  {
    id: 'dashboard',
    name: 'Control Center',
    description: 'Main dashboard and monitoring',
    status: 'ok',
    uptime: 99.9
  },
  {
    id: 'docs',
    name: 'Documentation',
    description: 'FolkUp documentation site',
    status: 'warn',
    uptime: 95.2
  },
  {
    id: 'api',
    name: 'Core API',
    description: 'Main backend services',
    status: 'ok',
    uptime: 99.8
  }
])

const incidents = ref([
  {
    id: 'inc-001',
    title: 'API Response Time Spike',
    project: 'Core API',
    severity: 'P1',
    timestamp: new Date(Date.now() - 1000 * 60 * 15) // 15 minutes ago
  },
  {
    id: 'inc-002',
    title: 'SSL Certificate Expiring',
    project: 'Documentation',
    severity: 'P0',
    timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2) // 2 hours ago
  }
])

// Methods
const toggleCommandPalette = () => {
  showCommandPalette.value = !showCommandPalette.value
}

const handleCommandExecution = (command) => {
  lastCommand.value = command
  console.log('Command executed:', command)

  // Handle different command types
  switch (command.type) {
    case 'navigate':
      console.log(`Navigating to: ${command.target}`)
      // In a real app, you would use Vue Router here
      // router.push(command.target)
      break
    case 'action':
      console.log(`Executing action: ${command.action}`)
      // Execute the specific action
      break
    case 'log-search':
      console.log(`Opening log search for: ${command.query} in ${command.container}`)
      // Open log search interface
      break
  }
}

const formatTime = (timestamp) => {
  const now = new Date()
  const diff = now - timestamp
  const minutes = Math.floor(diff / (1000 * 60))
  const hours = Math.floor(diff / (1000 * 60 * 60))

  if (minutes < 60) return `${minutes}m ago`
  return `${hours}h ago`
}

// Lifecycle
onMounted(() => {
  // Detect OS for keyboard shortcut display
  isWindows.value = navigator.platform.toLowerCase().includes('win')
})
</script>

<style scoped>
/* Example App Styles */
#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  color: #111827;
  background: #f9fafb;
  min-height: 100vh;
}

.app-header {
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  padding: 1rem 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.app-header h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.app-shortcuts {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.app-shortcuts kbd {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  padding: 0.25rem 0.5rem;
  font-family: ui-monospace, SFMono-Regular, monospace;
  font-size: 0.75rem;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.app-shortcuts kbd:hover {
  background: #e5e7eb;
}

.app-content {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.grid {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  margin-bottom: 2rem;
}

.card {
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  padding: 1.5rem;
}

.card h2 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.project-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

.project-card {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 1rem;
  position: relative;
}

.status-indicator {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status--ok { background-color: #10b981; }
.status--warn { background-color: #f59e0b; }
.status--down { background-color: #dc2626; }
.status--unknown { background-color: #6b7280; }

.project-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  font-weight: 600;
}

.project-card p {
  margin: 0 0 0.75rem 0;
  color: #6b7280;
  font-size: 0.875rem;
}

.project-meta {
  font-size: 0.75rem;
  color: #9ca3af;
}

.incident-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.incident-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
}

.incident-severity {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  min-width: 2rem;
  text-align: center;
}

.severity--P0 {
  background: #fecaca;
  color: #dc2626;
}

.severity--P1 {
  background: #fed7aa;
  color: #ea580c;
}

.incident-content h4 {
  margin: 0 0 0.25rem 0;
  font-size: 0.875rem;
  font-weight: 600;
}

.incident-content p {
  margin: 0;
  font-size: 0.75rem;
  color: #6b7280;
}

.demo-section {
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  padding: 1.5rem;
  text-align: center;
}

.demo-section h2 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.demo-section ul {
  text-align: left;
  max-width: 400px;
  margin: 1rem auto;
}

.demo-section kbd {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  padding: 0.125rem 0.25rem;
  font-family: ui-monospace, SFMono-Regular, monospace;
  font-size: 0.75rem;
}

.demo-button {
  background: #3b82f6;
  color: #ffffff;
  border: none;
  border-radius: 6px;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.15s ease;
  margin-top: 1rem;
}

.demo-button:hover {
  background: #2563eb;
}

.demo-button:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

.command-result {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  max-width: 400px;
  z-index: 1000;
}

.command-result h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.875rem;
  font-weight: 600;
}

.command-result pre {
  margin: 0 0 0.75rem 0;
  font-size: 0.75rem;
  background: #f3f4f6;
  padding: 0.5rem;
  border-radius: 4px;
  overflow-x: auto;
}

.command-result button {
  background: #dc2626;
  color: #ffffff;
  border: none;
  border-radius: 4px;
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
  cursor: pointer;
}

@media (max-width: 768px) {
  .app-header {
    padding: 1rem;
  }

  .app-content {
    padding: 1rem;
  }

  .grid {
    grid-template-columns: 1fr;
  }

  .command-result {
    left: 1rem;
    right: 1rem;
    max-width: none;
  }
}
</style>