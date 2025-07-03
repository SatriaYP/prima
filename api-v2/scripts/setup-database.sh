#!/bin/bash

# Script untuk setup database otomatis
# Dipanggil dari CI/CD workflow

ENVIRONMENT=$1
API_DIR="/var/www/prima-web-${ENVIRONMENT}/api"

echo "🔧 Setting up database for ${ENVIRONMENT}..."

cd $API_DIR

# Create .env file if not exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
DATABASE_URL="file:${API_DIR}/prisma/dev.db"
JWT_SECRET="your-jwt-secret-${ENVIRONMENT}"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Setup database
echo "🔧 Generating Prisma client..."
npx prisma generate

echo "🚀 Deploying migrations..."
npx prisma migrate deploy

echo "📤 Pushing schema..."
npx prisma db push --accept-data-loss

# Seed admin user if database is empty
if [ ! -f prisma/dev.db ] || [ ! -s prisma/dev.db ]; then
    echo "🌱 Seeding admin user..."
    node prisma/seed-minimal.js
    echo "✅ Admin user seeded"
else
    echo "✅ Database already has data"
fi

echo "🎉 Database setup completed for ${ENVIRONMENT}" 