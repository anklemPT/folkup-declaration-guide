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