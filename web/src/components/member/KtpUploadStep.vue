<!-- eslint-disable vue/no-mutating-props -->
<template>
  <div class="ktp-upload-step">
    <div class="form-group ktp-upload-block">
      <label>Upload Foto KTP</label>
      <input type="file" @change="handleFileUpload" accept="image/*" ref="ktpInput" />
      
      <!-- Preview KTP -->
      <div class="ktp-upload-preview-container">
        <div class="ktp-images-comparison">
          <!-- Slot Original -->
          <div class="ktp-image-container">
            <h4>Foto KTP</h4>
            <template v-if="form.fotoKtpUrl">
              <img :src="form.fotoKtpUrl" alt="Foto KTP" class="ktp-preview" />
            </template>
            <template v-else>
              <div class="ktp-placeholder">Belum ada foto</div>
            </template>
          </div>
          <div class="ktp-arrow">&#x2192;</div>
          <div class="ktp-image-container">
            <h4>Foto Hasil Proses</h4>
            <template v-if="form.fotoKtpProcessedUrl">
              <img 
                :src="form.fotoKtpProcessedUrl" 
                :key="form.fotoKtpProcessedUrl + Date.now()" 
                alt="KTP hasil proses" 
                class="ktp-preview processed"
                @load="onImageLoad"
                @error="onImageError"
              />
              <button type="button" class="btn btn-blue btn-sm" @click="downloadProcessedImage">Download Foto</button>
            </template>
            <template v-else>
              <div class="ktp-placeholder">Menunggu proses...</div>
            </template>
          </div>
        </div>
        
        <button v-if="form.fotoKtp && !ocrLoading" type="button" class="btn btn-blue" @click="prosesKtpOcr">Proses & Isi Otomatis</button>
  
        
        <!-- OCR Result Debug -->
        <div v-if="ocrResult" class="ocr-result-debug">
          <details>
            <summary>Hasil Ekstraksi OCR (debug)</summary>
            <pre>{{ ocrResult }}</pre>
          </details>
        </div>
        
        
        <div v-if="ocrLoading" class="ocr-loading">
          <div class="loading-spinner"></div>
          <div>Memproses KTP... Mohon tunggu (maksimal 2 menit)</div>
          <div class="loading-tip">Tips: Pastikan gambar KTP jelas dan tidak blur</div>
        </div>
        <div v-if="ocrError" class="ocr-error">{{ ocrError }}</div>
      </div>
    
    
    </div>

<!-- Data Diri dari KTP -->
    <div class="form-row">
      <div class="form-group">
        <label>NIK</label>
        <input v-model="form.nik" maxlength="16" required />
      </div>
      <div class="form-group">
        <label>Nama</label>
        <input v-model="form.nama" required />
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Tempat Lahir</label>
        <input v-model="form.tempatLahir" list="birthplace-list" placeholder="Kota / Kabupaten" required />
        <datalist id="birthplace-list">
          <option v-for="r in regionOptions" :key="r.id" :value="r.name"></option>
        </datalist>
      </div>
      <div class="form-group">
        <label>Tanggal Lahir</label>
        <input v-model="dateFormatted" placeholder="DD/MM/YYYY" required />
      </div>
    </div>
    <!-- Row Tempat & Tanggal + Alamat -->
    <div class="form-group">
      <label>Alamat</label>
      <input v-model="form.alamat" />
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Jenis Kelamin</label>
        <select v-model="form.jenisKelamin" required>
          <option value="">Pilih</option>
          <option value="Laki-laki">Laki-laki</option>
          <option value="Perempuan">Perempuan</option>
        </select>
      </div>
      <div class="form-group">
        <label>Status Perkawinan</label>
        <select v-model="form.statusPerkawinan" required>
          <option value="">Pilih</option>
          <option value="Belum Kawin">Belum Kawin</option>
          <option value="Kawin">Kawin</option>
          <option value="Cerai">Cerai</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Status Pekerjaan</label>
        <input v-model="form.statusPekerjaan" />
      </div>
      <div class="form-group">
        <label>Minat/Bakat</label>
        <input v-model="form.minatBakat" />
      </div>
    </div>

    <!-- Navigation -->
    <div class="step-navigation">
      <button type="button" class="btn btn-green" @click="nextStep">Lanjut ke Wilayah Pendaftaran</button>
    </div>
  </div>
</template>

<script>
/* eslint-disable vue/no-mutating-props */
import api from '../../services/api';

export default {
  name: 'KtpUploadStep',
  props: {
    form: {
      type: Object,
      required: true
    },
    provinsiList: {
      type: Array,
      required: true
    },
    kabupatenList: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      ocrLoading: false,
      ocrError: '',
      ocrResult: null,
      regionOptions: []
    };
  },
  computed: {
    dateFormatted: {
      get() {
        if (!this.form.tanggalLahir) return '';
        const [year, month, day] = this.form.tanggalLahir.split('-');
        return `${day}/${month}/${year}`;
      },
      set(val) {
        const parts = val.split('/');
        if (parts.length === 3) {
          const [d, m, y] = parts;
          if (y && m && d) {
            this.$emit('update:form', { ...this.form, tanggalLahir: `${y}-${m.padStart(2,'0')}-${d.padStart(2,'0')}` });
          }
        }
      }
    }
  },
  watch: {
    'form.tempatLahir'(val) {
      if (val && val.length >= 3) {
        this.fetchRegionOptions(val);
      }
    }
  },
  methods: {
    toTitleCase(str) {
      if (!str) return '';
      return str.toLowerCase().split(' ').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
    },
    async fetchRegionOptions(query) {
      try {
        // Gunakan backend API untuk search region
        const res = await api.get(`/regions/search?query=${encodeURIComponent(query)}`);
        this.regionOptions = res.data;
      } catch (e) { 
        console.error('Error fetching region options:', e);
        this.regionOptions = []; 
      }
    },
    nextStep() {
      this.$emit('next-step');
    },
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
    },
    resetKtpUpload() {
      this.$emit('update:form', {
        ...this.form,
        fotoKtp: null,
        fotoKtpUrl: '',
        fotoKtpProcessedUrl: ''
      });
      this.ocrResult = null;
      this.ocrError = '';
      if (this.$refs && this.$refs.ktpInput) this.$refs.ktpInput.value = '';
    },
    
    downloadProcessedImage() {
      if (!this.form.fotoKtpProcessedUrl) return;
      
      // Membuat anchor element untuk download
      const a = document.createElement('a');
      a.href = this.form.fotoKtpProcessedUrl;
      a.download = 'ktp_processed_' + new Date().getTime() + '.jpg';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    },
    
    onImageLoad() {
      console.log('✅ Image loaded successfully:', this.form.fotoKtpProcessedUrl);
    },
    
    onImageError(event) {
      console.error('❌ Image failed to load:', this.form.fotoKtpProcessedUrl);
      console.error('Error event:', event);
      this.ocrError = 'Gagal memuat gambar hasil proses. Silakan coba lagi.';
    },
    
    async prosesKtpOcr() {
      if (!this.form.fotoKtp) return;
      this.ocrLoading = true;
      this.ocrError = '';
      this.ocrResult = null;
      
      try {
        const formData = new FormData();
        formData.append('image', this.form.fotoKtp);
        
        console.log('Mengirim request OCR...');
        const res = await api.post('/ktp-ocr', formData, { 
          headers: { 'Content-Type': 'multipart/form-data' },
          timeout: 120000 // 2 menit timeout khusus untuk OCR
        });
        
        console.log('Response OCR:', res.data);
        
        if (res.data.success && res.data.data) {
          // Tampilkan hasil OCR JSON untuk debug
          this.ocrResult = JSON.stringify(res.data, null, 2);
          
          // Update foto hasil proses
          let imageUrl = '';
          
          // Coba gunakan processed_image_url terlebih dahulu
          if (res.data.processed_image_url) {
            imageUrl = res.data.processed_image_url;
            console.log('Using processed_image_url:', imageUrl);
          }
          // Fallback ke file_paths jika processed_image_url tidak ada
          else if (res.data.file_paths && res.data.file_paths.processed_image) {
            // Gunakan base URL yang sama dengan API untuk konsistensi
            const baseUrl = window.location.protocol === 'https:' 
              ? `https://${window.location.hostname}`
              : `http://${window.location.hostname}`;
            imageUrl = `${baseUrl}/api${res.data.file_paths.processed_image}`;
            console.log('Using file_paths fallback:', imageUrl);
          }
          
          if (imageUrl) {
            console.log('✅ Image URL ready:', imageUrl);
          }
          
          // Autofill field dari hasil OCR
          const ocr = res.data.data;
          let updatedForm = { ...this.form };
          
          // TAMBAHKAN URL GAMBAR KE UPDATED FORM
          if (imageUrl) {
            updatedForm.fotoKtpProcessedUrl = imageUrl;
          }
          
          // NIK
          if (ocr.nik) {
            updatedForm.nik = ocr.nik;
            
            // Ekstrak kode provinsi dan kabupaten dari NIK
            if (ocr.nik.length === 16) {
              const provCode = ocr.nik.substring(0, 2);
              const kabCode = ocr.nik.substring(0, 4);
              
              // Auto-select provinsi berdasarkan kode
              const matchingProv = this.provinsiList.find(p => p.id.startsWith(provCode));
              if (matchingProv) {
                updatedForm.provinsiId = matchingProv.id;
                // Fetch kabupaten setelah provinsi dipilih
                this.$emit('fetch-kabupaten');
                
                // Auto-select kabupaten berdasarkan kode
                setTimeout(() => {
                  const matchingKab = this.kabupatenList.find(k => k.id === kabCode);
                  if (matchingKab) {
                    updatedForm.kabupatenId = matchingKab.id;
                    // Fetch kecamatan setelah kabupaten dipilih
                    this.$emit('fetch-kecamatan');
                  }
                }, 500); // Delay untuk memastikan kabupaten sudah di-fetch
              }
            }
          }
          
          // Nama
          if (!updatedForm.nama && ocr.nama) {
            updatedForm.nama = this.toTitleCase(ocr.nama);
          }
          
          // Alamat
          if (ocr.alamat) {
            updatedForm.alamat = this.toTitleCase(ocr.alamat);
          }
          
          // TTL (Tempat Tanggal Lahir)
          if (ocr.ttl) {
            // Format TTL biasanya: "BEKASI, 26-10-2003" atau "BEKASI.26-10-2003"
            const ttlParts = ocr.ttl.split(/[,.-]/);
            if (ttlParts.length >= 1) {
              // Ambil bagian pertama sebagai tempat lahir
              const tempatLahir = ttlParts[0].trim();
              if (tempatLahir && tempatLahir !== '-') {
                updatedForm.tempatLahir = tempatLahir;
              }
              
              // Coba ekstrak tanggal lahir
              if (ttlParts.length >= 4) {
                const day = ttlParts[1].trim().padStart(2, '0');
                const month = ttlParts[2].trim().padStart(2, '0');
                const year = ttlParts[3].trim();
                if (day && month && year && year.length === 4) {
                  updatedForm.tanggalLahir = `${year}-${month}-${day}`;
                }
              }
            }
          }
          
          // Jenis Kelamin
          if (ocr.kelamin) {
            const kelamin = ocr.kelamin.toUpperCase();
            if (kelamin.includes('LAKI')) {
              updatedForm.jenisKelamin = 'Laki-laki';
            } else if (kelamin.includes('PEREMPUAN') || kelamin.includes('WANITA')) {
              updatedForm.jenisKelamin = 'Perempuan';
            }
          }
          
          // Status Perkawinan
          if (ocr.kawin) {
            const kawin = ocr.kawin.toUpperCase();
            if (kawin.includes('BELUM')) {
              updatedForm.statusPerkawinan = 'Belum Kawin';
            } else if (kawin.includes('KAWIN')) {
              updatedForm.statusPerkawinan = 'Kawin';
            } else if (kawin.includes('CERAI')) {
              updatedForm.statusPerkawinan = 'Cerai';
            }
          }
          
          // Pekerjaan
          if (ocr.kerja) {
            updatedForm.statusPekerjaan = ocr.kerja;
          }
          
          // Fallback ke field lain jika ada
          if (!updatedForm.tempatLahir && ocr.tempat_lahir) {
            updatedForm.tempatLahir = this.toTitleCase(ocr.tempat_lahir);
          }
          if (!updatedForm.tanggalLahir && ocr.tanggal_lahir) {
            updatedForm.tanggalLahir = ocr.tanggal_lahir;
          }
          if (!updatedForm.jenisKelamin && ocr.jenis_kelamin) {
            updatedForm.jenisKelamin = ocr.jenis_kelamin;
          }
          if (!updatedForm.statusPerkawinan && ocr.status_perkawinan) {
            updatedForm.statusPerkawinan = ocr.status_perkawinan;
          }
          if (!updatedForm.statusPekerjaan && ocr.status_pekerjaan) {
            updatedForm.statusPekerjaan = ocr.status_pekerjaan;
          }
          
          // Emit update form dengan SEMUA perubahan dalam SATU event
          console.log('🎯 Final updatedForm with image URL:', updatedForm);
          this.$emit('update:form', updatedForm);
        } else {
          throw new Error('Response OCR tidak valid');
        }
      } catch (err) {
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
      } finally {
        this.ocrLoading = false;
      }
    }
  }
};
</script>

<style scoped>
.ktp-upload-step {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.ktp-upload-block {
  margin-bottom: 20px;
}

.ktp-upload-preview-container {
  margin-top: 12px;
  margin-bottom: 16px;
}

.ktp-images-comparison {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 12px;
}

.ktp-image-container {
  flex: 1;
  min-width: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.ktp-image-container h4 {
  margin-bottom: 8px;
  font-size: 0.9em;
  color: #555;
}

.ktp-preview {
  margin-top: 6px;
  width: 100%;
  max-width: 280px;
  border-radius: 6px;
  border: 1.5px solid #d0d7e2;
}

.ktp-preview.processed {
  border-color: var(--primary);
}

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

.ktp-arrow {
  display: flex;
  align-items: center;
  font-size: 1.5em;
  color: #666;
  margin: 0 10px;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 0.85em;
  margin-top: 8px;
}

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

.ocr-error {
  margin: 10px 0;
  color: #e74c3c;
  font-weight: 500;
}

.ocr-result-debug {
  margin: 10px 0;
  font-size: 0.85em;
}

.ocr-result-debug pre {
  background: #f5f5f5;
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
  max-height: 200px;
}

/* Form alignment */
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.form-row .form-group {
  flex: 1 1 320px;
  display: flex;
  flex-direction: column;
}

.form-row label {
  font-weight: 600;
  margin-bottom: 4px;
  color: #333;
}

.form-row input,
.form-row select {
  padding: 10px 12px;
  border: 1.5px solid #d0d7e2;
  border-radius: 8px;
  font-size: 1em;
}

.form-group {
  margin-bottom: 14px;
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: 600;
  margin-bottom: 4px;
  color: #333;
}

.form-group input,
.form-group select {
  padding: 10px 12px;
  border: 1.5px solid #d0d7e2;
  border-radius: 8px;
  font-size: 1em;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

/* Button styles */
.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-size: 1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-blue {
  background: #3498db;
  color: white;
}

.btn-blue:hover {
  background: #2980b9;
}

.btn-green {
  background: #27ae60;
  color: white;
}

.btn-green:hover {
  background: #229954;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 700px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .ktp-images-comparison {
    flex-direction: column;
  }
  
  .ktp-arrow {
    transform: rotate(90deg);
    margin: 10px 0;
  }
}
</style>
