<template>
  <div class="member-form-container">
    <h1>{{ isEdit ? 'Edit Anggota' : 'Tambah Anggota' }}</h1>
    <form @submit.prevent="handleSubmit">
      <div class="form-group ktp-upload-block">
        <label>Upload Foto KTP</label>
        <input type="file" @change="handleFileUpload" accept="image/*" />
        <div v-if="form.fotoKtpUrl || form.fotoKtpProcessedUrl" class="ktp-upload-preview">
          <img v-if="form.fotoKtpProcessedUrl" :src="form.fotoKtpProcessedUrl" alt="KTP hasil preprocessing" class="ktp-preview processed" />
          <img v-else :src="form.fotoKtpUrl" alt="Foto KTP" class="ktp-preview" />
          <button type="button" class="btn btn-grey" @click="resetKtpUpload">Ulangi Upload</button>
        </div>
        <button v-if="form.fotoKtp && !ocrLoading" type="button" class="btn btn-blue" @click="prosesKtpOcr">Proses & Isi Otomatis</button>
        <div v-if="ocrLoading" class="ocr-loading">Memproses KTP... Mohon tunggu.</div>
        <div v-if="ocrError" class="ocr-error">{{ ocrError }}</div>
        <div v-if="ocrResult" class="ocr-result-debug">
          <details>
            <summary>Hasil Ekstraksi OCR (debug)</summary>
            <pre>{{ ocrResult }}</pre>
          </details>
        </div>
        <div class="ktp-upload-desc">Upload foto KTP yang jelas untuk mengisi data otomatis. Anda dapat mengedit data hasil ekstraksi jika perlu.</div>
      </div>
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
          <input v-model="form.tempatLahir" required />
        </div>
        <div class="form-group">
          <label>Tanggal Lahir</label>
          <input v-model="form.tanggalLahir" type="date" required />
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
      <div class="form-group">
        <label>Alamat</label>
        <input v-model="form.alamat" />
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Provinsi</label>
          <select v-model="form.provinsiId" @change="fetchKabupaten" required>
            <option value="">Pilih Provinsi</option>
            <option v-for="p in provinsiList" :value="p.id" :key="p.id">{{ p.name }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Kabupaten/Kota</label>
          <select v-model="form.kabupatenId" @change="fetchKecamatan" :disabled="!kabupatenList.length" required>
            <option value="">Pilih Kabupaten/Kota</option>
            <option v-for="k in kabupatenList" :value="k.id" :key="k.id">{{ k.name }}</option>
          </select>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Kecamatan</label>
          <select v-model="form.kecamatanId" @change="fetchKelurahan" :disabled="!kecamatanList.length" required>
            <option value="">Pilih Kecamatan</option>
            <option v-for="k in kecamatanList" :value="k.id" :key="k.id">{{ k.name }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Kelurahan/Desa</label>
          <select v-model="form.kelurahanId" :disabled="!kelurahanList.length" required>
            <option value="">Pilih Kelurahan/Desa</option>
            <option v-for="k in kelurahanList" :value="k.id" :key="k.id">{{ k.name }}</option>
          </select>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>No. KTA</label>
          <input v-model="form.noKta" readonly />
        </div>
        <div class="form-group">
          <label>Penerbit KTA</label>
          <input v-model="form.penerbitKta" readonly />
        </div>
      </div>
      <div class="form-group">
        <label>Upload Foto KTP</label>
        <input type="file" @change="handleFileUpload" accept="image/*" />
        <div v-if="form.fotoKtpUrl">
          <img :src="form.fotoKtpUrl" alt="Foto KTP" class="ktp-preview" />
        </div>
      </div>
      <div class="form-group form-checkbox">
        <input type="checkbox" v-model="form.isConfirmed" id="isConfirmed" required />
        <label for="isConfirmed">Saya menyatakan data di atas benar</label>
      </div>
      <div class="form-actions">
        <button type="submit" class="btn btn-green">{{ isEdit ? 'Simpan Perubahan' : 'Tambah Anggota' }}</button>
        <button type="button" class="btn" @click="$router.push('/members')">Batal</button>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
    </form>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'MemberFormView',
  data() {
    return {
      isEdit: !!this.$route.params.id,
      form: {
        nik: '',
        nama: '',
        tempatLahir: '',
        tanggalLahir: '',
        jenisKelamin: '',
        statusPerkawinan: '',
        statusPekerjaan: '',
        minatBakat: '',
        alamat: '',
        provinsiId: '',
        kabupatenId: '',
        kecamatanId: '',
        kelurahanId: '',
        noKta: '',
        penerbitKta: 'DPP',
        fotoKtp: null,
        fotoKtpUrl: '',
        fotoKtpProcessedUrl: '',
        isConfirmed: false
      },
      provinsiList: [],
      kabupatenList: [],
      kecamatanList: [],
      kelurahanList: [],
      ocrLoading: false,
      ocrError: '',
      ocrResult: null,
      error: ''
    };
  },
  watch: {
    'form.provinsiId'(val) { if (val) this.fetchKabupaten(); },
    'form.kabupatenId'(val) { if (val) this.fetchKecamatan(); },
    'form.kecamatanId'(val) { if (val) this.fetchKelurahan(); },
    'form.kelurahanId'() { this.generateKta(); }
  },
  mounted() {
    if (this.$route.params.id) {
      this.isEdit = true;
      this.fetchMember();
    }
    this.fetchProvinsi();
  },
  methods: {
    async fetchMember() {
      try {
        const res = await api.get(`/members/${this.$route.params.id}`);
        this.form = { ...this.form, ...res.data };
      } catch (err) {
        this.error = 'Gagal memuat data anggota';
      }
    },
    async fetchProvinsi() {
      try {
        const res = await api.get('/regions/provinces');
        this.provinsiList = res.data;
      } catch (e) { /* no-op */ }
    },
    async fetchKabupaten() {
      this.form.kabupatenId = '';
      this.form.kecamatanId = '';
      this.form.kelurahanId = '';
      this.kabupatenList = [];
      this.kecamatanList = [];
      this.kelurahanList = [];
      if (!this.form.provinsiId) return;
      try {
        const res = await api.get(`/regions/regencies?provinceId=${this.form.provinsiId}`);
        this.kabupatenList = res.data;
      } catch (e) { /* no-op */ }
    },
    async fetchKecamatan() {
      this.form.kecamatanId = '';
      this.form.kelurahanId = '';
      this.kecamatanList = [];
      this.kelurahanList = [];
      if (!this.form.kabupatenId) return;
      try {
        const res = await api.get(`/regions/districts?regencyId=${this.form.kabupatenId}`);
        this.kecamatanList = res.data;
      } catch (e) { /* no-op */ }
    },
    async fetchKelurahan() {
      this.form.kelurahanId = '';
      this.kelurahanList = [];
      if (!this.form.kecamatanId) return;
      try {
        const res = await api.get(`/regions/villages?districtId=${this.form.kecamatanId}`);
        this.kelurahanList = res.data;
      } catch (e) { /* no-op */ }
    },
    generateKta() {
      // Dummy KTA: <prov><kab><kec>0001
      if (!this.form.provinsiId || !this.form.kabupatenId || !this.form.kecamatanId || !this.form.kelurahanId) {
        this.form.noKta = '';
        return;
      }
      const prov = this.form.provinsiId.slice(0,2);
      const kab = this.form.kabupatenId.slice(2,4);
      const kec = this.form.kecamatanId.slice(4,6);
      this.form.noKta = `${prov}${kab}${kec}0001`;
    },
    handleFileUpload(e) {
      const file = e.target.files[0];
      if (file) {
        this.form.fotoKtp = file;
        this.form.fotoKtpUrl = URL.createObjectURL(file);
        this.ocrResult = null;
        this.ocrError = '';
      }
    },
    resetKtpUpload() {
      this.form.fotoKtp = null;
      this.form.fotoKtpUrl = '';
      this.ocrResult = null;
      this.ocrError = '';
      if (this.$refs && this.$refs.ktpInput) this.$refs.ktpInput.value = '';
    },
    async prosesKtpOcr() {
      if (!this.form.fotoKtp) return;
      this.ocrLoading = true;
      this.ocrError = '';
      this.ocrResult = null;
      try {
        const formData = new FormData();
        formData.append('ktp', this.form.fotoKtp);
        // Ganti URL berikut dengan endpoint OCR backend Anda
        const res = await api.post('/ktp-ocr', formData, { headers: { 'Content-Type': 'multipart/form-data' }});
        // Asumsi response: { data: {...}, processed_image_url: '...' }
        if (res.data) {
          // Tampilkan hasil OCR JSON
          this.ocrResult = JSON.stringify(res.data.data || res.data, null, 2);
          // Preview gambar hasil preprocessing
          if (res.data.processed_image_url) {
            this.form.fotoKtpProcessedUrl = res.data.processed_image_url;
          }
          // Autofill field dari hasil OCR
          const ocr = res.data.data || res.data;
          if (ocr.nik) this.form.nik = ocr.nik;
          if (ocr.nama) this.form.nama = ocr.nama;
          if (ocr.alamat) this.form.alamat = ocr.alamat;
          if (ocr.tempat_lahir) this.form.tempatLahir = ocr.tempat_lahir;
          if (ocr.tanggal_lahir) this.form.tanggalLahir = ocr.tanggal_lahir;
          if (ocr.jenis_kelamin) this.form.jenisKelamin = ocr.jenis_kelamin;
          if (ocr.status_perkawinan) this.form.statusPerkawinan = ocr.status_perkawinan;
          if (ocr.status_pekerjaan) this.form.statusPekerjaan = ocr.status_pekerjaan;
          // Tambahkan mapping lain sesuai kebutuhan
        }
      } catch (err) {
        this.ocrError = err.response?.data?.message || 'Gagal memproses KTP. Pastikan gambar jelas dan server OCR aktif.';
      } finally {
        this.ocrLoading = false;
      }
    },
    async handleSubmit() {
      this.error = '';
      try {
        const formData = new FormData();
        Object.entries(this.form).forEach(([k, v]) => {
          if (k === 'fotoKtpUrl') return;
          formData.append(k, v ?? '');
        });
        if (this.isEdit) {
          await api.put(`/members/${this.$route.params.id}`, formData, { headers: { 'Content-Type': 'multipart/form-data' }});
        } else {
          await api.post('/members', formData, { headers: { 'Content-Type': 'multipart/form-data' }});
        }
        this.$router.push('/members');
      } catch (err) {
        this.error = err.response?.data?.message || 'Gagal menyimpan data';
      }
    }
  }
};
</script>

<style scoped>
.member-form-container {
  max-width: 650px;
  margin: 36px auto;
  padding: 28px 26px 18px 26px;
  background: #fff;
  border-radius: 16px;
  box-shadow: var(--shadow);
}
h1 {
  color: var(--primary);
  font-size: 1.5em;
  font-weight: 700;
  margin-bottom: 22px;
}
form {
  display: flex;
  flex-direction: column;
  gap: 0;
}
.form-row {
  display: flex;
  gap: 18px;
}
.form-group {
  flex: 1 1 180px;
  margin-bottom: 14px;
  display: flex;
  flex-direction: column;
}
label {
  font-weight: 600;
  margin-bottom: 4px;
}
input, select {
  padding: 10px 12px;
  font-size: 1em;
  border-radius: 8px;
  border: 1.5px solid #d0d7e2;
  margin-bottom: 2px;
}
input[readonly] {
  background: #f5f6fa;
  color: #888;
}
.ktp-preview {
  margin-top: 6px;
  width: 140px;
  border-radius: 6px;
  border: 1.5px solid #d0d7e2;
}
.form-checkbox {
  flex-direction: row;
  align-items: center;
  margin-bottom: 14px;
}
.form-actions {
  margin-top: 12px;
}
.error {
  color: #E74C3C;
  margin-top: 12px;
}
@media (max-width: 700px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
}
</style>
