#!/bin/bash

echo "🔧 PERBAIKAN STAGING SEKARANG"
echo "=============================="

# Masuk ke direktori staging
cd /var/www/prima-web-staging/api

echo "📁 Direktori: $(pwd)"

# 1. Periksa file yang ada
echo "📂 Memeriksa file yang ada..."
ls -la
echo ""

# 2. Buat .env file dengan force
echo "📝 Membuat .env file..."
cat > .env << 'EOF'
DATABASE_URL="file:/var/www/prima-web-staging/api/prisma/dev.db"
JWT_SECRET="your-jwt-secret-staging"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF
echo "✅ .env file dibuat"

# 3. Install dependencies jika belum
echo "📦 Installing dependencies..."
npm install --production

# 4. Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# 5. Hapus database lama dan buat baru
echo "🗑️ Hapus database lama..."
rm -f prisma/dev.db
rm -f prisma/dev.db-journal

# 6. Deploy migrations
echo "🚀 Deploying migrations..."
npx prisma migrate deploy

# 7. Push schema
echo "📤 Pushing schema..."
npx prisma db push --accept-data-loss

# 8. Seed admin user
echo "🌱 Seeding admin user..."
node prisma/seed-minimal.js

# 9. Periksa database
echo "🔍 Memeriksa database..."
ls -la prisma/
echo ""

# 10. Restart PM2
echo "🔄 Restarting PM2..."
pm2 restart prima-web-api-staging

# 11. Cek status
echo "📊 Status PM2:"
pm2 status prima-web-api-staging

echo ""
echo "✅ SELESAI!"
echo "🔑 Login: admin / admin123"
echo "🌐 URL: https://web-staging.partaiprima.id" 