module.exports = {
  apps: [
    // Production API
    {
      name: 'prima-web-api',
      script: '/var/www/prima-web/api/src/app.js',
      cwd: '/var/www/prima-web/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        DATABASE_URL: 'file:./prisma/dev.db',
        JWT_SECRET: 'your-jwt-secret-here'
      },
      error_file: '/var/log/pm2/prima-web-api-error.log',
      out_file: '/var/log/pm2/prima-web-api-out.log',
      log_file: '/var/log/pm2/prima-web-api-combined.log',
      time: true
    },
    
    // Staging API
    {
      name: 'prima-web-api-staging',
      script: '/var/www/prima-web-staging/api/src/app.js',
      cwd: '/var/www/prima-web-staging/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'staging',
        PORT: 3002,
        DATABASE_URL: 'file:./prisma/dev.db',
        JWT_SECRET: 'your-jwt-secret-staging'
      },
      error_file: '/var/log/pm2/prima-web-api-staging-error.log',
      out_file: '/var/log/pm2/prima-web-api-staging-out.log',
      log_file: '/var/log/pm2/prima-web-api-staging-combined.log',
      time: true
    }
  ]
}; 