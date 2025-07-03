#!/bin/bash

# Script untuk reload nginx tanpa sudo password
# Script ini harus dijalankan dengan NOPASSWD sudo privileges

echo "Reloading nginx configuration..."

# Reload nginx configuration
sudo systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Failed to reload nginx"
    exit 1
fi 