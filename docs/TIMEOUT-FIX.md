# Perbaikan Masalah Timeout OCR KTP

## Masalah yang Ditemukan

Aplikasi mengalami error timeout saat memproses KTP:

```
AxiosError {message: 'timeout of 10000ms exceeded', name: 'AxiosError', code: 'ECONNABORTED'}
```

## Penyebab Masalah

1. **Timeout terlalu pendek**: Default timeout 10 detik tidak cukup untuk proses OCR
2. **Proses OCR membutuhkan waktu lama**: 
   - Upload file ke backend
   - Backend mengirim ke API OCR eksternal
   - API OCR memproses gambar
   - Backend menyimpan hasil
   - Response kembali ke frontend

3. **Tidak ada feedback yang jelas**: User tidak tahu berapa lama proses akan berlangsung

## Solusi yang Diterapkan

### 1. Perbaikan Timeout Configuration

**File: `web/src/services/api.js`**

```javascript
// Sebelum
const api = axios.create({
  baseURL: 'http://localhost:4000/api',
  timeout: 10000, // 10 detik
});

// Sesudah
const api = axios.create({
  baseURL: 'http://localhost:4000/api',
  timeout: 60000, // 60 detik untuk proses OCR yang membutuhkan waktu lama
});
```

### 2. Timeout Khusus untuk OCR

**File: `web/src/components/member/KtpUploadStep.vue`**

```javascript
const res = await api.post('/ktp-ocr', formData, { 
  headers: { 'Content-Type': 'multipart/form-data' },
  timeout: 120000 // 2 menit timeout khusus untuk OCR
});
```

### 3. Error Handling yang Lebih Baik

```javascript
catch (err) {
  console.error('Error OCR:', err);
  
  // Handle different types of errors
  if (err.code === 'ECONNABORTED') {
    this.ocrError = 'Proses OCR memakan waktu terlalu lama. Silakan coba lagi atau gunakan gambar yang lebih jelas.';
  } else if (err.response?.status === 413) {
    this.ocrError = 'File gambar terlalu besar. Gunakan gambar dengan ukuran maksimal 5MB.';
  } else if (err.response?.status === 400) {
    this.ocrError = 'Format file tidak didukung. Gunakan file gambar (JPG, PNG, dll).';
  } else if (err.response?.status >= 500) {
    this.ocrError = 'Server OCR sedang bermasalah. Silakan coba beberapa saat lagi.';
  } else {
    this.ocrError = err.response?.data?.message || 'Gagal memproses KTP. Pastikan gambar jelas dan server OCR aktif.';
  }
}
```

### 4. Loading Indicator yang Lebih Informatif

**Template:**
```vue
<div v-if="ocrLoading" class="ocr-loading">
  <div class="loading-spinner"></div>
  <div>Memproses KTP... Mohon tunggu (maksimal 2 menit)</div>
  <div class="loading-tip">Tips: Pastikan gambar KTP jelas dan tidak blur</div>
</div>
```

**CSS:**
```css
.ocr-loading {
  margin: 10px 0;
  color: #3498db;
  font-weight: 500;
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px auto;
}

.loading-tip {
  font-size: 0.85em;
  color: #6c757d;
  margin-top: 10px;
  font-style: italic;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```

### 5. Update Test Script

**File: `web/test-ocr.js`**

```javascript
const ocrResponse = await axios.post(`${API_BASE_URL}/ktp-ocr`, formData, {
  headers: {
    ...formData.getHeaders(),
    'Content-Type': 'multipart/form-data'
  },
  timeout: 120000 // 2 minutes timeout untuk OCR
});
```

## Timeline Proses OCR

```
1. User upload file (0-5 detik)
2. Frontend → Backend (1-3 detik)
3. Backend → API OCR eksternal (5-15 detik)
4. API OCR memproses gambar (10-30 detik)
5. API OCR → Backend (5-15 detik)
6. Backend menyimpan hasil (1-3 detik)
7. Backend → Frontend (1-3 detik)
8. Frontend menampilkan hasil (0-1 detik)
```

**Total waktu: 23-75 detik** (≈1-2 menit)

## Konfigurasi Timeout yang Direkomendasikan

| Komponen | Timeout | Alasan |
|----------|---------|--------|
| API Service Default | 60 detik | Untuk request umum |
| OCR Request | 120 detik | Untuk proses OCR yang lama |
| Test Script | 120 detik | Untuk testing yang konsisten |

## Tips untuk Mengoptimalkan Waktu Proses

### 1. Kualitas Gambar
- Gunakan gambar dengan resolusi yang baik (tidak blur)
- Pastikan pencahayaan cukup
- Hindari bayangan atau refleksi

### 2. Ukuran File
- Kompres gambar sebelum upload (max 5MB)
- Gunakan format JPG untuk ukuran yang lebih kecil
- Hindari gambar dengan resolusi terlalu tinggi

### 3. Koneksi Internet
- Pastikan koneksi internet stabil
- Hindari menggunakan VPN yang lambat
- Tutup aplikasi lain yang menggunakan bandwidth

## Monitoring dan Debugging

### 1. Console Logs
```javascript
console.log('Mengirim request OCR...');
console.log('Response OCR:', res.data);
console.log('Setting processed image URL:', res.data.processed_image_url);
```

### 2. Network Tab
- Buka Developer Tools (F12)
- Lihat tab Network
- Monitor request ke `/ktp-ocr`
- Periksa timing dan response

### 3. Backend Logs
```bash
# Lihat log backend
cd api-v2
npm start
# Monitor console untuk log OCR processing
```

## Troubleshooting Timeout

### Jika Masih Timeout:

1. **Periksa Koneksi Internet**
   - Test kecepatan internet
   - Coba di jaringan yang berbeda

2. **Periksa API OCR Eksternal**
   - Test akses ke `https://ocr.partaiprima.id`
   - Periksa status API key

3. **Periksa Backend**
   - Pastikan backend berjalan dengan baik
   - Periksa log untuk error

4. **Optimasi Gambar**
   - Gunakan gambar yang lebih kecil
   - Pastikan kualitas gambar baik

5. **Coba Lagi**
   - Kadang timeout terjadi karena beban server
   - Coba beberapa menit kemudian

## Kesimpulan

Masalah timeout telah diperbaiki dengan:

1. **Timeout yang lebih panjang** (60-120 detik)
2. **Error handling yang lebih baik**
3. **Loading indicator yang informatif**
4. **Tips untuk optimasi**

Sekarang proses OCR seharusnya berjalan dengan lancar tanpa timeout error. 