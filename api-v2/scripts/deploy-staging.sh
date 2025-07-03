#!/bin/bash

# Robust Staging Deployment Script
# This script handles staging deployment with proper error handling

set -e  # Exit on any error

echo "🚀 STAGING DEPLOYMENT STARTED"
echo "=============================="

# Change to staging directory
cd /var/www/prima-web-staging/api

echo "📁 Working directory: $(pwd)"

# Step 1: Install dependencies
echo "📦 Installing dependencies..."
npm install --production
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✅ Dependencies installed"

# Step 2: Create .env file
echo "📝 Creating .env file..."
cat > .env << 'EOF'
DATABASE_URL="file:/var/www/prima-web-staging/api/prisma/dev.db"
JWT_SECRET="your-jwt-secret-staging"
OCR_API_URL="http://localhost:9000"
WILAYAH_API_URL="http://localhost:3002"
OCR_API_KEY="GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc"
EOF

# Verify .env file was created
if [ ! -f .env ]; then
    echo "❌ Failed to create .env file"
    exit 1
fi
echo "✅ .env file created"

# Step 3: Setup database
echo "🔧 Setting up database..."

# Generate Prisma client
echo "  - Generating Prisma client..."
npx prisma generate
if [ $? -ne 0 ]; then
    echo "❌ Failed to generate Prisma client"
    exit 1
fi

# Remove old database files
echo "  - Removing old database files..."
rm -f prisma/dev.db
rm -f prisma/dev.db-journal

# Deploy migrations
echo "  - Deploying migrations..."
npx prisma migrate deploy
if [ $? -ne 0 ]; then
    echo "❌ Failed to deploy migrations"
    exit 1
fi

# Push schema
echo "  - Pushing schema..."
npx prisma db push --accept-data-loss
if [ $? -ne 0 ]; then
    echo "❌ Failed to push schema"
    exit 1
fi

# Verify database file exists
if [ ! -f prisma/dev.db ]; then
    echo "❌ Database file not created"
    exit 1
fi
echo "✅ Database setup completed"

# Step 4: Seed admin user
echo "🌱 Seeding admin user..."
node prisma/seed-minimal.js
if [ $? -ne 0 ]; then
    echo "❌ Failed to seed admin user"
    exit 1
fi
echo "✅ Admin user seeded"

# Step 5: Restart PM2
echo "🔄 Restarting PM2 service..."
if [ -f src/app.js ]; then
    pm2 restart prima-web-api-staging || pm2 start src/app.js --name prima-web-api-staging
    if [ $? -ne 0 ]; then
        echo "❌ Failed to restart PM2"
        exit 1
    fi
else
    echo "❌ src/app.js not found"
    ls -la src/
    exit 1
fi
echo "✅ PM2 service restarted"

# Step 6: Reload nginx
echo "🌐 Reloading nginx..."
sudo systemctl reload nginx
if [ $? -ne 0 ]; then
    echo "⚠️  Warning: Failed to reload nginx"
else
    echo "✅ Nginx reloaded"
fi

# Step 7: Final verification
echo "🔍 Final verification..."
pm2 status prima-web-api-staging

echo ""
echo "🎉 STAGING DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "🔑 Login credentials: admin / admin123"
echo "🌐 URL: https://web-staging.partaiprima.id" 