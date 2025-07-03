#!/bin/bash

echo "🔧 Setup Sudoers untuk CI/CD..."

# Backup sudoers file
echo "📋 Backup sudoers file..."
sudo cp /etc/sudoers /etc/sudoers.backup

# Add sudoers entry for primax user
echo "👤 Setup sudoers untuk user primax..."
sudo tee -a /etc/sudoers > /dev/null << EOF

# CI/CD Sudoers for primax user
primax ALL=(ALL) NOPASSWD: /usr/bin/mkdir -p /var/www/prima-web*
primax ALL=(ALL) NOPASSWD: /usr/bin/chown -R primax\:primax /var/www/prima-web*
primax ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
primax ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
primax ALL=(ALL) NOPASSWD: /usr/bin/nginx -t
EOF

# Test sudoers syntax
echo "🔍 Test sudoers syntax..."
sudo visudo -c

if [ $? -eq 0 ]; then
    echo "✅ Sudoers setup berhasil!"
    echo ""
    echo "📋 Commands yang bisa dijalankan tanpa password:"
    echo "   - mkdir -p /var/www/prima-web*"
    echo "   - chown -R primax:primax /var/www/prima-web*"
    echo "   - systemctl reload nginx"
    echo "   - systemctl restart nginx"
    echo "   - nginx -t"
else
    echo "❌ Sudoers syntax error!"
    echo "📋 Restore backup..."
    sudo cp /etc/sudoers.backup /etc/sudoers
    exit 1
fi 