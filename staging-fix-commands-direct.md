# Perintah Langsung untuk Perbaiki Staging

## Masalah
- File .env hilang
- Database tidak ter-setup
- Admin user tidak ada
- Error 401 saat login

## Solusi Langsung

**Jalankan perintah ini satu per satu di server:**

```bash
# 1. SSH ke server
ssh primax@212.85.26.97

# 2. Masuk ke direktori staging
cd /var/www/prima-web-staging/api

# 3. Buat .env file
cat > .env << 'EOF'
DATABASE_URL="file:/var/www/prima-web-staging/api/prisma/dev.db"
JWT_SECRET="your-jwt-secret-staging"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF

# 4. Install dependencies
npm install --production

# 5. Generate Prisma
npx prisma generate

# 6. Hapus database lama
rm -f prisma/dev.db
rm -f prisma/dev.db-journal

# 7. Setup database baru
npx prisma migrate deploy
npx prisma db push --accept-data-loss

# 8. Seed admin user
node prisma/seed-minimal.js

# 9. Restart PM2
pm2 restart prima-web-api-staging

# 10. Cek status
pm2 status prima-web-api-staging
```

## Verifikasi

Setelah menjalankan perintah di atas:

1. **Test login:**
   - URL: https://web-staging.partaiprima.id
   - Username: `admin`
   - Password: `admin123`

2. **Cek logs jika masih error:**
   ```bash
   pm2 logs prima-web-api-staging --lines 20
   ```

## Penyebab Masalah

**Ya, kemungkinan besar karena CI/CD deployment yang tidak sempurna:**

1. **Script database setup gagal** - Mungkin ada error saat menjalankan script
2. **File .env tidak terbuat** - CI/CD tidak berhasil membuat file environment
3. **Dependencies tidak ter-install** - npm install gagal
4. **Database tidak ter-reset** - Database lama masih ada tapi tidak valid

## Pencegahan

Untuk ke depannya, CI/CD workflow perlu:
1. **Better error handling** - Tangkap error dan retry
2. **Verification steps** - Pastikan setiap step berhasil
3. **Rollback mechanism** - Jika gagal, rollback ke versi sebelumnya 