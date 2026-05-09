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
