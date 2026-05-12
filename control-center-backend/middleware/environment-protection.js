/**
 * INFR-007 Environment Variable Protection Middleware
 * P0 CVSS 6.5 Security Remediation
 *
 * Prevents environment variable exposure through logs, responses, and error messages
 */

// Sensitive environment variable patterns that should never be logged or exposed
const SENSITIVE_ENV_PATTERNS = [
  /TOKEN/i,
  /KEY/i,
  /SECRET/i,
  /PASSWORD/i,
  /PASS/i,
  /AUTH/i,
  /PAT/i,  // Personal Access Token
  /API_KEY/i,
  /PRIVATE/i,
  /CREDENTIAL/i
];

// Configuration keys that contain sensitive data
const SENSITIVE_CONFIG_KEYS = [
  'KUMA_TOKEN',
  'KUMA_URL',  // URLs can contain embedded credentials
  'CROWDSEC_LAPI_KEY',
  'CROWDSEC_LAPI_URL',
  'GH_PAT_READONLY',
  'JWT_SECRET',
  'ADMIN_CACHE_TOKEN'
];

/**
 * Sanitize configuration object by removing or masking sensitive values
 */
function sanitizeConfig(config) {
  const sanitized = {};

  for (const [key, value] of Object.entries(config)) {
    if (SENSITIVE_CONFIG_KEYS.includes(key)) {
      // Mask sensitive values
      if (value) {
        if (typeof value === 'string' && value.length > 8) {
          sanitized[key] = `${value.substring(0, 4)}...[REDACTED]`;
        } else {
          sanitized[key] = '[REDACTED]';
        }
      } else {
        sanitized[key] = '[NOT_SET]';
      }
    } else {
      // Check if key name suggests sensitivity
      const isSensitive = SENSITIVE_ENV_PATTERNS.some(pattern => pattern.test(key));

      if (isSensitive && value) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    }
  }

  return sanitized;
}

/**
 * Create sanitized service status without revealing configuration details
 */
function getServiceStatus(config) {
  return {
    // Generic service availability without revealing configuration
    total_services: 4,  // Static count to avoid fingerprinting
    status: 'operational',
    health_check: 'enabled',
    // Remove specific service configuration disclosure
    integration_layer: 'configured'
  };
}

/**
 * Sanitize server information for startup logging
 */
function getSanitizedServerInfo(config) {
  return {
    service: 'folkup-control-center-backend',
    version: '1.0.0',
    port: config.PORT,
    host: config.HOST === '0.0.0.0' ? '[ALL_INTERFACES]' : config.HOST,
    // Remove aggregatorEnabled disclosure
    mode: config.AGGREGATOR_ENABLED ? 'active' : 'standby',
    endpoints: [
      '/api/health',
      '/api/overview',
      '/api/incidents',
      '/api/audit'
    ],
    startTime: new Date().toISOString(),
    security_hardening: 'enabled'
  };
}

/**
 * Middleware to prevent environment variable leakage in error responses
 */
function environmentProtectionMiddleware(err, req, res, next) {
  // Log error safely without exposing environment variables
  const sanitizedError = {
    message: err.message,
    statusCode: err.statusCode || 500,
    timestamp: new Date().toISOString(),
    endpoint: req.originalUrl,
    method: req.method
  };

  // Log for debugging (sanitized)
  console.error('[ERROR_SANITIZED]', sanitizedError);

  // Never expose stack traces or environment details in production
  if (process.env.NODE_ENV === 'production') {
    res.status(err.statusCode || 500).json({
      error: 'Internal Server Error',
      message: 'An error occurred while processing your request',
      timestamp: new Date().toISOString()
    });
  } else {
    // Development mode - still sanitize but provide more detail
    res.status(err.statusCode || 500).json({
      error: err.message || 'Internal Server Error',
      timestamp: new Date().toISOString(),
      note: 'Development mode - production responses are sanitized'
    });
  }
}

/**
 * Secure logging function that automatically sanitizes sensitive data
 */
function secureLog(level, message, data = {}) {
  const sanitizedData = {};

  for (const [key, value] of Object.entries(data)) {
    // Check for sensitive patterns in key names
    const isSensitive = SENSITIVE_ENV_PATTERNS.some(pattern => pattern.test(key));

    if (isSensitive) {
      sanitizedData[key] = '[REDACTED]';
    } else if (typeof value === 'object' && value !== null) {
      // Recursively sanitize objects
      sanitizedData[key] = sanitizeConfig(value);
    } else {
      sanitizedData[key] = value;
    }
  }

  const timestamp = new Date().toISOString();
  console[level](`[${timestamp}] ${message}`, Object.keys(sanitizedData).length > 0 ? sanitizedData : '');
}

module.exports = {
  sanitizeConfig,
  getServiceStatus,
  getSanitizedServerInfo,
  environmentProtectionMiddleware,
  secureLog,
  SENSITIVE_CONFIG_KEYS,
  SENSITIVE_ENV_PATTERNS
};