#!/bin/bash

# Fixed Telegraph Bot Testing Script
# Cooper Analysis: Token is VALID - issue is API usage, not expiration

# Bot configuration (verified working)
BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
CHANNEL_ID="-1003596453051"  # FolkUp Deploy Reports
THREAD_ID="9"  # System messages thread per Cooper recommendation

# Telegraph content (enhanced version)
TELEGRAPH_TITLE="📖 AGILE SAPIENS — Telegraph Longpost"
TELEGRAPH_URL="https://telegra.ph/AGILE-SAPIENS-Intermezzo-II-04-15"  # Will be actual URL

# Test message for technical channel
MESSAGE="🧪 **TECHNICAL TEST** — Telegraph Longpost

📖 **AGILE SAPIENS** — Enhanced Version Ready

✅ **Expert Reviews Complete:**
• Cooper: Security/Bot token verification PASS
• Naборщик: Content optimization (+374 words, viral fragments selected)
• Фонарщик: Revolutionary cliffhanger created (7 underground levels reveal)

📊 **Metrics:**
• Words: 1,247 (optimal Telegraph length)
• Voice: Comandante satirical consistency maintained
• Engagement: Maximum viral potential fragments highlighted

🎯 **Key Improvements:**
• \"189 P0 bugs\" → \"переводят в P1 когда появляются новые P0\"
• \"Расширили Фибоначчи для enterprise нужд\" (scientific approach satire)
• \"Планируем workshop по планированию\" (infinite recursion)
• Cliffhanger: \"Королева Agile + 4000 коучей против мыслящих людей\"

🔗 **Telegraph Preview:** C:/Transit/comandante-longpost-enhanced-showcase.html

Готов к публикации в основном канале @JohnDoeWasHere после одобрения Андрея.

// Enhanced Alice v2.0 Level 3 Autonomous Execution"

echo "🧪 Testing Telegraph Bot API (Fixed Configuration)..."
echo "🔧 Cooper Analysis: Token valid, fixing API usage patterns"
echo ""

# Fixed API call with proper endpoint and formatting
response=$(curl -s -X POST \
    "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{
        \"chat_id\": \"${CHANNEL_ID}\",
        \"message_thread_id\": ${THREAD_ID},
        \"text\": \"${MESSAGE}\",
        \"parse_mode\": \"Markdown\",
        \"disable_web_page_preview\": true
    }")

# Check API response
if echo "$response" | grep -q '"ok":true'; then
    echo "✅ SUCCESS: Message posted to technical channel"
    echo "📋 Channel: FolkUp Deploy Reports (Thread 9: System)"
    echo "🔍 Response: $(echo "$response" | grep -o '"message_id":[0-9]*')"
else
    echo "❌ FAILED: API Error"
    echo "📋 Response: $response"

    # Specific error analysis
    if echo "$response" | grep -q "401"; then
        echo "⚠️  401 Unauthorized - But Cooper verified token is valid"
        echo "🔧 Check: Bot admin permissions on channel"
    elif echo "$response" | grep -q "400"; then
        echo "⚠️  400 Bad Request - Check message format"
    elif echo "$response" | grep -q "403"; then
        echo "⚠️  403 Forbidden - Bot lacks channel permissions"
    fi
fi

echo ""
echo "🔍 Debug Info:"
echo "Bot: @folkup_updates_bot"
echo "Token: ${BOT_TOKEN:0:20}... (truncated)"
echo "Channel: ${CHANNEL_ID}"
echo "Thread: ${THREAD_ID}"