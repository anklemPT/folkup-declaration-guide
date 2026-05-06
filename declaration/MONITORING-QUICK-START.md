# DECL Monitoring Quick Start Guide

**Target:** Get basic monitoring operational in <30 minutes  
**Date:** 2026-05-06  

## Step 1: UptimeRobot Setup (10 minutes)

### Account Creation
1. Visit https://uptimerobot.com
2. Sign up with anklemqq@gmail.com
3. Verify email

### Monitor Configuration
```
Monitor Type: HTTP(s)
URL: https://declaration.folkup.app
Friendly Name: DECL Production
Monitoring Interval: 5 minutes
Alert Contacts: anklemqq@gmail.com
```

### Advanced Settings
- **Keyword Monitoring:** "Declaration Guide" (verify page loads correctly)
- **SSL Certificate:** Enable expiration alerts (30 days)
- **Response Time:** Alert if >3000ms
- **Locations:** Europe (Amsterdam, London, Frankfurt)

## Step 2: Performance Baseline (5 minutes)

### Google PageSpeed Test
```bash
# Run initial performance audit
curl "https://www.googleapis.com/pagespeedinights/v5/runPagespeed?url=https://declaration.folkup.app&category=performance&category=accessibility&category=seo"
```

### Expected Baseline
- Performance: >90
- Accessibility: >95
- SEO: >90
- Load Time: <2s

## Step 3: Basic Health Check Script (10 minutes)

Create `monitoring/health-check.sh`:
```bash
#!/bin/bash
# DECL Health Check - Run daily

URL="https://declaration.folkup.app"
LOG_FILE="monitoring/health-$(date +%Y%m%d).log"

echo "=== DECL Health Check $(date) ===" >> $LOG_FILE

# 1. Site accessibility
echo "Checking site accessibility..." >> $LOG_FILE
if curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200"; then
    echo "✅ Site accessible" >> $LOG_FILE
else
    echo "❌ Site inaccessible" >> $LOG_FILE
fi

# 2. SSL certificate
echo "Checking SSL certificate..." >> $LOG_FILE
SSL_EXPIRY=$(echo | openssl s_client -connect declaration.folkup.app:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
echo "SSL expires: $SSL_EXPIRY" >> $LOG_FILE

# 3. Security headers
echo "Checking security headers..." >> $LOG_FILE
HEADERS=$(curl -I -s $URL)
if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    echo "✅ HSTS header present" >> $LOG_FILE
else
    echo "❌ HSTS header missing" >> $LOG_FILE
fi

# 4. Content integrity
echo "Checking content integrity..." >> $LOG_FILE
if curl -s $URL | grep -q "Declaration Guide"; then
    echo "✅ Content loads correctly" >> $LOG_FILE
else
    echo "❌ Content loading issues" >> $LOG_FILE
fi

# 5. Language switching
if curl -s $URL | grep -q "lang-tab"; then
    echo "✅ Language switching available" >> $LOG_FILE
else
    echo "❌ Language switching missing" >> $LOG_FILE
fi

echo "=== Check complete ===" >> $LOG_FILE
echo "" >> $LOG_FILE

# Email results if errors found
if grep -q "❌" $LOG_FILE; then
    echo "Errors detected in DECL health check. See attached log." | mail -s "DECL Health Alert" anklemqq@gmail.com < $LOG_FILE
fi
```

## Step 4: Backup Script Setup (5 minutes)

Create `monitoring/backup.sh`:
```bash
#!/bin/bash
# DECL Backup Script - Run weekly

BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup production site
echo "Creating production backup..."
wget -r -p -k https://declaration.folkup.app -P $BACKUP_DIR/

# Backup configuration files
cp netlify.toml $BACKUP_DIR/
cp index.html $BACKUP_DIR/
cp -r images/ $BACKUP_DIR/ 2>/dev/null || echo "No images directory"

# Create archive
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR/
echo "Backup complete: $BACKUP_DIR.tar.gz"

# Clean old backups (keep 4 weeks)
find backups/ -name "*.tar.gz" -mtime +28 -delete
```

## Step 5: Automated Scheduling

### Linux/macOS (cron)
```bash
# Edit crontab
crontab -e

# Add these lines:
# Daily health check at 9 AM
0 9 * * * /path/to/monitoring/health-check.sh

# Weekly backup on Sundays at 2 AM
0 2 * * 0 /path/to/monitoring/backup.sh
```

### Windows (Task Scheduler)
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger: Daily/Weekly
4. Set action: Start program
5. Point to bash script location

## Verification Checklist

After setup, verify:
- [ ] UptimeRobot sends test alert
- [ ] Health check script runs successfully  
- [ ] Backup script creates valid archive
- [ ] Email notifications work
- [ ] Performance baseline recorded

## Next Steps

1. **Week 1:** Monitor for baseline stability
2. **Week 2:** Add performance regression detection
3. **Week 3:** Implement incident response procedures
4. **Month 1:** Full strategy implementation per PRODUCTION-MONITORING-STRATEGY.md

## Emergency Contacts

- **Primary:** anklemqq@gmail.com
- **Escalation:** Manual check via https://declaration.folkup.app
- **Status:** UptimeRobot status page (if configured)

---

**Quick Start Complete!** 🎯  
Basic monitoring operational in 30 minutes.  
Full strategy implementation roadmap available in PRODUCTION-MONITORING-STRATEGY.md.