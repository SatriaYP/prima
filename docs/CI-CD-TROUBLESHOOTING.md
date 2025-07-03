# Troubleshooting CI/CD Deployment

## Masalah: Sudo Password Required

### Error yang muncul:
```
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
Error: Process completed with exit code 1.
```

### Penyebab:
GitHub Actions tidak bisa menjalankan perintah `sudo` yang memerlukan password karena tidak ada terminal interaktif.

### Solusi:

#### Opsi 1: Setup NOPASSWD sudo (Recommended)

1. **Login ke server sebagai root atau user dengan sudo:**
```bash
ssh root@212.85.26.97
# atau
ssh user@212.85.26.97
```

2. **Edit file sudoers:**
```bash
sudo visudo
```

3. **Tambahkan baris berikut di akhir file:**
```
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx
```

4. **Simpan dan keluar (Ctrl+X, Y, Enter)**

#### Opsi 2: Gunakan Script Setup Otomatis

1. **Upload script setup ke server:**
```bash
scp scripts/setup-server.sh root@212.85.26.97:/tmp/
```

2. **Jalankan script setup:**
```bash
ssh root@212.85.26.97
chmod +x /tmp/setup-server.sh
/tmp/setup-server.sh prima
```

3. **Generate SSH key untuk deployment:**
```bash
ssh prima@212.85.26.97
ssh-keygen -t rsa -b 4096 -C "prima@deployment" -f ~/.ssh/id_rsa -N ""
```

4. **Ambil private key untuk GitHub Secrets:**
```bash
cat ~/.ssh/id_rsa
```

#### Opsi 3: Manual Setup (Jika tidak bisa menggunakan script)

1. **Buat user deployment:**
```bash
sudo adduser prima
sudo usermod -aG sudo prima
```

2. **Buat direktori deployment:**
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

3. **Setup NOPASSWD sudo:**
```bash
sudo visudo
# Tambahkan baris:
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
prima ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx
```

4. **Buat script deployment:**
```bash
sudo mkdir -p /home/prima/deploy-scripts
sudo chown prima:prima /home/prima/deploy-scripts

cat > /home/prima/deploy-scripts/reload-nginx.sh << 'EOF'
#!/bin/bash
echo "Reloading nginx configuration..."
sudo systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Failed to reload nginx"
    exit 1
fi
EOF

sudo chmod +x /home/prima/deploy-scripts/reload-nginx.sh
sudo chown prima:prima /home/prima/deploy-scripts/reload-nginx.sh
```

## Setup GitHub Secrets

Setelah setup server selesai, tambahkan secrets berikut di repository GitHub:

1. **Buka repository di GitHub**
2. **Pergi ke Settings > Secrets and variables > Actions**
3. **Klik "New repository secret"**
4. **Tambahkan secrets:**

### SSH_PRIVATE_KEY
- **Name:** `SSH_PRIVATE_KEY`
- **Value:** Isi dari file `/home/prima/.ssh/id_rsa` (private key)

### SSH_USER
- **Name:** `SSH_USER`
- **Value:** `prima`

## Testing Deployment

### Test SSH Connection
```bash
ssh prima@212.85.26.97
```

### Test Script Deployment
```bash
ssh prima@212.85.26.97 "/home/prima/deploy-scripts/reload-nginx.sh"
```

### Test PM2 Commands
```bash
ssh prima@212.85.26.97 "pm2 list"
```

## Troubleshooting Lainnya

### Error: Permission Denied
```bash
# Cek permission folder
ls -la /var/www/prima-v2/
ls -la /var/www/prima-staging-v2/

# Fix permission jika perlu
sudo chown -R prima:prima /var/www/prima-v2/
sudo chown -R prima:prima /var/www/prima-staging-v2/
```

### Error: PM2 Not Found
```bash
# Install PM2
sudo npm install -g pm2

# Setup PM2 startup
sudo -u prima pm2 startup
```

### Error: Nginx Not Reloading
```bash
# Test nginx config
sudo nginx -t

# Check nginx status
sudo systemctl status nginx

# Check nginx logs
sudo journalctl -u nginx -f
```

### Error: Port Already in Use
```bash
# Check what's using the port
sudo netstat -tlnp | grep :3003
sudo netstat -tlnp | grep :3004

# Kill process if needed
sudo kill -9 <PID>
```

## Monitoring Deployment

### Check GitHub Actions
1. Buka repository di GitHub
2. Klik tab "Actions"
3. Monitor workflow yang sedang berjalan

### Check Server Logs
```bash
# PM2 logs
pm2 logs prima-api-v2
pm2 logs prima-api-staging-v2

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Check Application Status
```bash
# PM2 status
pm2 list

# Nginx status
sudo systemctl status nginx

# Check ports
sudo netstat -tlnp | grep -E ':(3003|3004|80|443)'
``` 