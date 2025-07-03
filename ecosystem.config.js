module.exports = {
  apps: [
    {
      name: 'prima-api-v2',
      script: 'app.js',
      cwd: '/var/www/prima-v2/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3003
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3003
      }
    },
    {
      name: 'prima-api-staging-v2',
      script: 'app.js',
      cwd: '/var/www/prima-staging-v2/api',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'staging',
        PORT: 3004
      },
      env_staging: {
        NODE_ENV: 'staging',
        PORT: 3004
      }
    }
  ]
}; 