# Perbaikan Database Staging

## Masalah
Error: `The table 'main.User' does not exist in the current database`

## Solusi

### Opsi 1: Jalankan Script Otomatis
```bash
# Upload file fix-staging-db.sh ke server, lalu jalankan:
chmod +x fix-staging-db.sh
./fix-staging-db.sh
```

### Opsi 2: Jalankan Perintah Manual

**1. Masuk ke direktori staging:**
```bash
cd /var/www/prima-web-staging/api
```

**2. Periksa file .env:**
```bash
ls -la .env
```

**3. Jika .env tidak ada, buat file:**
```bash
cat > .env << 'EOF'
DATABASE_URL="file:/var/www/prima-web-staging/api/prisma/dev.db"
JWT_SECRET="your-jwt-secret-staging"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF
```

**4. Generate Prisma client:**
```bash
npx prisma generate
```

**5. Deploy migrations:**
```bash
npx prisma migrate deploy
```

**6. Push schema:**
```bash
npx prisma db push --accept-data-loss
```

**7. Seed admin user:**
```bash
node prisma/seed-minimal.js
```

**8. Restart PM2:**
```bash
pm2 restart prima-web-api-staging
```

**9. Cek status:**
```bash
pm2 status prima-web-api-staging
pm2 logs prima-web-api-staging --lines 10
```

## Verifikasi

Setelah menjalankan perintah di atas:

1. **Cek database:**
```bash
npx prisma studio --port 5556
```

2. **Test login:**
- URL: https://web-staging.partaiprima.id
- Username: `admin`
- Password: `admin123`

## Troubleshooting

**Jika masih error:**

1. **Periksa path database:**
```bash
ls -la prisma/dev.db
```

2. **Periksa permissions:**
```bash
ls -la prisma/
chmod 755 prisma/
chmod 644 prisma/dev.db
```

3. **Periksa PM2 environment:**
```bash
pm2 show prima-web-api-staging
```

4. **Restart PM2 dengan environment yang benar:**
```bash
pm2 delete prima-web-api-staging
pm2 start ecosystem.config.js --only prima-web-api-staging
``` 