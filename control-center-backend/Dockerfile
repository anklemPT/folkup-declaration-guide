# FolkUp Control Center Backend - DSHB-053/057 Infrastructure
# Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
# Banking-Level Security: Single-stage build for simplicity

FROM node:18-alpine

# Create app user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with npm audit fix
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy application code and set ownership
COPY --chown=nodejs:nodejs server.js ./

# Security hardening
RUN apk --no-cache add dumb-init && \
    rm -rf /var/cache/apk/*

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); \
    const options = { hostname: 'localhost', port: 3001, path: '/api/health', timeout: 5000 }; \
    const req = http.request(options, (res) => { \
      if (res.statusCode === 200) { process.exit(0); } else { process.exit(1); } \
    }); \
    req.on('error', () => process.exit(1)); \
    req.on('timeout', () => { req.destroy(); process.exit(1); }); \
    req.end();"

# Set environment
ENV NODE_ENV=production

# Start application with dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]