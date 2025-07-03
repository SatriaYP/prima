<template>
  <div class="region-selection-step">
    <h3>Wilayah Pendaftaran</h3>
    
    <div class="form-row">
      <div class="form-group">
        <label>Provinsi</label>
        <select :value="form.provinsiId" @change="updateProvinsi($event)" required>
          <option value="">Pilih Provinsi</option>
          <option v-for="p in provinsiList" :value="p.id" :key="p.id">{{ p.name }}</option>
        </select>
      </div>
      <div class="form-group">
        <label>Kabupaten/Kota</label>
        <select :value="form.kabupatenId" @change="updateKabupaten($event)" :disabled="!kabupatenList.length" required>
          <option value="">Pilih Kabupaten/Kota</option>
          <option v-for="k in kabupatenList" :value="k.id" :key="k.id">{{ k.name }}</option>
        </select>
      </div>
    </div>
    
    <div class="form-row">
      <div class="form-group">
        <label>Kecamatan</label>
        <select :value="form.kecamatanId" @change="updateKecamatan($event)" :disabled="!kecamatanList.length" required>
          <option value="">Pilih Kecamatan</option>
          <option v-for="k in kecamatanList" :value="k.id" :key="k.id">{{ k.name }}</option>
        </select>
      </div>
      <div class="form-group">
        <label>Kelurahan/Desa</label>
        <select :value="form.kelurahanId" @change="updateKelurahan($event)" :disabled="!kelurahanList.length" required>
          <option value="">Pilih Kelurahan/Desa</option>
          <option v-for="k in kelurahanList" :value="k.id" :key="k.id">{{ k.name }}</option>
        </select>
      </div>
    </div>
    
    <div class="form-row">
      <div class="form-group">
        <label>No. KTA</label>
        <input :value="form.noKta" readonly />
        <div class="field-info">Nomor KTA akan digenerate otomatis berdasarkan wilayah</div>
      </div>
      <div class="form-group">
        <label>Penerbit KTA</label>
        <input :value="form.penerbitKta" readonly />
      </div>
    </div>
    
    <!-- Navigation -->
    <div class="step-navigation">
      <button type="button" class="btn" @click="prevStep">Kembali</button>
      <button type="button" class="btn btn-green" @click="nextStep" :disabled="!isFormValid">Lanjut ke Cetak KTA</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegionSelectionStep',
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
    },
    kecamatanList: {
      type: Array,
      required: true
    },
    kelurahanList: {
      type: Array,
      required: true
    }
  },
  computed: {
    isFormValid() {
      return this.form.provinsiId && 
             this.form.kabupatenId && 
             this.form.kecamatanId && 
             this.form.kelurahanId;
    }
  },
  methods: {
    prevStep() {
      this.$emit('prev-step');
    },
    nextStep() {
      if (this.isFormValid) {
        this.$emit('next-step');
      }
    },
    updateProvinsi(event) {
      const provinsiId = event.target.value;
      this.$emit('update:form', {
        ...this.form,
        provinsiId,
        kabupatenId: '',
        kecamatanId: '',
        kelurahanId: ''
      });
      this.$emit('fetch-kabupaten');
    },
    updateKabupaten(event) {
      const kabupatenId = event.target.value;
      this.$emit('update:form', {
        ...this.form,
        kabupatenId,
        kecamatanId: '',
        kelurahanId: ''
      });
      this.$emit('fetch-kecamatan');
    },
    updateKecamatan(event) {
      const kecamatanId = event.target.value;
      this.$emit('update:form', {
        ...this.form,
        kecamatanId,
        kelurahanId: ''
      });
      this.$emit('fetch-kelurahan');
    },
    updateKelurahan(event) {
      const kelurahanId = event.target.value;
      this.$emit('update:form', {
        ...this.form,
        kelurahanId
      });
    }
  }
};
</script>

<style scoped>
.region-selection-step {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

h3 {
  margin-bottom: 20px;
  color: var(--primary);
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

.field-info {
  font-size: 0.8em;
  color: #666;
  margin-top: 4px;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: space-between;
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

.btn-green {
  background: #27ae60;
  color: white;
}

.btn-green:hover {
  background: #229954;
}

.btn-green:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 700px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
}
</style>
