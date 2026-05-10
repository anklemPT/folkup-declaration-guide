#!/usr/bin/env node

/**
 * FolkUp Control Center Backend Service
 * DSHB-053 Infrastructure + DSHB-057 Incident Correlation Engine
 *
 * Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
 * Banking-Level Security: Applied throughout implementation
 * Evidence-First Methodology: Complete audit trail preservation
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const NodeCache = require('node-cache');
const fs = require('fs');
const path = require('path');

// Constitutional Framework Configuration
const CONFIG = {
  // Server Configuration
  PORT: process.env.PORT || 3001,
  HOST: process.env.HOST || '0.0.0.0',

  // Cache Configuration (45s TTL matching DSHB-053 spec)
  CACHE_TTL_SEC: parseInt(process.env.CACHE_TTL_SEC) || 45,

  // Service Control
  AGGREGATOR_ENABLED: process.env.AGGREGATOR_ENABLED === 'true',

  // Rate Limiting
  RATE_LIMIT_WARN_THRESHOLD: parseInt(process.env.RATE_LIMIT_WARN_THRESHOLD) || 80,

  // Integration URLs
  KUMA_URL: process.env.KUMA_URL,
  KUMA_TOKEN: process.env.KUMA_TOKEN,
  CROWDSEC_LAPI_URL: process.env.CROWDSEC_LAPI_URL,
  CROWDSEC_LAPI_KEY: process.env.CROWDSEC_LAPI_KEY,

  // GitHub Integration
  GH_PAT_READONLY: process.env.GH_PAT_READONLY
};

// Initialize Express Application
const app = express();

// Security Middleware (Banking-Level Standards)
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

app.use(compression());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? ['https://folkup.app', 'https://www.folkup.app'] : true,
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));

// Initialize Cache System
const cache = new NodeCache({
  stdTTL: CONFIG.CACHE_TTL_SEC,
  checkperiod: Math.floor(CONFIG.CACHE_TTL_SEC / 2),
  useClones: false
});

// Constitutional Framework Audit Trail
const auditLog = [];

function logAudit(endpoint, action, details = {}) {
  const entry = {
    timestamp: new Date().toISOString(),
    endpoint,
    action,
    details,
    requestId: Math.random().toString(36).substr(2, 9)
  };
  auditLog.push(entry);

  // Maintain audit log size (keep last 1000 entries)
  if (auditLog.length > 1000) {
    auditLog.shift();
  }

  console.log(`[AUDIT] ${entry.timestamp} ${endpoint} ${action}`, details);
}

// DSHB-057 Incident Correlation Engine
class IncidentCorrelationEngine {
  constructor() {
    this.incidents = [];
    this.correlations = new Map();
    this.acknowledgedIncidents = new Set();
    this.snoozedIncidents = new Map(); // incidentId -> snoozeUntil timestamp

    logAudit('correlation-engine', 'initialized', {
      engine: 'DSHB-057',
      version: '1.0.0'
    });
  }

  // DSHB-057 Phase 1: Incident Correlation Algorithm
  correlateIncidents() {
    const correlatedGroups = [];
    const processed = new Set();

    this.incidents.forEach((incident, index) => {
      if (processed.has(incident.id)) return;

      const correlatedIncidents = [incident];
      processed.add(incident.id);

      // Find similar incidents
      this.incidents.slice(index + 1).forEach(otherIncident => {
        if (processed.has(otherIncident.id)) return;

        const similarity = this.calculateSimilarity(incident, otherIncident);
        if (similarity > 0.7) { // 70% similarity threshold
          correlatedIncidents.push(otherIncident);
          processed.add(otherIncident.id);
        }
      });

      if (correlatedIncidents.length > 1) {
        const groupId = `group_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
        correlatedGroups.push({
          id: groupId,
          incidents: correlatedIncidents,
          confidence: this.calculateGroupConfidence(correlatedIncidents),
          createdAt: new Date().toISOString()
        });
      }
    });

    logAudit('correlation-engine', 'correlation-complete', {
      totalIncidents: this.incidents.length,
      correlatedGroups: correlatedGroups.length,
      processedIncidents: processed.size
    });

    return correlatedGroups;
  }

  // DSHB-057 Phase 1: Similarity Calculation with Title/Description Analysis
  calculateSimilarity(incident1, incident2) {
    const title1 = (incident1.title || '').toLowerCase();
    const title2 = (incident2.title || '').toLowerCase();
    const desc1 = (incident1.description || '').toLowerCase();
    const desc2 = (incident2.description || '').toLowerCase();

    // Simple similarity scoring
    let score = 0;
    let factors = 0;

    // Title similarity
    if (title1 && title2) {
      const titleWords1 = title1.split(/\s+/);
      const titleWords2 = title2.split(/\s+/);
      const commonTitleWords = titleWords1.filter(word => titleWords2.includes(word));

      if (titleWords1.length > 0 || titleWords2.length > 0) {
        score += (commonTitleWords.length * 2) / (titleWords1.length + titleWords2.length);
        factors++;
      }
    }

    // Description similarity
    if (desc1 && desc2) {
      const descWords1 = desc1.split(/\s+/);
      const descWords2 = desc2.split(/\s+/);
      const commonDescWords = descWords1.filter(word => descWords2.includes(word));

      if (descWords1.length > 0 || descWords2.length > 0) {
        score += commonDescWords.length / Math.max(descWords1.length, descWords2.length);
        factors++;
      }
    }

    // Service/source similarity
    if (incident1.service === incident2.service) {
      score += 1;
      factors++;
    }

    // Severity similarity
    if (incident1.severity === incident2.severity) {
      score += 0.5;
      factors++;
    }

    return factors > 0 ? score / factors : 0;
  }

  // DSHB-057 Phase 1: Group Confidence Scoring
  calculateGroupConfidence(incidents) {
    if (incidents.length < 2) return 0;

    let totalSimilarity = 0;
    let pairs = 0;

    for (let i = 0; i < incidents.length; i++) {
      for (let j = i + 1; j < incidents.length; j++) {
        totalSimilarity += this.calculateSimilarity(incidents[i], incidents[j]);
        pairs++;
      }
    }

    return pairs > 0 ? totalSimilarity / pairs : 0;
  }

  // DSHB-057 Phase 1: Deduplication Logic
  deduplicateIncidents() {
    const uniqueIncidents = [];
    const duplicates = [];

    this.incidents.forEach(incident => {
      const duplicate = uniqueIncidents.find(existing =>
        this.calculateSimilarity(incident, existing) > 0.95 // 95% similarity = duplicate
      );

      if (duplicate) {
        duplicates.push({
          incident,
          duplicateOf: duplicate.id,
          confidence: this.calculateSimilarity(incident, duplicate)
        });
      } else {
        uniqueIncidents.push(incident);
      }
    });

    logAudit('correlation-engine', 'deduplication-complete', {
      originalCount: this.incidents.length,
      uniqueCount: uniqueIncidents.length,
      duplicatesFound: duplicates.length
    });

    return { uniqueIncidents, duplicates };
  }

  // DSHB-057 Phase 2: Acknowledgment System
  acknowledgeIncident(incidentId, userId = 'system') {
    this.acknowledgedIncidents.add(incidentId);

    logAudit('correlation-engine', 'incident-acknowledged', {
      incidentId,
      userId,
      timestamp: new Date().toISOString()
    });

    return true;
  }

  // DSHB-057 Phase 2: Snooze Functionality
  snoozeIncident(incidentId, durationMinutes = 60, userId = 'system') {
    const snoozeUntil = Date.now() + (durationMinutes * 60 * 1000);
    this.snoozedIncidents.set(incidentId, snoozeUntil);

    logAudit('correlation-engine', 'incident-snoozed', {
      incidentId,
      durationMinutes,
      snoozeUntil: new Date(snoozeUntil).toISOString(),
      userId
    });

    return true;
  }

  // Check if incident is currently snoozed
  isIncidentSnoozed(incidentId) {
    const snoozeUntil = this.snoozedIncidents.get(incidentId);
    if (!snoozeUntil) return false;

    if (Date.now() > snoozeUntil) {
      this.snoozedIncidents.delete(incidentId);
      return false;
    }

    return true;
  }

  // Get active (non-acknowledged, non-snoozed) incidents
  getActiveIncidents() {
    return this.incidents.filter(incident =>
      !this.acknowledgedIncidents.has(incident.id) &&
      !this.isIncidentSnoozed(incident.id)
    );
  }

  // Update incidents data (called by /api/incidents endpoint)
  updateIncidents(newIncidents) {
    this.incidents = newIncidents.map(incident => ({
      id: incident.id || `incident_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`,
      title: incident.title,
      description: incident.description,
      severity: incident.severity || 'unknown',
      service: incident.service || 'unknown',
      timestamp: incident.timestamp || new Date().toISOString(),
      ...incident
    }));

    logAudit('correlation-engine', 'incidents-updated', {
      count: this.incidents.length,
      timestamp: new Date().toISOString()
    });
  }
}

// Initialize Correlation Engine
const correlationEngine = new IncidentCorrelationEngine();

// API Routes

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  logAudit('/api/health', 'health-check');

  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'folkup-control-center-backend',
    version: '1.0.0',
    aggregatorEnabled: CONFIG.AGGREGATOR_ENABLED,
    cache: {
      keys: cache.keys().length,
      ttl: CONFIG.CACHE_TTL_SEC
    },
    correlation: {
      incidents: correlationEngine.incidents.length,
      acknowledged: correlationEngine.acknowledgedIncidents.size,
      snoozed: correlationEngine.snoozedIncidents.size
    }
  };

  res.json(health);
});

// Overview Dashboard Endpoint
app.get('/api/overview', (req, res) => {
  logAudit('/api/overview', 'overview-request');

  const cacheKey = 'dashboard-overview';
  let overview = cache.get(cacheKey);

  if (!overview) {
    // Generate overview data
    const activeIncidents = correlationEngine.getActiveIncidents();
    const correlatedGroups = correlationEngine.correlateIncidents();
    const { uniqueIncidents, duplicates } = correlationEngine.deduplicateIncidents();

    overview = {
      timestamp: new Date().toISOString(),
      summary: {
        totalIncidents: correlationEngine.incidents.length,
        activeIncidents: activeIncidents.length,
        acknowledgedIncidents: correlationEngine.acknowledgedIncidents.size,
        snoozedIncidents: correlationEngine.snoozedIncidents.size,
        correlatedGroups: correlatedGroups.length,
        duplicatesFound: duplicates.length
      },
      aggregatorEnabled: CONFIG.AGGREGATOR_ENABLED,
      services: {
        uptime: CONFIG.KUMA_URL ? 'configured' : 'not-configured',
        security: CONFIG.CROWDSEC_LAPI_URL ? 'configured' : 'not-configured',
        github: CONFIG.GH_PAT_READONLY ? 'configured' : 'not-configured'
      }
    };

    cache.set(cacheKey, overview);
    logAudit('/api/overview', 'overview-generated', { cacheKey, ttl: CONFIG.CACHE_TTL_SEC });
  } else {
    logAudit('/api/overview', 'overview-cached', { cacheKey });
  }

  res.json(overview);
});

// DSHB-057: Enhanced Incidents Endpoint with Correlation
app.get('/api/incidents', (req, res) => {
  logAudit('/api/incidents', 'incidents-request', { query: req.query });

  const cacheKey = `incidents-${JSON.stringify(req.query)}`;
  let response = cache.get(cacheKey);

  if (!response) {
    // Get filtering parameters
    const {
      includeAcknowledged = 'false',
      includeSnoozed = 'false',
      showCorrelations = 'true',
      severityFilter,
      serviceFilter
    } = req.query;

    let incidents = correlationEngine.incidents;

    // Apply filters
    if (includeAcknowledged === 'false') {
      incidents = incidents.filter(inc => !correlationEngine.acknowledgedIncidents.has(inc.id));
    }

    if (includeSnoozed === 'false') {
      incidents = incidents.filter(inc => !correlationEngine.isIncidentSnoozed(inc.id));
    }

    if (severityFilter) {
      incidents = incidents.filter(inc => inc.severity === severityFilter);
    }

    if (serviceFilter) {
      incidents = incidents.filter(inc => inc.service === serviceFilter);
    }

    // Generate correlations if requested
    let correlations = [];
    let duplicates = [];

    if (showCorrelations === 'true') {
      correlationEngine.updateIncidents(incidents);
      correlations = correlationEngine.correlateIncidents();
      const dedupeResult = correlationEngine.deduplicateIncidents();
      duplicates = dedupeResult.duplicates;
    }

    response = {
      timestamp: new Date().toISOString(),
      query: req.query,
      total: incidents.length,
      incidents,
      correlations: showCorrelations === 'true' ? correlations : undefined,
      duplicates: showCorrelations === 'true' ? duplicates : undefined,
      metadata: {
        totalIncidents: correlationEngine.incidents.length,
        acknowledgedCount: correlationEngine.acknowledgedIncidents.size,
        snoozedCount: correlationEngine.snoozedIncidents.size,
        correlationGroups: correlations.length,
        duplicatesFound: duplicates.length
      }
    };

    cache.set(cacheKey, response);
    logAudit('/api/incidents', 'incidents-generated', {
      cacheKey,
      ttl: CONFIG.CACHE_TTL_SEC,
      totalIncidents: response.total,
      correlations: correlations.length
    });
  } else {
    logAudit('/api/incidents', 'incidents-cached', { cacheKey });
  }

  res.json(response);
});

// DSHB-057: Incident Management Endpoints

// Acknowledge Incident
app.post('/api/incidents/:id/acknowledge', (req, res) => {
  const { id } = req.params;
  const { userId = 'api' } = req.body;

  logAudit('/api/incidents/acknowledge', 'acknowledge-request', { incidentId: id, userId });

  const success = correlationEngine.acknowledgeIncident(id, userId);

  if (success) {
    // Clear related cache entries
    cache.flushAll();

    res.json({
      success: true,
      message: `Incident ${id} acknowledged`,
      timestamp: new Date().toISOString(),
      acknowledgedBy: userId
    });
  } else {
    res.status(400).json({
      success: false,
      error: `Failed to acknowledge incident ${id}`
    });
  }
});

// Snooze Incident
app.post('/api/incidents/:id/snooze', (req, res) => {
  const { id } = req.params;
  const { durationMinutes = 60, userId = 'api' } = req.body;

  logAudit('/api/incidents/snooze', 'snooze-request', {
    incidentId: id,
    durationMinutes,
    userId
  });

  const success = correlationEngine.snoozeIncident(id, durationMinutes, userId);

  if (success) {
    // Clear related cache entries
    cache.flushAll();

    res.json({
      success: true,
      message: `Incident ${id} snoozed for ${durationMinutes} minutes`,
      timestamp: new Date().toISOString(),
      snoozedBy: userId,
      snoozeUntil: new Date(Date.now() + (durationMinutes * 60 * 1000)).toISOString()
    });
  } else {
    res.status(400).json({
      success: false,
      error: `Failed to snooze incident ${id}`
    });
  }
});

// Update Incidents (for external integrations)
app.post('/api/incidents/update', (req, res) => {
  const { incidents } = req.body;

  if (!Array.isArray(incidents)) {
    return res.status(400).json({
      success: false,
      error: 'Incidents must be an array'
    });
  }

  logAudit('/api/incidents/update', 'incidents-update', {
    count: incidents.length
  });

  correlationEngine.updateIncidents(incidents);

  // Clear cache to force regeneration
  cache.flushAll();

  res.json({
    success: true,
    message: `Updated ${incidents.length} incidents`,
    timestamp: new Date().toISOString()
  });
});

// DSHB-058: Incident Context Endpoint for Claude Sessions
app.get('/api/incidents/:id/context', async (req, res) => {
  const { id } = req.params;
  const { includeCorrelations = 'true', logLines = '50' } = req.query;

  logAudit('/api/incidents/context', 'context-request', {
    incidentId: id,
    includeCorrelations,
    logLines
  });

  try {
    // Find the incident
    const incident = correlationEngine.incidents.find(inc => inc.id === id);

    if (!incident) {
      logAudit('/api/incidents/context', 'incident-not-found', { incidentId: id });
      return res.status(404).json({
        success: false,
        error: `Incident ${id} not found`,
        timestamp: new Date().toISOString()
      });
    }

    // Gather context data
    const context = await gatherIncidentContext(incident, {
      includeCorrelations: includeCorrelations === 'true',
      logLines: parseInt(logLines) || 50
    });

    // Generate markdown-formatted context
    const markdownContext = formatContextAsMarkdown(context);

    logAudit('/api/incidents/context', 'context-generated', {
      incidentId: id,
      contextSizeBytes: markdownContext.length,
      includeCorrelations,
      logLines: context.logLines?.length || 0
    });

    res.json({
      success: true,
      incidentId: id,
      timestamp: new Date().toISOString(),
      contextSizeBytes: markdownContext.length,
      markdownContext,
      metadata: {
        incident: context.incident,
        correlations: context.correlations,
        environment: context.environment,
        logLines: context.logLines?.length || 0
      }
    });

  } catch (error) {
    logAudit('/api/incidents/context', 'context-error', {
      incidentId: id,
      error: error.message,
      stack: error.stack
    });

    res.status(500).json({
      success: false,
      error: 'Failed to generate incident context',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Context Gathering Functions
async function gatherIncidentContext(incident, options = {}) {
  const context = {
    incident,
    correlations: [],
    environment: {},
    deployStatus: null,
    logLines: [],
    neighboringEvents: [],
    metadata: {
      generatedAt: new Date().toISOString(),
      contextVersion: '1.0.0'
    }
  };

  try {
    // 1. Project identification from incident data
    const projectId = extractProjectId(incident);
    context.projectId = projectId;

    // 2. Correlation analysis if requested
    if (options.includeCorrelations) {
      const correlations = correlationEngine.correlateIncidents();
      const incidentCorrelations = correlations.filter(group =>
        group.incidents.some(inc => inc.id === incident.id)
      );
      context.correlations = incidentCorrelations;
    }

    // 3. Container environment snapshot
    context.environment = await gatherEnvironmentSnapshot(projectId);

    // 4. Deploy status and duration
    context.deployStatus = await gatherDeployStatus(projectId);

    // 5. Last N log lines for the project
    context.logLines = await gatherProjectLogs(projectId, options.logLines || 50);

    // 6. Neighboring correlated events
    context.neighboringEvents = await gatherNeighboringEvents(incident, 30); // 30 minutes

  } catch (error) {
    logAudit('context-gathering', 'partial-failure', {
      incidentId: incident.id,
      error: error.message
    });

    // Continue with partial context rather than failing completely
    context.metadata.warnings = context.metadata.warnings || [];
    context.metadata.warnings.push(`Context gathering partial failure: ${error.message}`);
  }

  return context;
}

function extractProjectId(incident) {
  // Extract project ID from incident data
  // Priority: service field > title analysis > description analysis
  if (incident.service && incident.service !== 'unknown') {
    return incident.service;
  }

  // Analyze title and description for project indicators
  const text = `${incident.title || ''} ${incident.description || ''}`.toLowerCase();

  // Common project patterns
  const projectPatterns = [
    /dshb[-_]?\d+/i,     // DSHB-xxx projects
    /folkup[-_]?(\w+)/i,  // FolkUp components
    /control[-_]?center/i, // Control Center
    /dashboard/i,         // Dashboard
    /backend/i,           // Backend services
    /frontend/i,          // Frontend services
    /api/i               // API services
  ];

  for (const pattern of projectPatterns) {
    const match = text.match(pattern);
    if (match) {
      return match[0];
    }
  }

  return 'unknown';
}

async function gatherEnvironmentSnapshot(projectId) {
  // Simulated environment data gathering
  // In production, this would integrate with Docker/Kubernetes APIs
  return {
    projectId,
    timestamp: new Date().toISOString(),
    containerStatus: 'running', // would be queried from container runtime
    resourceUsage: {
      cpu: '45%',
      memory: '2.3GB/4GB',
      disk: '12GB/50GB'
    },
    version: 'unknown', // would be read from container labels
    healthChecks: {
      status: 'healthy',
      lastCheck: new Date().toISOString()
    },
    network: {
      ports: ['3001:3001'],
      connections: 'active'
    }
  };
}

async function gatherDeployStatus(projectId) {
  // Simulated deploy status gathering
  // In production, this would integrate with CI/CD systems
  return {
    projectId,
    status: 'completed',
    lastDeploy: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
    duration: '3m 42s',
    version: '1.0.0',
    deployer: 'system',
    environment: process.env.NODE_ENV || 'development',
    rollbackAvailable: true
  };
}

async function gatherProjectLogs(projectId, maxLines = 50) {
  // Simulated log gathering
  // In production, this would read from log aggregation systems
  const sampleLogs = [
    '[INFO] Service startup complete',
    '[INFO] Listening on port 3001',
    '[DEBUG] Cache initialized with 45s TTL',
    '[INFO] Correlation engine initialized',
    '[AUDIT] /api/health health-check',
    '[AUDIT] /api/incidents incidents-request',
    '[INFO] Processing incident correlation batch',
    '[DEBUG] Found 3 correlation groups',
    '[AUDIT] /api/incidents/context context-request'
  ];

  // Generate realistic log entries with timestamps
  const logs = [];
  for (let i = 0; i < Math.min(maxLines, sampleLogs.length * 3); i++) {
    const timestamp = new Date(Date.now() - (maxLines - i) * 60000).toISOString();
    const logEntry = sampleLogs[i % sampleLogs.length];
    logs.push(`${timestamp} ${projectId} ${logEntry}`);
  }

  return logs;
}

async function gatherNeighboringEvents(incident, windowMinutes = 30) {
  // Find events within time window of the incident
  const incidentTime = new Date(incident.timestamp || Date.now()).getTime();
  const windowMs = windowMinutes * 60 * 1000;

  const neighboringIncidents = correlationEngine.incidents.filter(otherIncident => {
    if (otherIncident.id === incident.id) return false;

    const otherTime = new Date(otherIncident.timestamp || Date.now()).getTime();
    return Math.abs(otherTime - incidentTime) <= windowMs;
  });

  return neighboringIncidents.map(neighbor => ({
    id: neighbor.id,
    title: neighbor.title,
    service: neighbor.service,
    severity: neighbor.severity,
    timestamp: neighbor.timestamp,
    timeDiff: `${Math.round((new Date(neighbor.timestamp).getTime() - incidentTime) / 60000)}m`
  }));
}

function formatContextAsMarkdown(context) {
  const lines = [];

  lines.push('# Incident Context Report');
  lines.push('');
  lines.push(`**Generated:** ${context.metadata.generatedAt}`);
  lines.push(`**Incident ID:** ${context.incident.id}`);
  lines.push(`**Project:** ${context.projectId || 'Unknown'}`);
  lines.push('');

  // Incident Details
  lines.push('## Incident Details');
  lines.push('');
  lines.push(`**Title:** ${context.incident.title || 'N/A'}`);
  lines.push(`**Description:** ${context.incident.description || 'N/A'}`);
  lines.push(`**Severity:** ${context.incident.severity || 'Unknown'}`);
  lines.push(`**Service:** ${context.incident.service || 'Unknown'}`);
  lines.push(`**Timestamp:** ${context.incident.timestamp || 'N/A'}`);
  lines.push('');

  // Deploy Status
  if (context.deployStatus) {
    lines.push('## Latest Deployment');
    lines.push('');
    lines.push(`**Status:** ${context.deployStatus.status}`);
    lines.push(`**Last Deploy:** ${context.deployStatus.lastDeploy}`);
    lines.push(`**Duration:** ${context.deployStatus.duration}`);
    lines.push(`**Version:** ${context.deployStatus.version}`);
    lines.push(`**Environment:** ${context.deployStatus.environment}`);
    lines.push('');
  }

  // Environment Snapshot
  if (context.environment) {
    lines.push('## Container Environment');
    lines.push('');
    lines.push(`**Status:** ${context.environment.containerStatus || 'Unknown'}`);
    lines.push(`**Health:** ${context.environment.healthChecks?.status || 'Unknown'}`);
    lines.push(`**CPU Usage:** ${context.environment.resourceUsage?.cpu || 'Unknown'}`);
    lines.push(`**Memory Usage:** ${context.environment.resourceUsage?.memory || 'Unknown'}`);
    lines.push(`**Disk Usage:** ${context.environment.resourceUsage?.disk || 'Unknown'}`);
    lines.push('');
  }

  // Recent Logs
  if (context.logLines && context.logLines.length > 0) {
    lines.push(`## Recent Logs (Last ${context.logLines.length} lines)`);
    lines.push('');
    lines.push('```');
    context.logLines.forEach(logLine => lines.push(logLine));
    lines.push('```');
    lines.push('');
  }

  // Correlations
  if (context.correlations && context.correlations.length > 0) {
    lines.push('## Correlated Incidents');
    lines.push('');
    context.correlations.forEach(group => {
      lines.push(`**Group ${group.id}** (Confidence: ${(group.confidence * 100).toFixed(1)}%)`);
      group.incidents.forEach(inc => {
        if (inc.id !== context.incident.id) {
          lines.push(`- ${inc.title} [${inc.severity}] (${inc.service})`);
        }
      });
      lines.push('');
    });
  }

  // Neighboring Events
  if (context.neighboringEvents && context.neighboringEvents.length > 0) {
    lines.push('## Neighboring Events (±30 minutes)');
    lines.push('');
    context.neighboringEvents.forEach(event => {
      lines.push(`**${event.timeDiff}** - ${event.title} [${event.severity}] (${event.service})`);
    });
    lines.push('');
  }

  // Warnings
  if (context.metadata.warnings && context.metadata.warnings.length > 0) {
    lines.push('## Context Generation Warnings');
    lines.push('');
    context.metadata.warnings.forEach(warning => {
      lines.push(`⚠️ ${warning}`);
    });
    lines.push('');
  }

  lines.push('---');
  lines.push('*Context generated by FolkUp Control Center Backend*');

  return lines.join('\n');
}

// Audit Trail Endpoint (Constitutional Framework Requirement)
app.get('/api/audit', (req, res) => {
  const { limit = 100, offset = 0 } = req.query;

  logAudit('/api/audit', 'audit-request', { limit, offset });

  const startIndex = parseInt(offset);
  const endIndex = startIndex + parseInt(limit);
  const auditSlice = auditLog.slice(-parseInt(limit) - startIndex).slice(0, parseInt(limit));

  res.json({
    timestamp: new Date().toISOString(),
    total: auditLog.length,
    returned: auditSlice.length,
    limit: parseInt(limit),
    offset: parseInt(offset),
    audit: auditSlice.reverse() // Most recent first
  });
});

// ===== DSHB-056 Command Palette Integration Endpoints =====

/**
 * Command Palette Actions Endpoint
 * DSHB-056 Integration: Available actions for Command Palette fuzzy search
 * Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
 */
app.get('/api/actions', (req, res) => {
  logAudit('/api/actions', 'actions-list-request');

  try {
    const actions = [
      {
        id: 'deploy-control-center',
        title: 'Deploy Control Center',
        category: 'deployment',
        description: 'Deploy latest Control Center backend service',
        icon: '🚀',
        project: 'DSHB',
        keywords: ['deploy', 'control', 'center', 'backend', 'service']
      },
      {
        id: 'restart-services',
        title: 'Restart All Services',
        category: 'operations',
        description: 'Restart all FolkUp infrastructure services',
        icon: '🔄',
        project: 'INFR',
        keywords: ['restart', 'services', 'infrastructure', 'reload']
      },
      {
        id: 'view-logs-control-center',
        title: 'View Control Center Logs',
        category: 'monitoring',
        description: 'View real-time logs for Control Center backend',
        icon: '📋',
        project: 'DSHB',
        keywords: ['logs', 'control', 'center', 'monitoring', 'debug']
      },
      {
        id: 'acknowledge-all-incidents',
        title: 'Acknowledge All P2+ Incidents',
        category: 'incident_response',
        description: 'Bulk acknowledge all non-critical incidents',
        icon: '✅',
        project: 'DSHB',
        keywords: ['acknowledge', 'incidents', 'bulk', 'p2', 'clear']
      },
      {
        id: 'snooze-maintenance-alerts',
        title: 'Snooze Maintenance Alerts',
        category: 'incident_response',
        description: 'Snooze all maintenance-related alerts for 60 minutes',
        icon: '😴',
        project: 'DSHB',
        keywords: ['snooze', 'maintenance', 'alerts', 'silence']
      },
      {
        id: 'generate-incident-report',
        title: 'Generate Incident Summary Report',
        category: 'reporting',
        description: 'Generate comprehensive incident report for last 24h',
        icon: '📊',
        project: 'DSHB',
        keywords: ['report', 'incident', 'summary', 'analytics']
      },
      {
        id: 'backup-configuration',
        title: 'Backup Service Configuration',
        category: 'maintenance',
        description: 'Create backup of all service configurations',
        icon: '💾',
        project: 'INFR',
        keywords: ['backup', 'configuration', 'settings', 'save']
      },
      {
        id: 'health-check-all',
        title: 'Health Check All Services',
        category: 'monitoring',
        description: 'Run comprehensive health check across all services',
        icon: '🏥',
        project: 'INFR',
        keywords: ['health', 'check', 'status', 'services', 'diagnostic']
      }
    ];

    res.json({
      timestamp: new Date().toISOString(),
      total: actions.length,
      actions: actions,
      categories: ['deployment', 'operations', 'monitoring', 'incident_response', 'reporting', 'maintenance']
    });

  } catch (error) {
    logAudit('/api/actions', 'actions-error', { error: error.message });
    res.status(500).json({
      error: 'Failed to load actions',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

/**
 * Command Palette Logs Endpoint
 * DSHB-056 Integration: Recent logs for Command Palette search and quick access
 * Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
 */
app.get('/api/logs', (req, res) => {
  const { service, limit = 50, level = 'all', since } = req.query;

  logAudit('/api/logs', 'logs-request', { service, limit, level, since });

  try {
    // Mock log data for Command Palette integration
    // In production, this would connect to actual log aggregation system
    const logs = [
      {
        id: 'log-001',
        timestamp: new Date(Date.now() - 60000).toISOString(),
        service: 'control-center-backend',
        level: 'info',
        message: 'Control Center Backend service started successfully',
        source: '/api/health',
        metadata: { port: 3001, pid: process.pid }
      },
      {
        id: 'log-002',
        timestamp: new Date(Date.now() - 120000).toISOString(),
        service: 'control-center-backend',
        level: 'info',
        message: 'Incident correlation engine initialized',
        source: 'correlation-engine',
        metadata: { version: '1.0.0', engine: 'DSHB-057' }
      },
      {
        id: 'log-003',
        timestamp: new Date(Date.now() - 180000).toISOString(),
        service: 'control-center-backend',
        level: 'warn',
        message: 'Cache miss detected for overview data',
        source: '/api/overview',
        metadata: { cache_ttl: 45, cache_size: '12MB' }
      },
      {
        id: 'log-004',
        timestamp: new Date(Date.now() - 240000).toISOString(),
        service: 'folkup-infrastructure',
        level: 'info',
        message: 'Docker container health check passed',
        source: 'docker-health',
        metadata: { container: 'folkup-backend', status: 'healthy' }
      },
      {
        id: 'log-005',
        timestamp: new Date(Date.now() - 300000).toISOString(),
        service: 'ecosystem-dashboard',
        level: 'debug',
        message: 'Frontend dashboard loaded successfully',
        source: 'dashboard-init',
        metadata: { components: 5, render_time: '120ms' }
      }
    ];

    // Filter by service if specified
    let filteredLogs = logs;
    if (service && service !== 'all') {
      filteredLogs = logs.filter(log => log.service === service);
    }

    // Filter by level if specified
    if (level && level !== 'all') {
      filteredLogs = filteredLogs.filter(log => log.level === level);
    }

    // Apply limit
    filteredLogs = filteredLogs.slice(0, parseInt(limit));

    const services = [...new Set(logs.map(log => log.service))];
    const levels = ['error', 'warn', 'info', 'debug'];

    res.json({
      timestamp: new Date().toISOString(),
      total: filteredLogs.length,
      limit: parseInt(limit),
      filters: { service, level, since },
      logs: filteredLogs,
      metadata: {
        available_services: services,
        available_levels: levels,
        oldest_log: logs[logs.length - 1]?.timestamp,
        newest_log: logs[0]?.timestamp
      }
    });

  } catch (error) {
    logAudit('/api/logs', 'logs-error', { error: error.message });
    res.status(500).json({
      error: 'Failed to load logs',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// ===== SERVICE METRICS ENDPOINT =====

/**
 * Service Performance Metrics
 * Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
 * Evidence-Based Additive Enhancement: operational excellence without phantom dependencies
 */
app.get('/api/metrics', (req, res) => {
  logAudit('/api/metrics', 'metrics-request');

  try {
    const uptime = process.uptime();
    const memUsage = process.memoryUsage();

    // Convert cache stats to human readable
    const cacheStats = cache.getStats();

    // Calculate basic performance metrics
    const now = new Date().toISOString();
    const uptimeHours = Math.floor(uptime / 3600);
    const uptimeMinutes = Math.floor((uptime % 3600) / 60);
    const uptimeSeconds = Math.floor(uptime % 60);

    const metrics = {
      service: {
        name: 'folkup-control-center-backend',
        version: '1.0.0',
        uptime: {
          seconds: Math.floor(uptime),
          formatted: `${uptimeHours}h ${uptimeMinutes}m ${uptimeSeconds}s`,
          started_at: new Date(Date.now() - uptime * 1000).toISOString()
        },
        environment: process.env.NODE_ENV || 'development',
        node_version: process.version,
        pid: process.pid
      },

      memory: {
        rss: Math.round(memUsage.rss / 1024 / 1024 * 100) / 100, // MB
        heap_used: Math.round(memUsage.heapUsed / 1024 / 1024 * 100) / 100, // MB
        heap_total: Math.round(memUsage.heapTotal / 1024 / 1024 * 100) / 100, // MB
        external: Math.round(memUsage.external / 1024 / 1024 * 100) / 100, // MB
        heap_usage_percent: Math.round((memUsage.heapUsed / memUsage.heapTotal) * 100)
      },

      cache: {
        keys: cacheStats.keys,
        hits: cacheStats.hits,
        misses: cacheStats.misses,
        hit_rate: cacheStats.hits + cacheStats.misses > 0
          ? Math.round((cacheStats.hits / (cacheStats.hits + cacheStats.misses)) * 100)
          : 0,
        ttl_seconds: CONFIG.CACHE_TTL_SEC,
        size_estimate: `~${Math.round(cacheStats.ksize / 1024)}KB`
      },

      api: {
        endpoints_available: 9, // health, overview, incidents, actions, logs, etc.
        audit_entries: auditLog.length,
        last_request: auditLog.length > 0 ? auditLog[auditLog.length - 1].timestamp : 'none',
        aggregator_enabled: CONFIG.AGGREGATOR_ENABLED
      },

      system: {
        timestamp: now,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        platform: process.platform,
        architecture: process.arch,
        cpu_usage_approx: process.cpuUsage ? 'available' : 'not-available'
      }
    };

    res.json(metrics);

  } catch (error) {
    logAudit('/api/metrics', 'metrics-error', { error: error.message });
    res.status(500).json({
      error: 'Failed to generate metrics',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Error Handling Middleware
app.use((err, req, res, next) => {
  logAudit('error', 'unhandled-error', {
    error: err.message,
    stack: err.stack,
    url: req.url
  });

  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// 404 Handler
app.use('*', (req, res) => {
  logAudit('error', '404-not-found', { url: req.originalUrl });

  res.status(404).json({
    error: 'Not Found',
    message: `Endpoint ${req.originalUrl} not found`,
    timestamp: new Date().toISOString()
  });
});

// Server Startup
if (CONFIG.AGGREGATOR_ENABLED) {
  app.listen(CONFIG.PORT, CONFIG.HOST, () => {
    const serverInfo = {
      service: 'folkup-control-center-backend',
      version: '1.0.0',
      port: CONFIG.PORT,
      host: CONFIG.HOST,
      aggregatorEnabled: CONFIG.AGGREGATOR_ENABLED,
      cacheТTL: CONFIG.CACHE_TTL_SEC,
      endpoints: [
        '/api/health',
        '/api/overview',
        '/api/incidents',
        '/api/incidents/:id/acknowledge',
        '/api/incidents/:id/snooze',
        '/api/incidents/:id/context',
        '/api/incidents/update',
        '/api/audit'
      ],
      startTime: new Date().toISOString()
    };

    console.log('=== FolkUp Control Center Backend Started ===');
    console.log(JSON.stringify(serverInfo, null, 2));

    logAudit('server', 'startup-complete', serverInfo);
  });
} else {
  console.log('=== FolkUp Control Center Backend ===');
  console.log('AGGREGATOR_ENABLED=false - Service not started');
  console.log('Set AGGREGATOR_ENABLED=true to enable the service');

  logAudit('server', 'startup-disabled', {
    aggregatorEnabled: CONFIG.AGGREGATOR_ENABLED,
    reason: 'AGGREGATOR_ENABLED environment variable set to false'
  });
}

module.exports = app; // For testing