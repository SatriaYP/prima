#!/bin/bash

echo "⚡ Update PM2 Configuration..."

# Copy new ecosystem config
echo "📝 Copy ecosystem config..."
sudo cp ecosystem.config.js /var/www/

# Stop existing processes
echo "🛑 Stop existing PM2 processes..."
pm2 stop prima-web-api prima-web-api-staging 2>/dev/null || true
pm2 delete prima-web-api prima-web-api-staging 2>/dev/null || true

# Start with new config
echo "🚀 Start PM2 with new config..."
cd /var/www
pm2 start ecosystem.config.js

# Save PM2 config
echo "💾 Save PM2 config..."
pm2 save

echo "✅ PM2 configuration updated!"
echo ""
echo "📋 PM2 Status:"
pm2 list 