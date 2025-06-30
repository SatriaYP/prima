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
              <img :src="form.fotoKtpProcessedUrl" alt="KTP hasil proses" class="ktp-preview processed" />
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
        
        
        <div v-if="ocrLoading" class="ocr-loading">Memproses KTP... Mohon tunggu.</div>
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
    <!-- Row Tempat & Tanggal + Alamat -->
    <div class="form-group">
      <label>Alamat</label>
      <input v-model="form.alamat" />
    </div>
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
        const res = await api.get(`/regions/search?query=${encodeURIComponent(query)}`);
        this.regionOptions = res.data;
      } catch (e) { this.regionOptions = []; }
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
          fotoKtpUrl: URL.createObjectURL(file)
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
    
    async prosesKtpOcr() {
      if (!this.form.fotoKtp) return;
      this.ocrLoading = true;
      this.ocrError = '';
      this.ocrResult = null;
      try {
        const formData = new FormData();
        // Menggunakan nama field 'image' agar sesuai dengan konfigurasi backend dan API OCR eksternal
        formData.append('image', this.form.fotoKtp);
        // Ganti URL berikut dengan endpoint OCR backend Anda
        const res = await api.post('/ktp-ocr', formData, { headers: { 'Content-Type': 'multipart/form-data' }});
        // Asumsi response: { data: {...}, processed_image_url: '...' }
        if (res.data) {
          // Tampilkan hasil OCR JSON
          this.ocrResult = JSON.stringify(res.data.data || res.data, null, 2);
          // Preview gambar hasil preprocessing
          // Cari berbagai kemungkinan nama field untuk processed image
          let processedUrl = res.data.processed_image_url || res.data.processed_image || '';
          if (res.data.processed_image_url) {
            processedUrl = res.data.processed_image_url;
          } else if (!processedUrl && (res.data.processed_image_base64 || res.data.processed_image_data)) {
            // Tambahkan prefix jika belum ada
            const base64 = res.data.processed_image_base64 || res.data.processed_image_data;
            processedUrl = base64.startsWith('data:') ? base64 : `data:image/jpeg;base64,${base64}`;
          }
          if (processedUrl) {
            this.$emit('update:form', {
              ...this.form,
              fotoKtpProcessedUrl: processedUrl
            });
          }
          
          // Autofill field dari hasil OCR
          const ocr = res.data.data || res.data;
          
          // Siapkan object form yang akan diperbarui
          let updatedForm = { ...this.form };
          
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
          if (!updatedForm.nama && ocr.nama) updatedForm.nama = this.toTitleCase(ocr.nama);
          if (!updatedForm.alamat && ocr.alamat) updatedForm.alamat = this.toTitleCase(ocr.alamat);
          
          // Alamat
          if (ocr.alamat) updatedForm.alamat = ocr.alamat;
          
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
          if (!updatedForm.tempatLahir && ocr.tempat_lahir) updatedForm.tempatLahir = this.toTitleCase(ocr.tempat_lahir);
          if (!updatedForm.tanggalLahir && ocr.tanggal_lahir) updatedForm.tanggalLahir = ocr.tanggal_lahir;
          if (!updatedForm.jenisKelamin && ocr.jenis_kelamin) updatedForm.jenisKelamin = ocr.jenis_kelamin;
          if (!updatedForm.statusPerkawinan && ocr.status_perkawinan) updatedForm.statusPerkawinan = ocr.status_perkawinan;
          if (!updatedForm.statusPekerjaan && ocr.status_pekerjaan) updatedForm.statusPekerjaan = ocr.status_pekerjaan;
          
          // Emit update form dengan semua perubahan
          this.$emit('update:form', updatedForm);
        }
      } catch (err) {
        this.ocrError = err.response?.data?.message || 'Gagal memproses KTP. Pastikan gambar jelas dan server OCR aktif.';
      } finally {
        this.ocrLoading = false;
      }
    }
  }
};
</script>

<style scoped>
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

.btn-sm {
  padding: 6px 12px;
  font-size: 0.85em;
  margin-top: 8px;
}

.ocr-loading {
  margin: 10px 0;
  color: #3498db;
}

.ocr-error {
  margin: 10px 0;
  color: #e74c3c;
}

.ocr-result-debug {
  margin: 10px 0;
  font-size: 0.85em;
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
  align-items: center;
  gap: 14px;
}

.form-row label {
  width: 140px;
  font-weight: 600;
  margin-bottom: 0;
  color: #333;
}

.form-row input,
.form-row select {
  flex: 1;
  padding: 10px 12px;
  border: 1.5px solid #d0d7e2;
  border-radius: 8px;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}
</style>
