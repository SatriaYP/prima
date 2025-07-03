module.exports = {
  apps: [
    // Production API
    {
      name: 'prima-web-api',
      script: 'src/app.js',
      cwd: '/var/www/prima-web/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        DATABASE_URL: 'file:/var/www/prima-web/api/prisma/dev.db',
        JWT_SECRET: 'your-jwt-secret-here',
        OCR_API_URL: 'http://localhost:9000',
        WILAYAH_API_URL: 'http://localhost:3001',
        OCR_API_KEY: 'GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc'
      },
      error_file: '/var/log/pm2/prima-web-api-error.log',
      out_file: '/var/log/pm2/prima-web-api-out.log',
      log_file: '/var/log/pm2/prima-web-api-combined.log',
      time: true
    },
    
    // Staging API
    {
      name: 'prima-web-api-staging',
      script: 'src/app.js',
      cwd: '/var/www/prima-web-staging/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'staging',
        PORT: 3002,
        DATABASE_URL: 'file:/var/www/prima-web-staging/api/prisma/dev.db',
        JWT_SECRET: 'your-jwt-secret-staging',
        OCR_API_URL: 'http://localhost:9000',
        WILAYAH_API_URL: 'http://localhost:3002',
        OCR_API_KEY: 'GbtXXzyMjZgDnSXyFqGHfuNFklv3ZBMrQteUuYkbgWRQXBJlPPPciRc2cjJCrIlqRlJHdlBzkmWblAdO4w35735uuD3dX4MpRFA5zZlIYntNpjaXMhyFHwDqxaFWszRc'
      },
      error_file: '/var/log/pm2/prima-web-api-staging-error.log',
      out_file: '/var/log/pm2/prima-web-api-staging-out.log',
      log_file: '/var/log/pm2/prima-web-api-staging-combined.log',
      time: true
    }
  ]
}; 