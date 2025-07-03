#!/bin/bash

# Script Setup Server untuk Aplikasi Web Prima
# Jalankan sebagai root atau dengan sudo

echo "🚀 Setup Server untuk Aplikasi Web Prima..."

# 1. Buat direktori
echo "📁 Membuat direktori..."
mkdir -p /var/www/prima-web-staging/{api,web}
mkdir -p /var/www/prima-web/{api,web}
mkdir -p /var/log/pm2

# 2. Set ownership
echo "👤 Set ownership..."
chown -R primax:primax /var/www/prima-web*
chown -R primax:primax /var/log/pm2

# 3. Copy Nginx config
echo "🌐 Setup Nginx..."
cp nginx-prima-web.conf /etc/nginx/sites-available/prima-web
ln -sf /etc/nginx/sites-available/prima-web /etc/nginx/sites-enabled/

# 4. Test Nginx config
echo "🔍 Test Nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx config valid"
    systemctl reload nginx
else
    echo "❌ Nginx config error"
    exit 1
fi

# 5. Setup PM2
echo "⚡ Setup PM2..."
npm install -g pm2
cp ecosystem.config.js /var/www/
echo "✅ PM2 ecosystem config disimpan di /var/www/ecosystem.config.js"

# 6. Setup log rotation
echo "📝 Setup log rotation..."
cat > /etc/logrotate.d/pm2-prima-web << EOF
/var/log/pm2/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 primax primax
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

# 7. Setup firewall (jika menggunakan ufw)
echo "🔥 Setup firewall..."
ufw allow 3001/tcp
ufw allow 3002/tcp

echo "✅ Setup server selesai!"
echo ""
echo "📋 File locations:"
echo "   - PM2 config: /var/www/ecosystem.config.js"
echo "   - Nginx config: /etc/nginx/sites-available/prima-web"
echo "   - Log rotation: /etc/logrotate.d/pm2-prima-web"
echo ""
echo "📋 Langkah selanjutnya:"
echo "1. Setup domain di Cloudflare:"
echo "   - web-staging.partaiprima.id → 212.85.26.97"
echo "   - web.partaiprima.id → 212.85.26.97"
echo ""
echo "2. Deploy aplikasi pertama kali:"
echo "   - Staging: git push origin develop"
echo "   - Production: git push origin main"
echo ""
echo "3. Monitor logs:"
echo "   - PM2: pm2 logs"
echo "   - Nginx: tail -f /var/log/nginx/access.log" 