# Server Setup untuk Aplikasi Web Prima

Dokumentasi ini menjelaskan setup server untuk aplikasi web Prima yang terpisah dari aplikasi Flutter.

## 🏗️ **Struktur Server**

### Direktori
```
/var/www/
├── prima/                    # Aplikasi Flutter Prima (existing)
├── prima-web-staging/        # Web App Staging
│   ├── api/                 # API v2 backend (port 3002)
│   └── web/                 # Vue.js frontend
└── prima-web/               # Web App Production
    ├── api/                 # API v2 backend (port 3001)
    └── web/                 # Vue.js frontend
```

### Port Allocation
- **Port 3001:** Production API (prima-web-api)
- **Port 3002:** Staging API (prima-web-api-staging)
- **Port 9000:** OCR API (existing)
- **Port 80/443:** Nginx (existing)

## 🌐 **Domain Configuration**

### Cloudflare DNS Records
```
Type    Name                    Value           Proxy
A       web-staging            212.85.26.97    ✅ (Orange Cloud)
A       web                    212.85.26.97    ✅ (Orange Cloud)
```

### SSL Certificates
- **Origin Certificate:** Cloudflare Origin Certificate
- **Path:** `/etc/ssl/certs/cloudflare-origin.pem`
- **Key:** `/etc/ssl/private/cloudflare-origin.key`

## ⚙️ **Installation Steps**

### 1. **Persiapan Server**
```bash
# Login ke server
ssh primax@212.85.26.97

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y nginx nodejs npm git
```

### 2. **Setup Direktori**
```bash
# Buat direktori
sudo mkdir -p /var/www/prima-web-staging/{api,web}
sudo mkdir -p /var/www/prima-web/{api,web}
sudo mkdir -p /var/log/pm2

# Set ownership
sudo chown -R primax:primax /var/www/prima-web*
sudo chown -R primax:primax /var/log/pm2
```

### 3. **Install PM2**
```bash
# Install PM2 globally
sudo npm install -g pm2

# Setup PM2 startup
pm2 startup
# Follow instructions yang muncul
```

### 4. **Setup Nginx**
```bash
# Copy config file
sudo cp nginx-prima-web.conf /etc/nginx/sites-available/prima-web

# Enable site
sudo ln -sf /etc/nginx/sites-available/prima-web /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 5. **Setup PM2 Ecosystem**
```bash
# Copy ecosystem config
sudo cp ecosystem.config.js /var/www/

# Start services (akan kosong sampai deployment pertama)
cd /var/www
pm2 start ecosystem.config.js
pm2 save
```

### 6. **Setup Log Rotation**
```bash
# Create logrotate config
sudo tee /etc/logrotate.d/pm2-prima-web > /dev/null << EOF
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
```

### 7. **Setup Firewall**
```bash
# Allow ports
sudo ufw allow 3001/tcp
sudo ufw allow 3002/tcp

# Check status
sudo ufw status
```

## 🔧 **Configuration Files**

### Nginx Configuration
File: `/etc/nginx/sites-available/prima-web`

**Features:**
- SSL termination dengan Cloudflare Origin Certificate
- Proxy pass ke API backend
- Static file serving untuk Vue.js SPA
- Security headers
- Cache optimization untuk static assets

### PM2 Ecosystem
File: `/var/www/ecosystem.config.js`

**Features:**
- Separate config untuk staging dan production
- Log rotation dan monitoring
- Memory limit (1GB per instance)
- Auto-restart on crash

## 📊 **Monitoring & Logs**

### PM2 Commands
```bash
# View all processes
pm2 list

# View logs
pm2 logs prima-web-api
pm2 logs prima-web-api-staging

# Monitor resources
pm2 monit

# Restart services
pm2 restart prima-web-api
pm2 restart prima-web-api-staging
```

### Nginx Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/access.log

# Error logs
sudo tail -f /var/log/nginx/error.log
```

### Application Logs
```bash
# Production API logs
tail -f /var/log/pm2/prima-web-api-combined.log

# Staging API logs
tail -f /var/log/pm2/prima-web-api-staging-combined.log
```

## 🚀 **Deployment Process**

### First Deployment
1. **Setup GitHub Secrets:**
   - `SSH_PRIVATE_KEY`
   - `SSH_USER` (primax)

2. **Push to develop branch:**
   ```bash
   git push origin develop
   ```

3. **Monitor deployment:**
   - Check GitHub Actions
   - Monitor server logs
   - Test staging URL

4. **Push to main branch:**
   ```bash
   git push origin main
   ```

### Manual Deployment
```bash
# Deploy API
cd /var/www/prima-web/api
git pull origin main
npm install --production
pm2 restart prima-web-api

# Deploy Web
cd /var/www/prima-web/web
git pull origin main
npm install
npm run build
# Files akan di-copy otomatis oleh workflow
```

## 🔍 **Troubleshooting**

### Common Issues

1. **Nginx 502 Bad Gateway**
   ```bash
   # Check if API is running
   pm2 list
   
   # Check API logs
   pm2 logs prima-web-api
   
   # Check port
   netstat -tlnp | grep :3001
   ```

2. **SSL Certificate Issues**
   ```bash
   # Check certificate
   sudo nginx -t
   
   # Check certificate validity
   openssl x509 -in /etc/ssl/certs/cloudflare-origin.pem -text -noout
   ```

3. **Permission Issues**
   ```bash
   # Fix ownership
   sudo chown -R primax:primax /var/www/prima-web*
   sudo chown -R primax:primax /var/log/pm2
   ```

4. **Port Conflicts**
   ```bash
   # Check port usage
   sudo netstat -tlnp | grep :3001
   sudo netstat -tlnp | grep :3002
   ```

### Health Check URLs
- **Staging:** `https://web-staging.partaiprima.id/api/health`
- **Production:** `https://web.partaiprima.id/api/health`

## 📈 **Performance Optimization**

### Nginx Optimization
- Gzip compression
- Static file caching
- Security headers
- HTTP/2 support

### PM2 Optimization
- Memory limits
- Auto-restart
- Log rotation
- Process monitoring

### Database Optimization
- Connection pooling
- Query optimization
- Index optimization

## 🔒 **Security Considerations**

### SSL/TLS
- Cloudflare Origin Certificate
- TLS 1.2+ only
- Strong cipher suites

### Firewall
- Only necessary ports open
- Rate limiting
- DDoS protection via Cloudflare

### Application Security
- JWT token validation
- Input validation
- SQL injection prevention
- XSS protection headers 