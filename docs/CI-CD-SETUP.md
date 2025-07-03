# CI/CD Setup dengan GitHub Actions

Dokumentasi ini menjelaskan setup CI/CD untuk aplikasi Prima.id menggunakan GitHub Actions.

## Struktur Workflow

### Prima.id CI/CD (`combined-ci.yml`)
Workflow terpadu untuk backend API v2 dan frontend Vue.js yang di-deploy ke satu server VPS.

**Fitur:**
- Testing terpadu untuk kedua aplikasi
- Prisma database generation
- Security audit
- Build process untuk Vue.js
- Deployment ke VPS 212.85.26.97
- Staging deployment (branch `develop`)
- Production deployment (branch `main`)

## Setup yang Diperlukan

### 1. Environment Variables
Tambahkan secrets berikut di GitHub repository settings:

**API v2:**
```
DATABASE_URL=your_database_connection_string
JWT_SECRET=your_jwt_secret
NODE_ENV=production
```

**Web:**
```
STAGING_API_URL=https://api-staging.prima.id
PRODUCTION_API_URL=https://api.prima.id
```

### 2. Environments
Buat environments di GitHub repository:
- `staging` - untuk testing deployment
- `production` - untuk production deployment

### 3. Branch Protection Rules
Aktifkan branch protection untuk:
- `main` - require status checks to pass
- `develop` - require status checks to pass

## Deployment Configuration

## Deployment Configuration

### VPS Deployment (212.85.26.97)
Kedua aplikasi di-deploy ke satu server VPS yang sama.

**Struktur Direktori di Server:**
```
/var/www/prima-staging/     # Staging environment
├── api/                    # API v2 backend
└── web/                    # Vue.js frontend

/var/www/prima/             # Production environment  
├── api/                    # API v2 backend
└── web/                    # Vue.js frontend
```

**Deployment Process:**
1. **Testing & Build:** Semua test dan build dilakukan di GitHub Actions
2. **File Transfer:** Menggunakan rsync untuk transfer file ke server
3. **Service Restart:** Menggunakan PM2 untuk API dan Nginx untuk web
4. **Environment Separation:** Staging dan production terpisah

**Required Secrets:**
```
SSH_PRIVATE_KEY=your_private_ssh_key
SSH_USER=your_server_username
```

## Testing Configuration

### API v2 Tests
Pastikan file test sudah ada di `api-v2/`:

```javascript
// api-v2/__tests__/app.test.js
const request = require('supertest');
const app = require('../src/app');

describe('API Tests', () => {
  test('GET /health should return 200', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
  });
});
```

### Web Tests
Pastikan testing framework sudah dikonfigurasi di `web/`:

```javascript
// web/tests/unit/example.spec.js
import { mount } from '@vue/test-utils'
import HelloWorld from '@/components/HelloWorld.vue'

describe('HelloWorld.vue', () => {
  test('renders message', () => {
    const wrapper = mount(HelloWorld)
    expect(wrapper.text()).toMatch('Welcome')
  })
})
```

## Monitoring dan Notifications

### Slack Notifications
Tambahkan notifikasi Slack:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: '#deployments'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Status Badges
Tambahkan status badges di README:

```markdown
![API v2 CI](https://github.com/username/prima.id/workflows/API%20v2%20CI/badge.svg)
![Web CI](https://github.com/username/prima.id/workflows/Web%20CI/badge.svg)
```

## Troubleshooting

### Common Issues

1. **Prisma Generate Fails**
   - Pastikan `schema.prisma` ada di `api-v2/prisma/`
   - Check database connection string

2. **Build Fails**
   - Verify all dependencies are installed
   - Check for syntax errors in code

3. **Deployment Fails**
   - Verify SSH keys and permissions
   - Check server connectivity
   - Validate environment variables

### Debug Workflows
Untuk debug workflow:
1. Go to Actions tab di GitHub
2. Click pada workflow yang gagal
3. Check logs untuk error details
4. Use `echo` commands untuk debugging

## Best Practices

1. **Cache Dependencies**
   - Gunakan cache untuk npm/yarn dependencies
   - Cache Prisma generated files

2. **Parallel Jobs**
   - Jalankan test dan security audit secara paralel
   - Optimize workflow execution time

3. **Environment Separation**
   - Gunakan environment variables untuk config
   - Separate staging dan production configs

4. **Rollback Strategy**
   - Implement rollback mechanism
   - Keep previous versions for quick recovery

5. **Security**
   - Regular security audits
   - Scan for vulnerabilities
   - Use secrets untuk sensitive data 