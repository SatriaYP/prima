# Setup Server untuk Deployment CI/CD

## 1. Setup User dan Permissions

### Buat user deployment (jika belum ada)
```bash
sudo adduser prima
sudo usermod -aG sudo prima
```

### Setup NOPASSWD sudo untuk user prima
```bash
sudo visudo
```

Tambahkan baris berikut di akhir file:
```
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx
```

### Buat direktori deployment
```bash
sudo mkdir -p /var/www/prima-v2/api
sudo mkdir -p /var/www/prima-v2/web
sudo mkdir -p /var/www/prima-staging-v2/api
sudo mkdir -p /var/www/prima-staging-v2/web

sudo chown -R prima:prima /var/www/prima-v2/
sudo chown -R prima:prima /var/www/prima-staging-v2/
sudo chmod -R 755 /var/www/prima-v2/
sudo chmod -R 755 /var/www/prima-staging-v2/
```

## 2. Setup SSH Key

### Generate SSH key pair (jika belum ada)
```bash
ssh-keygen -t rsa -b 4096 -C "prima@deployment"
```

### Tambahkan public key ke authorized_keys
```bash
mkdir -p /home/prima/.ssh
cat ~/.ssh/id_rsa.pub >> /home/prima/.ssh/authorized_keys
chmod 700 /home/prima/.ssh
chmod 600 /home/prima/.ssh/authorized_keys
chown -R prima:prima /home/prima/.ssh
```

## 3. Setup Deployment Scripts

### Buat direktori scripts
```bash
sudo mkdir -p /home/prima/deploy-scripts
sudo chown prima:prima /home/prima/deploy-scripts
```

### Upload script reload-nginx.sh
Upload file `deploy-scripts/reload-nginx.sh` ke `/home/prima/deploy-scripts/reload-nginx.sh`

### Set permission script
```bash
sudo chmod +x /home/prima/deploy-scripts/reload-nginx.sh
sudo chown prima:prima /home/prima/deploy-scripts/reload-nginx.sh
```

## 4. Setup PM2 Ecosystem

### Install PM2 (jika belum)
```bash
sudo npm install -g pm2
```

### Setup PM2 startup
```bash
pm2 startup
# Ikuti instruksi yang muncul
```

## 5. Setup Nginx Configuration

### Konfigurasi untuk production
```nginx
# /etc/nginx/sites-available/prima-v2
server {
    listen 80;
    server_name web.partaiprima.id;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name web.partaiprima.id;
    
    ssl_certificate /etc/ssl/certs/prima-v2.crt;
    ssl_certificate_key /etc/ssl/private/prima-v2.key;
    
    # Frontend
    location / {
        root /var/www/prima-v2/web;
        try_files $uri $uri/ /index.html;
    }
    
    # API
    location /api/ {
        proxy_pass http://localhost:3003/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Konfigurasi untuk staging
```nginx
# /etc/nginx/sites-available/prima-staging-v2
server {
    listen 80;
    server_name staging.web.partaiprima.id;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name staging.web.partaiprima.id;
    
    ssl_certificate /etc/ssl/certs/prima-staging-v2.crt;
    ssl_certificate_key /etc/ssl/private/prima-staging-v2.key;
    
    # Frontend
    location / {
        root /var/www/prima-staging-v2/web;
        try_files $uri $uri/ /index.html;
    }
    
    # API
    location /api/ {
        proxy_pass http://localhost:3004/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Aktifkan konfigurasi
```bash
sudo ln -s /etc/nginx/sites-available/prima-v2 /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/prima-staging-v2 /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 6. GitHub Secrets Setup

Di repository GitHub, tambahkan secrets berikut:

- `SSH_PRIVATE_KEY`: Private key dari server (isi dari `/home/prima/.ssh/id_rsa`)
- `SSH_USER`: Username di server (`prima`)

## 7. Testing Deployment

### Test SSH connection
```bash
ssh prima@212.85.26.97
```

### Test script deployment
```bash
ssh prima@212.85.26.97 "/home/prima/deploy-scripts/reload-nginx.sh"
```

### Test PM2 commands
```bash
ssh prima@212.85.26.97 "pm2 list"
```

## 8. Troubleshooting

### Jika ada error permission
```bash
sudo chown -R prima:prima /var/www/prima-v2/
sudo chown -R prima:prima /var/www/prima-staging-v2/
```

### Jika PM2 tidak start
```bash
pm2 delete prima-api-v2 prima-api-staging-v2
pm2 start ecosystem.config.js
pm2 save
```

### Jika nginx tidak reload
```bash
sudo nginx -t
sudo systemctl status nginx
sudo journalctl -u nginx -f
``` 