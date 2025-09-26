<script setup>
import { useAlert } from "@/composables/useAlert";
import api from "@/services/api.service";
import { computed, ref, watch } from "vue";

const props = defineProps({
  form: { type: Object, required: true },
  provinsiList: { type: Array, required: true },
  kabupatenList: { type: Array, required: true },
  kecamatanList: { type: Array, required: true },
  kelurahanList: { type: Array, required: true },
  isEdit: { type: Boolean, default: false },
});

const emit = defineEmits([
  "prev-step",
  "next-step",
  "update:form",
  "fetch-kabupaten",
  "fetch-kecamatan",
  "fetch-kelurahan",
  "generate-kta",
]);

const { showAlert } = useAlert();

const isFormValid = computed(() => {
  return (
    localProvinceCode.value &&
    localCityCode.value &&
    localDistrictCode.value &&
    localVillageCode.value
  );
});

const isCreated = ref(false);


const updateProvinsi = (event) => {
  const provinceCode = event.target.value;
  console.log(provinceCode, " heheheeh");
  emit("update:form", {
    ...props.form,
    provinceCode,
    cityCode: "",
    districtCode: "",
    villageCode: "",
  });
  emit("fetch-kabupaten");
};

const updateKabupaten = (event) => {
  const cityCode = event.target.value;
  console.log(cityCode, " heheheeh");
  emit("update:form", {
    ...props.form,
    // kabupatenId,
    // kecamatanId: "",
    // kelurahanId: "",
    cityCode,
    districtCode: "",
    villageCode: "",
  });
  emit("fetch-kecamatan");
};

const updateKecamatan = (event) => {
  const kecamatanId = event.target.value;
  emit("update:form", {
    ...props.form,
    districtCode: kecamatanId,
    villageCode: "",
  });
  emit("fetch-kelurahan");
};

const updateKelurahan = (event) => {
  const kelurahanId = event.target.value;
  emit("update:form", {
    ...props.form,
    villageCode: kelurahanId,
  });
};

const generateKta = () => {
  emit("generate-kta");
};

const updateConfirmation = (event) => {
  emit("update:form", {
    ...props.form,
    isConfirmed: event.target.checked,
  });
};
const localKtaNumber = computed({
  get() {
    return props.form?.ktaNumber || "";
  },
  // eslint-disable-next-line
  set(value) {
    // Tidak perlu setter karena readonly
    // Tapi biarkan agar tidak error jika suatu hari diubah jadi v-model
  },
});
const localProvinceCode = computed({
  get() {
    return props.form?.provinceCode || "";
  },
  set(value) {
    emit("update:form", {
      ...props.form,
      provinceCode: value,
      cityCode: "",
      districtCode: "",
      villageCode: "",
    });
  },
});

const localCityCode = computed({
  get() {
    return props.form?.cityCode || "";
  },
  set(value) {
    emit("update:form", {
      ...props.form,
      cityCode: value,
      districtCode: "",
      villageCode: "",
    });
  },
});

const localDistrictCode = computed({
  get() {
    return props.form?.districtCode || "";
  },
  set(value) {
    emit("update:form", {
      ...props.form,
      districtCode: value,
      villageCode: "",
    });
  },
});

const localVillageCode = computed({
  get() {
    return props.form?.villageCode || "";
  },
  set(value) {
    emit("update:form", {
      ...props.form,
      villageCode: value,
    });
  },
});
// eslint-disable-next-line
const handleCreateMember = async () => {
  try {
    const form = props.form;
    const payload = {
      nik: form.nik,
      ktaNumber: form.ktaNumber,
      name: form.name,
      gender: form.gender,
      birthPlace: form.birthPlace || null,
      birthDate: form.birthDate ? new Date(form.birthDate) : null,
      address: form.address || null,
      phone: form.phone || null,
      email: form.email || null,
      maritalStatus: form.maritalStatus || null,
      occupation: form.occupation || null,
      skills: form.skills || null,
      interests: form.interests || null,
      provinceCode: form.provinceCode || null,
      cityCode: form.cityCode || null,
      districtCode: form.districtCode || null,
      villageCode: form.villageCode || null,
      ktpUrl: form.ktpUrl || null,
      ktpProcessedUrl: form.ktpProcessedUrl || null,
      photoUrl: form.photoUrl || null,
      certificateUrl: form.certificateUrl || null,
      registrationType: form.registrationType || "admin",
      registeredById: form.registeredById || null,
      isOfficial: form.isOfficial ?? false,
    };

    let res;
    if (props.isEdit) {  // ✅ BENAR — akses via props
      res = await api.put(`/members/${form.id}`, payload);
    } else {
      res = await api.post("/members", payload);
    }

    if (res) {
      showAlert(props.isEdit ? "Anggota berhasil diupdate" : "Anggota berhasil ditambahkan", "success");
      isCreated.value = true;
    }
  } catch (error) {
    const message = error.response?.data?.message || "Terjadi kesalahan.";
    showAlert(message, "error");
  }
};

watch(
  [localProvinceCode, localCityCode, localDistrictCode],
  ([newProv, newCity, newDistrict]) => {
    if (newProv) emit("fetch-kabupaten");
    if (newCity) emit("fetch-kecamatan");
    if (newDistrict) emit("fetch-kelurahan");
  },
  { immediate: true }
);
// watch(
//   () => props.form.provinceCode,
//   (newVal) => {
//     if (newVal) emit("fetch-kabupaten");
//   },
//   { immediate: true }
// );

// watch(
//   () => props.form.cityCode,
//   (newVal) => {
//     if (newVal) emit("fetch-kecamatan");
//   },
//   { immediate: true }
// );

// watch(
//   () => props.form.districtCode,
//   (newVal) => {
//     if (newVal) emit("fetch-kelurahan");
//   },
//   { immediate: true }
// );
// export default {
//   name: 'RegionSelectionStep',
//   props: {
//     form: {
//       type: Object,
//       required: true
//     },
//     provinsiList: {
//       type: Array,
//       required: true
//     },
//     kabupatenList: {
//       type: Array,
//       required: true
//     },
//     kecamatanList: {
//       type: Array,
//       required: true
//     },
//     kelurahanList: {
//       type: Array,
//       required: true
//     }
//   },
//   computed: {
//     isFormValid() {
//       return this.form.provinsiId &&
//              this.form.kabupatenId &&
//              this.form.kecamatanId &&
//              this.form.kelurahanId;
//     }
//   },
//   methods: {
//     prevStep() {
//       this.$emit('prev-step');
//     },
//     nextStep() {
//       if (this.isFormValid) {
//         this.$emit('next-step');
//       }
//     },
//     updateProvinsi(event) {
//       const provinsiId = event.target.value;
//       this.$emit('update:form', {
//         ...this.form,
//         provinsiId,
//         kabupatenId: '',
//         kecamatanId: '',
//         kelurahanId: ''
//       });
//       this.$emit('fetch-kabupaten');
//     },
//     updateKabupaten(event) {
//       const kabupatenId = event.target.value;
//       this.$emit('update:form', {
//         ...this.form,
//         kabupatenId,
//         kecamatanId: '',
//         kelurahanId: ''
//       });
//       this.$emit('fetch-kecamatan');
//     },
//     updateKecamatan(event) {
//       const kecamatanId = event.target.value;
//       this.$emit('update:form', {
//         ...this.form,
//         kecamatanId,
//         kelurahanId: ''
//       });
//       this.$emit('fetch-kelurahan');
//     },
//     updateKelurahan(event) {
//       const kelurahanId = event.target.value;
//       this.$emit('update:form', {
//         ...this.form,
//         kelurahanId
//       });
//     }
//   }
// };
</script>
<template>
  <div class="region-selection-step">
    <h3>Wilayah Pendaftaran</h3>

    <div class="form-row">
      <div class="form-group">
        <label>Provinsi</label>
        <select v-model="localProvinceCode" @change="updateProvinsi($event)" required>
          <option value="">Pilih Provinsi</option>
          <option v-for="p in provinsiList" :value="p.code" :key="p.code">
            {{ p.name }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label>Kabupaten/Kota</label>
        <select v-model="localCityCode" @change="updateKabupaten($event)" :disabled="!kabupatenList.length" required>
          <option value="">Pilih Kabupaten/Kota</option>
          <option v-for="k in kabupatenList" :value="k.code" :key="k.code">
            {{ k.name }}
          </option>
        </select>
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Kecamatan</label>
        <select v-model="localDistrictCode" @change="updateKecamatan($event)" :disabled="!kecamatanList.length"
          required>
          <option value="">Pilih Kecamatan</option>
          <option v-for="k in kecamatanList" :value="k.code" :key="k.code">
            {{ k.name }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label>Kelurahan/Desa</label>
        <select v-model="localVillageCode" @change="updateKelurahan($event)" :disabled="!kelurahanList.length" required>
          <option value="">Pilih Kelurahan/Desa</option>
          <option v-for="k in kelurahanList" :value="k.code" :key="k.code">
            {{ k.name }}
          </option>
        </select>
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>No. KTA</label>
        <div class="input-with-button">
          <input :value="localKtaNumber" readonly />
          <button type="button" class="btn btn-blue" @click="generateKta" :disabled="!isFormValid">
            Generate
          </button>
        </div>
        <div class="field-info">
          Nomor KTA akan digenerate otomatis berdasarkan wilayah
        </div>
      </div>

      <!-- <div class="form-group">
        <label>Penerbit KTA</label>
        <input :value="form.penerbitKta" readonly />
      </div> -->
    </div>
    <div class="form-row">
      <div class="form-group">
        <div class="form-checkbox">
          <input type="checkbox" @change="updateConfirmation($event)" id="isConfirmed" required />
          <!-- <input
          type="checkbox"
          :checked="form.isConfirmed"
          @change="updateConfirmation($event)"
          id="isConfirmed"
          required
        /> -->
          <label for="isConfirmed">Saya menyatakan data di atas benar</label>
        </div>
      </div>
    </div>

    <!-- Navigation -->

  </div>
</template>
<style scoped>
.region-selection-step {
  display: flex;
  flex-direction: column;
  gap: 20px;
  max-width: 600px;
  margin: auto;
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

.form-checkbox {
  display: flex;
  align-items: baseline;
  gap: 10px;
  /* background-color: #2980b9; */
}

.form-checkbox>label {
  font-size: 14px;
  font-weight: 500;
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

.input-with-button {
  display: flex;
  gap: 8px;
}

.input-with-button input {
  flex: 1;
}

.btn-blue {
  background: #3498db;
  color: white;
  padding: 10px 16px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-blue:hover {
  background: #2980b9;
}

.btn-blue:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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
