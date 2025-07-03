#!/bin/bash

echo "=== PERBAIKAN LENGKAP STAGING ==="

# 1. Masuk ke direktori staging
cd /var/www/prima-web-staging/api

echo "📁 Direktori saat ini: $(pwd)"

# 2. Periksa file .env
echo "🔍 Memeriksa file .env..."
if [ ! -f ".env" ]; then
    echo "❌ File .env tidak ditemukan, membuat dari template..."
    cat > .env << EOF
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

# 3. Periksa direktori prisma
echo "📂 Memeriksa direktori prisma..."
ls -la prisma/

# 4. Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# 5. Deploy migrations
echo "🚀 Deploying migrations..."
npx prisma migrate deploy

# 6. Push schema (untuk memastikan)
echo "📤 Pushing schema..."
npx prisma db push --accept-data-loss

# 7. Seed admin user
echo "🌱 Seeding admin user..."
node prisma/seed-minimal.js

# 8. Periksa database
echo "🔍 Memeriksa database..."
npx prisma studio --port 5556 &
STUDIO_PID=$!
sleep 3
kill $STUDIO_PID

# 9. Restart PM2
echo "🔄 Restarting PM2..."
pm2 restart prima-web-api-staging

# 10. Cek status
echo "📊 Status PM2:"
pm2 status

echo "📋 Logs terakhir:"
pm2 logs prima-web-api-staging --lines 5

echo "=== SELESAI ==="
echo "🔑 Login credentials: admin / admin123"
echo "🌐 URL: https://web-staging.partaiprima.id" 