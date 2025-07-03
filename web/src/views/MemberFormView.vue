<template>
  <div class="member-form-container">
    <h1>{{ isEdit ? 'Edit Anggota' : 'Tambah Anggota' }}</h1>
    
    <!-- Step Indicator -->
    <div class="step-indicator">
      <div 
        v-for="(stepName, index) in ['Upload KTP & Data Diri', 'Wilayah Pendaftaran', 'Cetak KTA']"
        :key="index"
        :class="['step', { 'active': currentStep === index, 'completed': currentStep > index }]"
        @click="goToStep(index)"
      >
        <div class="step-number">{{ index + 1 }}</div>
        <div class="step-name">{{ stepName }}</div>
      </div>
    </div>
    
    <form @submit.prevent="handleSubmit">
      <!-- Step 0: Upload KTP & Data Diri -->
      <ktp-upload-step 
        v-if="currentStep === 0"
        :form="form"
        :provinsiList="provinsiList"
        :kabupatenList="kabupatenList"
        @update:form="updateForm"
        @next-step="nextStep"
        @fetch-kabupaten="fetchKabupaten"
        @fetch-kecamatan="fetchKecamatan"
      />
      
      <!-- Step 1: Wilayah Pendaftaran -->
      <region-selection-step 
        v-if="currentStep === 1"
        :form="form"
        :provinsiList="provinsiList"
        :kabupatenList="kabupatenList"
        :kecamatanList="kecamatanList"
        :kelurahanList="kelurahanList"
        @update:form="updateForm"
        @prev-step="prevStep"
        @next-step="nextStep"
        @fetch-kabupaten="fetchKabupaten"
        @fetch-kecamatan="fetchKecamatan"
        @fetch-kelurahan="fetchKelurahan"
      />
      
      <!-- Step 2: Cetak KTA -->
      <kta-generation-step 
        v-if="currentStep === 2"
        :form="form"
        :isEdit="isEdit"
        @update:form="updateForm"
        @prev-step="prevStep"
      />
      
      <div v-if="error" class="error">{{ error }}</div>
    </form>
  </div>
</template>

<script>
import api from '../services/api';
import KtpUploadStep from '../components/member/KtpUploadStep.vue';
import RegionSelectionStep from '../components/member/RegionSelectionStep.vue';
import KtaGenerationStep from '../components/member/KtaGenerationStep.vue';

export default {
  name: 'MemberFormView',
  components: {
    KtpUploadStep,
    RegionSelectionStep,
    KtaGenerationStep
  },
  data() {
    return {
      currentStep: 0,
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
    nextStep() {
      if (this.currentStep < 2) {
        this.currentStep++;
        window.scrollTo(0, 0);
      }
    },
    prevStep() {
      if (this.currentStep > 0) {
        this.currentStep--;
        window.scrollTo(0, 0);
      }
    },
    goToStep(step) {
      // Only allow going to steps that are completed or the next step
      if (step <= this.currentStep + 1) {
        this.currentStep = step;
        window.scrollTo(0, 0);
      }
    },
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
    updateForm(updated) {
      console.log('🔄 Parent updateForm called with:', updated);
      console.log('🔄 Current form before update:', this.form);
      this.form = { ...this.form, ...updated };
      console.log('🔄 Form after update:', this.form);
      console.log('🔄 fotoKtpProcessedUrl after update:', this.form.fotoKtpProcessedUrl);
    },
    async handleSubmit() {
      this.error = '';
      try {
        const formData = new FormData();
        Object.entries(this.form).forEach(([k, v]) => {
          if (k === 'fotoKtpUrl' || k === 'fotoKtpProcessedUrl') return;
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

.form-checkbox {
  flex-direction: row;
  align-items: center;
  margin-bottom: 14px;
}

.error {
  color: #E74C3C;
  margin-top: 12px;
}

/* Step Indicator Styles */
.step-indicator {
  display: flex;
  justify-content: space-between;
  margin-bottom: 30px;
  position: relative;
}

.step-indicator::before {
  content: '';
  position: absolute;
  top: 15px;
  left: 40px;
  right: 40px;
  height: 2px;
  background: #e0e0e0;
  z-index: 1;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 2;
  cursor: pointer;
}

.step-number {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #f0f0f0;
  border: 2px solid #ddd;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-bottom: 8px;
  transition: all 0.3s;
}

.step-name {
  font-size: 0.8em;
  text-align: center;
  color: #666;
  max-width: 100px;
}

.step.active .step-number {
  background: var(--primary);
  border-color: var(--primary);
  color: white;
}

.step.active .step-name {
  color: var(--primary);
  font-weight: 600;
}

.step.completed .step-number {
  background: #4CAF50;
  border-color: #4CAF50;
  color: white;
}

@media (max-width: 700px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .step-name {
    font-size: 0.7em;
    max-width: 70px;
  }
}
</style>
