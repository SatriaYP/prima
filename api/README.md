# PRIMA API - Wilayah Indonesia

API untuk data wilayah Indonesia (Provinsi, Kabupaten/Kota, Kecamatan, dan Kelurahan/Desa) yang digunakan oleh aplikasi PRIMA.

## Struktur Project

```
prima-api/
├── data/                 # Data CSV untuk wilayah Indonesia
├── prisma/               # Konfigurasi dan migrasi database
├── src/
│   ├── controllers/      # Request handlers
│   ├── models/           # Data models
│   ├── routes/           # API routes
│   ├── services/         # Business logic
│   ├── utils/            # Utility functions
│   └── app.js            # Express app
├── .env                  # Environment variables
├── .env.example          # Example environment variables
├── package.json          # Dependencies
└── README.md             # Documentation
```

## Teknologi yang Digunakan

- Node.js & Express.js - Backend framework
- Prisma - ORM untuk database
- SQLite - Database (development)
- CSV Parser - Untuk mengimpor data dari CSV

## Setup & Instalasi

### Prasyarat

- Node.js (v14 atau lebih baru)
- npm atau yarn

### Langkah-langkah Instalasi

1. Clone repository
```bash
git clone <repository-url>
cd prima-api
```

2. Install dependencies
```bash
npm install
```

3. Setup environment variables
```bash
cp .env.example .env
```

4. Jalankan migrasi database
```bash
npm run migrate
```

5. Impor data wilayah
```bash
npm run import-data
```

6. Jalankan server
```bash
npm run dev
```

Server akan berjalan di http://localhost:3000

## API Endpoints

### Provinsi

- `GET /api/wilayah/provinsi` - Mendapatkan semua provinsi
- `GET /api/wilayah/provinsi/{id}` - Mendapatkan detail provinsi
- `GET /api/wilayah/provinsi/{id}/kabupaten` - Mendapatkan kabupaten dalam provinsi

### Kabupaten/Kota

- `GET /api/wilayah/kabupaten/{id}` - Mendapatkan detail kabupaten/kota
- `GET /api/wilayah/kabupaten/{id}/kecamatan` - Mendapatkan kecamatan dalam kabupaten/kota

### Kecamatan

- `GET /api/wilayah/kecamatan/{id}` - Mendapatkan detail kecamatan
- `GET /api/wilayah/kecamatan/{id}/kelurahan` - Mendapatkan kelurahan dalam kecamatan

### Kelurahan/Desa

- `GET /api/wilayah/kelurahan/{id}` - Mendapatkan detail kelurahan/desa

## Format Response

Semua endpoint mengembalikan response dalam format berikut:

```json
{
  "status": "success",
  "data": [
    {
      "id": "31",
      "name": "DKI JAKARTA",
      "code": "31"
    },
    ...
  ]
}
```

## Integrasi dengan Frontend

Untuk mengintegrasikan API ini dengan aplikasi PRIMA, update konfigurasi di `AppConfig.dart`:

```dart
static const String wilayahApiBaseUrl = 'http://localhost:3000/api/wilayah';
```

## Deployment

### Persiapan

1. Update `.env` dengan konfigurasi production
2. Build aplikasi
```bash
npm run build
```

### Deployment ke Server

1. Upload file ke server
2. Install dependencies
```bash
npm install --production
```

3. Jalankan migrasi database
```bash
npm run migrate
```

4. Jalankan server
```bash
npm start
```

## Pengembangan Lebih Lanjut

- Implementasi caching untuk meningkatkan performa
- Menambahkan fitur pencarian untuk data wilayah
- Migrasi ke database PostgreSQL untuk production
- Implementasi autentikasi dan otorisasi

## Lisensi

[MIT](LICENSE)

# PRIMAtrix API

## Overview
API untuk aplikasi PRIMAtrix - Sistem Manajemen Keanggotaan Partai Prima, termasuk manajemen data wilayah Indonesia (Provinsi, Kabupaten/Kota, Kecamatan, dan Kelurahan/Desa).

## Version
1.0.0

## Last Updated
2024-03-26

## Tech Stack
- Node.js & Express.js - Backend framework
- Prisma ORM - Database ORM
- PostgreSQL - Database (production)
- SQLite - Database (development)
- CSV Parser - Untuk mengimpor data wilayah

## CI/CD Pipeline
- GitHub Actions untuk automated testing dan deployment
- Workflow akan berjalan otomatis saat:
  - Push ke branch `main`
  - Pull request ke branch `main`
- Job yang dijalankan:
  - Test API (lint, unit test)
  - Build aplikasi
  - Deploy ke server production
