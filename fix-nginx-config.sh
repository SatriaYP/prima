#!/bin/bash

echo "🔧 Memperbaiki Konfigurasi Nginx..."

# Backup konfigurasi yang ada
echo "📋 Backup konfigurasi yang ada..."
sudo cp /etc/nginx/sites-available/prima-web /etc/nginx/sites-available/prima-web.backup

# Copy konfigurasi yang diperbaiki
echo "📝 Copy konfigurasi yang diperbaiki..."
sudo cp nginx-prima-web-fixed.conf /etc/nginx/sites-available/prima-web

# Test konfigurasi
echo "🔍 Test konfigurasi Nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Konfigurasi Nginx valid"
    
    # Reload nginx
    echo "🔄 Reload Nginx..."
    sudo systemctl reload nginx
    
    echo "✅ Konfigurasi Nginx berhasil diperbaiki!"
    echo ""
    echo "📋 Status:"
    echo "   - Backup: /etc/nginx/sites-available/prima-web.backup"
    echo "   - Active: /etc/nginx/sites-available/prima-web"
    echo ""
    echo "🌐 Test URLs:"
    echo "   - Staging: https://web-staging.partaiprima.id"
    echo "   - Production: https://web.partaiprima.id"
else
    echo "❌ Konfigurasi Nginx masih bermasalah"
    echo "📋 Restore backup..."
    sudo cp /etc/nginx/sites-available/prima-web.backup /etc/nginx/sites-available/prima-web
    exit 1
fi 