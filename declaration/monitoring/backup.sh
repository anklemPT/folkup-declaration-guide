#!/bin/bash
# DECL Backup Script - Run weekly
# Enhanced Alice v2.0 Level 3 Autonomous Implementation

BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup production site
echo "Creating production backup..."
wget -r -p -k https://declaration.folkup.app -P $BACKUP_DIR/ 2>/dev/null

# Backup configuration files
cp netlify.toml $BACKUP_DIR/ 2>/dev/null || echo "netlify.toml not found - production config may differ"
cp index.html $BACKUP_DIR/ 2>/dev/null || echo "index.html not found"
cp -r images/ $BACKUP_DIR/ 2>/dev/null || echo "No images directory"

# Backup git state
git log --oneline -10 > $BACKUP_DIR/recent-commits.txt
git status --porcelain > $BACKUP_DIR/git-status.txt

# Create archive
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR/
echo "Backup complete: $BACKUP_DIR.tar.gz"

# Clean old backups (keep 4 weeks)
find backups/ -name "*.tar.gz" -mtime +28 -delete 2>/dev/null

# Log backup completion
echo "$(date): Backup completed - $BACKUP_DIR.tar.gz" >> backup.log