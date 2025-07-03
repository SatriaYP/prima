#!/bin/bash

echo "🔧 PERBAIKAN DATABASE STAGING"
echo "================================"

# Masuk ke direktori staging
cd /var/www/prima-web-staging/api

echo "📁 Direktori: $(pwd)"

# 1. Periksa dan buat .env jika tidak ada
if [ ! -f ".env" ]; then
    echo "❌ File .env tidak ditemukan, membuat..."
    cat > .env << 'EOF'
DATABASE_URL="file:/var/www/prima-web-staging/api/prisma/dev.db"
JWT_SECRET="your-jwt-secret-staging"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF
    echo "✅ File .env dibuat"
else
    echo "✅ File .env sudah ada"
fi

# 2. Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# 3. Deploy migrations
echo "🚀 Deploying migrations..."
npx prisma migrate deploy

# 4. Push schema
echo "📤 Pushing schema..."
npx prisma db push --accept-data-loss

# 5. Seed admin user
echo "🌱 Seeding admin user..."
node prisma/seed-minimal.js

# 6. Restart PM2
echo "🔄 Restarting PM2..."
pm2 restart prima-web-api-staging

# 7. Cek status
echo "📊 Status PM2:"
pm2 status prima-web-api-staging

echo ""
echo "✅ SELESAI!"
echo "🔑 Login: admin / admin123"
echo "🌐 URL: https://web-staging.partaiprima.id" 