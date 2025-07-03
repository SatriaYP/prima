# Perbaikan Tampilan Foto Hasil Proses OCR KTP

## Masalah yang Ditemukan

Aplikasi tidak berhasil menampilkan foto hasil proses KTP, padahal:
1. **Backend berhasil menyimpan foto** ke `api-v2/public/processed/`
2. **URL yang dihasilkan backend** sudah benar: `http://localhost:4000/static/processed/ktp-{uuid}.jpg`
3. **File foto tersimpan** dengan ukuran yang benar (137KB)

## Penyebab Masalah

### 1. Penanganan Response OCR yang Tidak Konsisten
- Frontend mencari field `processed_image_url` dalam response
- Backend menghasilkan field `processed_image_url` dengan benar
- Namun ada beberapa kemungkinan field yang dicari frontend

### 2. Reset Foto Hasil Proses
- Saat upload file baru, foto hasil proses tidak direset
- Menyebabkan foto lama masih ditampilkan

### 3. Debug Information Tidak Lengkap
- Sulit untuk melacak masalah karena debug info terbatas

## Solusi yang Diterapkan

### 1. Perbaikan Penanganan Response OCR

**File: `web/src/components/member/KtpUploadStep.vue`**

```javascript
// Sebelum (kode lama)
let processedUrl = res.data.processed_image_url || res.data.processed_image || res.data.enhanced_image || '';
if (res.data.processed_image_url) {
  processedUrl = res.data.processed_image_url;
} else if (!processedUrl && (res.data.processed_image_base64 || res.data.processed_image_data)) {
  const base64 = res.data.processed_image_base64 || res.data.processed_image_data;
  processedUrl = base64.startsWith('data:') ? base64 : `data:image/jpeg;base64,${base64}`;
}

// Sesudah (kode baru)
if (res.data.success && res.data.data) {
  // Tampilkan hasil OCR JSON untuk debug
  this.ocrResult = JSON.stringify(res.data, null, 2);
  
  // Update foto hasil proses
  if (res.data.processed_image_url) {
    console.log('Setting processed image URL:', res.data.processed_image_url);
    this.$emit('update:form', {
      ...this.form,
      fotoKtpProcessedUrl: res.data.processed_image_url
    });
  }
}
```

### 2. Reset Foto Hasil Proses Saat Upload File Baru

```javascript
handleFileUpload(e) {
  const file = e.target.files[0];
  if (file) {
    this.$emit('update:form', {
      ...this.form,
      fotoKtp: file,
      fotoKtpUrl: URL.createObjectURL(file),
      fotoKtpProcessedUrl: '' // Reset processed image
    });
    this.ocrResult = null;
    this.ocrError = '';
  }
}
```

### 3. Penambahan Debug Information

```javascript
async prosesKtpOcr() {
  // ... kode lainnya ...
  
  console.log('Mengirim request OCR...');
  const res = await api.post('/ktp-ocr', formData, { 
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  
  console.log('Response OCR:', res.data);
  
  if (res.data.success && res.data.data) {
    // Tampilkan hasil OCR JSON untuk debug
    this.ocrResult = JSON.stringify(res.data, null, 2);
    
    // Update foto hasil proses
    if (res.data.processed_image_url) {
      console.log('Setting processed image URL:', res.data.processed_image_url);
      // ... kode lainnya ...
    }
  }
}
```

### 4. Perbaikan UI/UX

**Template:**
```vue
<template v-if="form.fotoKtpProcessedUrl">
  <img :src="form.fotoKtpProcessedUrl" :key="form.fotoKtpProcessedUrl" alt="KTP hasil proses" class="ktp-preview processed" />
  <button type="button" class="btn btn-blue btn-sm" @click="downloadProcessedImage">Download Foto</button>
</template>
<template v-else>
  <div class="ktp-placeholder">Menunggu proses...</div>
</template>
```

**CSS:**
```css
.ktp-placeholder {
  width: 100%;
  max-width: 280px;
  height: 180px;
  border: 2px dashed #d0d7e2;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #888;
  font-size: 0.9em;
}

.ktp-preview.processed {
  border-color: var(--primary);
}
```

## Verifikasi Solusi

### 1. Test Upload KTP
1. Upload file KTP baru
2. Klik "Proses & Isi Otomatis"
3. Periksa console browser untuk log debug
4. Verifikasi foto hasil proses muncul

### 2. Test Reset Foto
1. Upload file KTP pertama
2. Proses OCR
3. Upload file KTP kedua
4. Verifikasi foto hasil proses dari file pertama hilang

### 3. Test Download Foto
1. Proses OCR
2. Klik tombol "Download Foto"
3. Verifikasi file terdownload dengan benar

## Struktur Response OCR yang Diharapkan

```json
{
  "success": true,
  "processing_time_ms": 3458.3,
  "data": {
    "nik": "3216062008720009",
    "nama": "AGUSBARLIANTO",
    "ttl": "BEKASI, 26-10-2003",
    "kelamin": "LAKI-LAKI",
    "alamat": "CLUSTERGARDENFIESTA BLOK",
    "rt_rw": "001/018",
    "kel_desa": "LAM...",
    // ... field lainnya
  },
  "processed_image_url": "http://localhost:4000/static/processed/ktp-eef0fb1a-a645-4bf7-99ed-d4a540cd2c24.jpg"
}
```

## Troubleshooting

### Jika Foto Masih Tidak Muncul:

1. **Periksa Console Browser**
   - Buka Developer Tools (F12)
   - Lihat tab Console untuk error
   - Periksa tab Network untuk request OCR

2. **Periksa Response API**
   - Pastikan field `processed_image_url` ada dalam response
   - Verifikasi URL dapat diakses langsung di browser

3. **Periksa Backend Logs**
   - Lihat log server untuk error
   - Verifikasi file tersimpan di `api-v2/public/processed/`

4. **Test URL Langsung**
   - Buka URL foto hasil proses langsung di browser
   - Pastikan tidak ada error 404 atau 403

### Jika Ada Error CORS:

1. **Periksa Konfigurasi CORS di Backend**
   ```javascript
   app.use(cors());
   ```

2. **Periksa Static File Serving**
   ```javascript
   app.use('/static', express.static(path.join(process.cwd(), 'public')));
   ```

## Kesimpulan

Masalah tampilan foto hasil proses OCR telah diperbaiki dengan:

1. **Penanganan response yang lebih konsisten**
2. **Reset foto hasil proses saat upload file baru**
3. **Debug information yang lebih lengkap**
4. **UI/UX yang lebih baik**

Sekarang aplikasi seharusnya dapat menampilkan foto hasil proses KTP dengan benar. 