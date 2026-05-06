#!/bin/bash
# DECL Health Check - Run daily
# Enhanced Alice v2.0 Level 3 Autonomous Implementation

URL="https://declaration.folkup.app"
LOG_FILE="health-$(date +%Y%m%d).log"

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

# 6. Educational content verification
if curl -s $URL | grep -q "civic responsibility"; then
    echo "✅ Educational content present" >> $LOG_FILE
else
    echo "❌ Educational content missing" >> $LOG_FILE
fi

echo "=== Check complete ===" >> $LOG_FILE
echo "" >> $LOG_FILE

# Email results if errors found
if grep -q "❌" $LOG_FILE; then
    echo "Errors detected in DECL health check. See attached log." | mail -s "DECL Health Alert" anklemqq@gmail.com < $LOG_FILE 2>/dev/null || echo "Email notification failed - check local log"
fi