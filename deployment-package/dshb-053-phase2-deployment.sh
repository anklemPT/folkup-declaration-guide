#!/bin/bash

# DSHB-053 Phase 2: Dashboard Aggregator Configuration Deployment
# Constitutional Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome
# Banking-Level Security: Encrypted credential deployment with validation

set -euo pipefail

echo "=== DSHB-053 Phase 2: Dashboard Aggregator Deployment ==="
echo "Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"

# Configuration
PROD_SECRETS_DIR="/opt/folkup/secrets"
CONFIG_FILE="dashboard-aggregator.env"
BACKUP_FILE="dashboard-aggregator.env.backup"

# Phase 2A: Pre-deployment validation
echo "Phase 2A: Configuration validation..."

# Validate local encrypted configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: $CONFIG_FILE not found in current directory"
    exit 1
fi

# Test SOPS decryption
echo "Testing SOPS decryption..."
if ! sops -d "$CONFIG_FILE" > /dev/null; then
    echo "ERROR: SOPS decryption failed"
    exit 1
fi
echo "✅ SOPS decryption successful"

# Phase 2B: Server connectivity and preparation
echo "Phase 2B: Server preparation..."

# Test server connectivity
if ! ssh vps "echo 'Server accessible'" 2>/dev/null; then
    echo "WARNING: Cannot connect to production server"
    echo "Creating deployment package for manual transfer..."

    # Create deployment package
    mkdir -p deployment-package
    cp "$CONFIG_FILE" deployment-package/
    cp "$0" deployment-package/

    cat > deployment-package/deploy-instructions.md << 'EOF'
# DSHB-053 Phase 2 Manual Deployment Instructions

## Server Commands to Execute:
```bash
# Create secrets directory
sudo mkdir -p /opt/folkup/secrets
sudo chown deploy:deploy /opt/folkup/secrets
sudo chmod 750 /opt/folkup/secrets

# Deploy configuration
sudo cp dashboard-aggregator.env /opt/folkup/secrets/
sudo chown deploy:deploy /opt/folkup/secrets/dashboard-aggregator.env
sudo chmod 640 /opt/folkup/secrets/dashboard-aggregator.env

# Validate SOPS access
cd /opt/folkup/secrets
sops -d dashboard-aggregator.env > /dev/null && echo "SOPS validation successful"
```

## Validation Commands:
```bash
# Test configuration accessibility
sudo ls -la /opt/folkup/secrets/
sudo -u deploy sops -d /opt/folkup/secrets/dashboard-aggregator.env | head -3
```
EOF

    echo "✅ Deployment package created in deployment-package/"
    echo "Manual deployment instructions available"
    exit 0
fi

# Phase 2C: Production deployment
echo "Phase 2C: Production deployment..."

# Create secrets directory
ssh vps "sudo mkdir -p $PROD_SECRETS_DIR && sudo chown deploy:deploy $PROD_SECRETS_DIR && sudo chmod 750 $PROD_SECRETS_DIR"

# Deploy encrypted configuration
echo "Deploying encrypted configuration..."
scp "$CONFIG_FILE" vps:/tmp/
ssh vps "sudo mv /tmp/$CONFIG_FILE $PROD_SECRETS_DIR/ && sudo chown deploy:deploy $PROD_SECRETS_DIR/$CONFIG_FILE && sudo chmod 640 $PROD_SECRETS_DIR/$CONFIG_FILE"

# Phase 2D: Production validation
echo "Phase 2D: Production validation..."

# Validate deployment
ssh vps "ls -la $PROD_SECRETS_DIR/$CONFIG_FILE"

# Test SOPS decryption on server
ssh vps "cd $PROD_SECRETS_DIR && sops -d $CONFIG_FILE > /dev/null" || {
    echo "ERROR: SOPS decryption failed on production server"
    exit 1
}

echo "✅ Production SOPS decryption successful"

# Validate configuration keys
REQUIRED_KEYS=("GH_PAT_READONLY" "KUMA_URL" "KUMA_TOKEN" "CROWDSEC_LAPI_URL" "CROWDSEC_LAPI_KEY" "PORT" "HOST" "AGGREGATOR_ENABLED")
for key in "${REQUIRED_KEYS[@]}"; do
    if ! ssh vps "cd $PROD_SECRETS_DIR && sops -d $CONFIG_FILE | grep -q '^$key='" ; then
        echo "ERROR: Required key $key missing from configuration"
        exit 1
    fi
done

echo "✅ All required configuration keys present"

# Phase 2E: Service readiness validation
echo "Phase 2E: Service readiness validation..."

# Check if dashboard aggregator service exists
if ssh vps "systemctl list-unit-files | grep -q dashboard-aggregator"; then
    echo "Dashboard aggregator service found"
    SERVICE_STATUS=$(ssh vps "systemctl is-active dashboard-aggregator.service || echo 'inactive'")
    echo "Service status: $SERVICE_STATUS"
else
    echo "Dashboard aggregator service not yet configured (expected for Phase 2)"
fi

echo "=== DSHB-053 Phase 2 Complete ==="
echo "✅ Configuration deployed to: $PROD_SECRETS_DIR/$CONFIG_FILE"
echo "✅ SOPS decryption validated on production"
echo "✅ All required configuration keys present"
echo ""
echo "Phase 3 Ready: Git push trigger + conditional deployment activation"
echo "Evidence: Encrypted configuration deployed with banking-level security"