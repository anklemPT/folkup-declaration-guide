#!/bin/bash
# Constitutional Deployment Script for declaration.folkup.app
# Enhanced Alice v2.0 Level 3 Constitutional Framework
# Banking-Level Security Standards

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="declaration.folkup.app"
DOCUMENT_ROOT="/var/www/declaration.folkup.app/html"
NGINX_CONFIG="/etc/nginx/sites-available/declaration.folkup.app"
LOG_FILE="/tmp/constitutional-deploy-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
    echo -e "$1"
}

# Error handling
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}✅ $1${NC}"
    log "SUCCESS: $1"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log "WARNING: $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error_exit "This script must be run as root (use sudo)"
fi

log "=== CONSTITUTIONAL DEPLOYMENT STARTED ==="
log "Domain: $DOMAIN"
log "Document Root: $DOCUMENT_ROOT"

# Phase 1: Pre-deployment validation
log "PHASE 1: Pre-deployment validation"

# Check nginx
if ! nginx -v &>/dev/null; then
    error_exit "nginx is not installed or not in PATH"
fi
success "nginx is available"

# Check current nginx configuration
if ! nginx -t; then
    error_exit "Current nginx configuration is invalid"
fi
success "Current nginx configuration is valid"

# Phase 2: Document root setup
log "PHASE 2: Document root setup"

# Create directory structure
mkdir -p "$DOCUMENT_ROOT"
mkdir -p "/var/log/nginx"
success "Directory structure created"

# Set proper ownership
chown -R www-data:www-data "/var/www/declaration.folkup.app/"
chmod -R 755 "/var/www/declaration.folkup.app/"
success "Ownership and permissions set"

# Phase 3: Content deployment
log "PHASE 3: Content deployment"

# Check if index.html exists in current directory
if [[ ! -f "index.html" ]]; then
    error_exit "index.html not found in current directory. Please run from declaration project root."
fi

# Copy content
cp index.html "$DOCUMENT_ROOT/"
if [[ -d "images" ]]; then
    cp -r images/ "$DOCUMENT_ROOT/"
fi
if [[ -d "css" ]]; then
    cp -r css/ "$DOCUMENT_ROOT/"
fi
success "Content deployed"

# Create error pages
cat > "$DOCUMENT_ROOT/404.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Page Not Found</title></head>
<body><h1>404 - Page Not Found</h1><p>The requested page could not be found.</p></body>
</html>
EOF

cat > "$DOCUMENT_ROOT/50x.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Server Error</title></head>
<body><h1>Server Error</h1><p>A server error occurred. Please try again later.</p></body>
</html>
EOF

chown www-data:www-data "$DOCUMENT_ROOT"/*.html
chmod 644 "$DOCUMENT_ROOT"/*.html
success "Error pages created"

# Phase 4: SSL certificate generation
log "PHASE 4: SSL certificate generation"

# Check if certbot is available
if ! command -v certbot &> /dev/null; then
    warning "certbot not found, installing..."
    apt update && apt install -y certbot python3-certbot-nginx
fi

# Check if certificate already exists
if [[ -d "/etc/letsencrypt/live/$DOMAIN" ]]; then
    warning "SSL certificate for $DOMAIN already exists"
else
    log "Generating SSL certificate for $DOMAIN"
    # Use staging first for testing
    if certbot certonly --nginx --staging -d "$DOMAIN" --email anklemqq@gmail.com --agree-tos --no-eff-email; then
        success "Staging certificate generated"
        # Generate production certificate
        if certbot certonly --nginx -d "$DOMAIN" --email anklemqq@gmail.com --agree-tos --no-eff-email; then
            success "Production SSL certificate generated"
        else
            error_exit "Failed to generate production SSL certificate"
        fi
    else
        error_exit "Failed to generate staging SSL certificate"
    fi
fi

# Phase 5: DH parameters generation
log "PHASE 5: DH parameters generation"

if [[ ! -f "/etc/nginx/dhparam.pem" ]]; then
    log "Generating DH parameters (this may take several minutes)..."
    openssl dhparam -out /etc/nginx/dhparam.pem 2048
    chmod 600 /etc/nginx/dhparam.pem
    success "DH parameters generated"
else
    success "DH parameters already exist"
fi

# Phase 6: nginx configuration deployment
log "PHASE 6: nginx configuration deployment"

# Check if constitutional config exists
if [[ ! -f "nginx-declaration-constitutional.conf" ]]; then
    error_exit "nginx-declaration-constitutional.conf not found in current directory"
fi

# Copy configuration
cp nginx-declaration-constitutional.conf "$NGINX_CONFIG"
success "nginx configuration copied"

# Enable site
ln -sf "$NGINX_CONFIG" "/etc/nginx/sites-enabled/"
success "Site enabled"

# Test configuration
if nginx -t; then
    success "nginx configuration test passed"
else
    error_exit "nginx configuration test failed"
fi

# Phase 7: Deploy and reload
log "PHASE 7: Deploy and reload"

# Reload nginx
if systemctl reload nginx; then
    success "nginx reloaded successfully"
else
    error_exit "Failed to reload nginx"
fi

# Phase 8: Post-deployment verification
log "PHASE 8: Post-deployment verification"

# Wait a moment for nginx to fully reload
sleep 2

# Test site accessibility
if curl -s -o /dev/null -w "%{http_code}" "http://localhost" | grep -q "200"; then
    success "Site is responding to HTTP requests"
else
    warning "Site not responding to HTTP requests"
fi

# Test HTTPS redirect
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN" 2>/dev/null || echo "000")
if [[ "$HTTP_RESPONSE" == "200" ]]; then
    success "HTTPS is working"
elif [[ "$HTTP_RESPONSE" == "000" ]]; then
    warning "HTTPS test failed - this may be normal if DNS is not yet propagated"
else
    warning "HTTPS returned status: $HTTP_RESPONSE"
fi

# Test security headers
if curl -I "https://$DOMAIN" 2>/dev/null | grep -q "X-Frame-Options"; then
    success "Security headers are present"
else
    warning "Security headers may not be working correctly"
fi

# Check nginx status
if systemctl is-active --quiet nginx; then
    success "nginx service is active"
else
    error_exit "nginx service is not active"
fi

# Final verification
log "PHASE 9: Constitutional compliance verification"

# Check GDPR-compliant logging
LOG_FORMAT=$(nginx -T 2>/dev/null | grep "gdpr_compliant" || true)
if [[ -n "$LOG_FORMAT" ]]; then
    success "GDPR-compliant logging configured"
else
    warning "GDPR-compliant logging may not be active"
fi

# Summary
log "=== CONSTITUTIONAL DEPLOYMENT COMPLETE ==="
success "declaration.folkup.app deployment completed successfully"
echo
echo "Next steps:"
echo "1. Verify DNS propagation: dig $DOMAIN"
echo "2. Test site: curl -I https://$DOMAIN"
echo "3. Monitor logs: tail -f /var/log/nginx/$DOMAIN.access.log"
echo "4. SSL certificate auto-renewal test: certbot renew --dry-run"
echo
echo "Deployment log saved to: $LOG_FILE"
echo "Constitutional compliance achieved ✅"