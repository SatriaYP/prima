# Dokumentasi API OCR KTP

API OCR KTP adalah layanan berbasis FastAPI untuk memproses gambar KTP (Kartu Tanda Penduduk) Indonesia. API ini mengekstrak data terstruktur dari gambar KTP menggunakan PaddleOCR dan teknik pemrosesan gambar.

## Base URL

```
https://ocr.partaiprima.id
```

## Autentikasi

Semua permintaan API harus menyertakan API key dalam header:

```
X-API-Key: your_api_key_here
```

## Endpoints

### 1. Informasi Layanan

Mendapatkan informasi dasar tentang layanan API.

- **URL**: `/`
- **Method**: GET
- **Headers**: `X-API-Key: your_api_key_here`
- **Response Format**: JSON

### 2. Health Check

Memeriksa status kesehatan layanan API.

- **URL**: `/health`
- **Method**: GET
- **Headers**: `X-API-Key: your_api_key_here`
- **Response Format**: JSON

### 3. Proses KTP dari File Upload

Memproses gambar KTP yang diunggah sebagai file.

- **URL**: `/process/file`
- **Method**: POST
- **Headers**: `X-API-Key: your_api_key_here`
- **Request Body**: Form Data dengan field `file` berisi gambar KTP
- **Response Format**: JSON
- **Response Example**:

```json
{
  "success": true,
  "processing_time_ms": 1234.56,
  "data": {
    "nik": "1234567890123456",
    "nama": "NAMA LENGKAP",
    "tempat_lahir": "JAKARTA",
    "tanggal_lahir": "01-01-1990",
    "jenis_kelamin": "LAKI-LAKI",
    "alamat": "JL. CONTOH NO. 123",
    "rt_rw": "001/002",
    "kelurahan_desa": "KELURAHAN",
    "kecamatan": "KECAMATAN",
    "agama": "ISLAM",
    "status_perkawinan": "BELUM KAWIN",
    "pekerjaan": "PELAJAR/MAHASISWA",
    "kewarganegaraan": "WNI",
    "berlaku_hingga": "SEUMUR HIDUP"
  },
  "enhanced_image": "base64_encoded_image_data",
  "file_paths": {
    "processed_image": "/files/20250630_123456_uuid/cropped.jpg",
    "json_data": "/files/20250630_123456_uuid/output.json",
    "local_image_path": "/home/user/apps/ktp-image-processor/api_output/20250630_123456_uuid/cropped.jpg",
    "local_json_path": "/home/user/apps/ktp-image-processor/api_output/20250630_123456_uuid/output.json"
  }
}
```

### 4. Proses KTP dari Base64

Memproses gambar KTP yang dikirim dalam format Base64.

- **URL**: `/process/base64`
- **Method**: POST
- **Headers**: 
  - `X-API-Key: your_api_key_here`
  - `Content-Type: application/json`
- **Request Body**: JSON dengan field `image_base64` berisi gambar KTP dalam format Base64
- **Response Format**: JSON
- **Response Example**: Sama seperti endpoint `/process/file`

## Penggunaan dalam Aplikasi

### Contoh Penggunaan dengan Axios (Vue.js) - Upload File

```javascript
import axios from 'axios';

async function processKtpImage(file) {
  try {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await axios.post('https://ocr.partaiprima.id/process/file', formData, {
      headers: {
        'X-API-Key': 'your_api_key_here',
        'Content-Type': 'multipart/form-data'
      }
    });
    
    return response.data;
  } catch (error) {
    console.error('Error processing KTP image:', error);
    throw error;
  }
}
```

### Contoh Penggunaan dengan Axios (Vue.js) - Base64

```javascript
import axios from 'axios';

async function processKtpBase64(base64Image) {
  try {
    const response = await axios.post('https://ocr.partaiprima.id/process/base64', {
      image_base64: base64Image
    }, {
      headers: {
        'X-API-Key': 'your_api_key_here',
        'Content-Type': 'application/json'
      }
    });
    
    return response.data;
  } catch (error) {
    console.error('Error processing KTP image:', error);
    throw error;
  }
}

// Contoh konversi file ke Base64
function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const base64String = reader.result.split(',')[1];
      resolve(base64String);
    };
    reader.onerror = error => reject(error);
  });
}

// Penggunaan
async function handleFileUpload(file) {
  try {
    const base64Image = await fileToBase64(file);
    const result = await processKtpBase64(base64Image);
    console.log('OCR Result:', result);
    return result;
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### Implementasi dalam Form Pendaftaran Anggota

```vue
<template>
  <div class="ktp-upload-section">
    <h3>Upload KTP</h3>
    <input type="file" @change="handleFileChange" accept="image/*" />
    
    <div v-if="isProcessing" class="processing-indicator">
      Memproses KTP... Mohon tunggu.
    </div>
    
    <div v-if="ktpPreview" class="ktp-preview">
      <img :src="ktpPreview" alt="Preview KTP" />
      <button @click="processKtp" :disabled="isProcessing">
        Proses & Isi Otomatis
      </button>
    </div>
    
    <div v-if="ocrResult" class="ocr-result">
      <h4>Hasil Ekstraksi Data KTP:</h4>
      <pre>{{ JSON.stringify(ocrResult.data, null, 2) }}</pre>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      selectedFile: null,
      ktpPreview: null,
      isProcessing: false,
      ocrResult: null,
      ocrError: null
    };
  },
  methods: {
    handleFileChange(event) {
      this.selectedFile = event.target.files[0];
      this.ktpPreview = URL.createObjectURL(this.selectedFile);
      this.ocrResult = null;
      this.ocrError = null;
    },
    async processKtp() {
      if (!this.selectedFile) return;
      
      this.isProcessing = true;
      try {
        const formData = new FormData();
        formData.append('file', this.selectedFile);
        
        const response = await axios.post('https://ocr.partaiprima.id/process/file', formData, {
          headers: {
            'X-API-Key': 'your_api_key_here',
            'Content-Type': 'multipart/form-data'
          }
        });
        
        this.ocrResult = response.data;
        
        // Update form fields with OCR data
        if (this.ocrResult.success && this.ocrResult.data) {
          this.$emit('ocr-completed', {
            nik: this.ocrResult.data.nik,
            nama: this.ocrResult.data.nama,
            tempatLahir: this.ocrResult.data.tempat_lahir,
            tanggalLahir: this.formatDate(this.ocrResult.data.tanggal_lahir),
            jenisKelamin: this.ocrResult.data.jenis_kelamin,
            alamat: this.ocrResult.data.alamat,
            agama: this.ocrResult.data.agama,
            statusPerkawinan: this.ocrResult.data.status_perkawinan,
            pekerjaan: this.ocrResult.data.pekerjaan,
            ktpProcessedUrl: `data:image/jpeg;base64,${this.ocrResult.enhanced_image}`
          });
        }
      } catch (error) {
        console.error('Error processing KTP:', error);
        this.ocrError = 'Gagal memproses KTP. Silakan coba lagi.';
      } finally {
        this.isProcessing = false;
      }
    },
    formatDate(dateStr) {
      // Convert from DD-MM-YYYY to YYYY-MM-DD for HTML date input
      if (!dateStr) return '';
      const parts = dateStr.split('-');
      if (parts.length !== 3) return '';
      return `${parts[2]}-${parts[1]}-${parts[0]}`;
    }
  }
};
</script>
```

## Catatan Penting

- API ini dioptimalkan untuk KTP Indonesia dan menggunakan PaddleOCR dengan model bahasa Latin untuk akurasi pengenalan teks yang lebih baik.
- Data yang diekstrak distrukturkan sesuai dengan field-field pada KTP Indonesia seperti NIK, nama, alamat, dll.
- Pastikan gambar KTP yang diunggah memiliki kualitas yang baik untuk hasil OCR yang optimal.
- API akan melakukan preprocessing gambar untuk meningkatkan kualitas dan akurasi OCR.
- Selalu tangani error dengan baik saat mengakses API ini, terutama jika koneksi internet tidak stabil.
- Simpan API key dengan aman dan jangan sertakan dalam kode frontend yang dapat diakses publik.
