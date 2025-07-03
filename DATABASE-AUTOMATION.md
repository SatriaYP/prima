# Database Automation - Prima.id

## Overview
Sistem sekarang otomatis menangani setup database melalui CI/CD workflow, sehingga tidak perlu setup manual lagi setiap deployment.

## Masalah Sebelumnya
- Database staging/production perlu setup manual setiap deployment
- File `.env` hilang saat deployment baru
- Admin user tidak otomatis dibuat
- Error "table User does not exist" sering terjadi

## Solusi yang Diimplementasikan

### 1. Script Otomatis
**File:** `api-v2/scripts/setup-database.sh`

Script ini otomatis:
- Membuat file `.env` dengan konfigurasi yang benar
- Menjalankan Prisma generate dan migrate
- Setup database schema
- Seed admin user jika database kosong

### 2. CI/CD Integration
**File:** `.github/workflows/combined-ci.yml`

CI/CD workflow sekarang:
- Otomatis menjalankan `scripts/setup-database.sh` saat deployment
- Menangani staging dan production secara terpisah
- Memastikan database siap sebelum restart service

### 3. Environment Templates
**File:** `api-v2/env.template`

Template untuk environment variables yang konsisten.

## Cara Kerja

### Staging Deployment (branch `develop`)
```bash
# CI/CD otomatis menjalankan:
cd /var/www/prima-web-staging/api
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh staging
pm2 restart prima-web-api-staging
```

### Production Deployment (branch `main`)
```bash
# CI/CD otomatis menjalankan:
cd /var/www/prima-web/api
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh production
pm2 restart prima-web-api
```

## Manual Setup (Jika Diperlukan)

### Staging
```bash
cd /var/www/prima-web-staging/api
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh staging
pm2 restart prima-web-api-staging
```

### Production
```bash
cd /var/www/prima-web/api
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh production
pm2 restart prima-web-api
```

## Login Credentials

Setelah setup otomatis:
- **Username:** `admin`
- **Password:** `admin123`

## Troubleshooting

### Jika Script Gagal
1. Periksa permissions:
   ```bash
   chmod +x scripts/setup-database.sh
   ```

2. Periksa Node.js dan npm:
   ```bash
   node --version
   npm --version
   ```

3. Periksa Prisma:
   ```bash
   npx prisma --version
   ```

### Jika Database Masih Error
1. Hapus database dan buat ulang:
   ```bash
   rm prisma/dev.db
   ./scripts/setup-database.sh staging
   ```

2. Periksa logs:
   ```bash
   pm2 logs prima-web-api-staging
   ```

## Keuntungan

1. **Konsistensi** - Setup database selalu sama setiap deployment
2. **Otomatis** - Tidak perlu intervensi manual
3. **Reliable** - Mengurangi kemungkinan error setup
4. **Maintainable** - Mudah diubah dan di-debug
5. **Documented** - Proses ter-dokumentasi dengan baik

## File yang Terlibat

- `api-v2/scripts/setup-database.sh` - Script utama
- `api-v2/env.template` - Template environment
- `api-v2/prisma/seed-minimal.js` - Admin user seeder
- `.github/workflows/combined-ci.yml` - CI/CD workflow
- `docs/CI-CD-SETUP.md` - Dokumentasi lengkap 