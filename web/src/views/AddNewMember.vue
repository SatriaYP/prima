<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
// import axios from "axios";
// import api from "@/services/api.service";
// import KtpUploadStep from "@/components/member/KtpUploadStep.vue";
import RegionSelectionStep from "@/components/member/RegionSelectionStep.vue";
import KtaGenerationStep from "@/components/member/KtaGenerationStep.vue";
import StepIndicator from "@/components/common/StepIndicator.vue";
import AppKtpUpload from "@/components/layout/AppKtpUpload.vue";

import { useRegionStore } from "@/stores/region.store";
import { storeToRefs } from "pinia";
import api from "@/services/api.service";

const route = useRoute();
const router = useRouter();
const region = useRegionStore();
const { provinces, cities, districts, villages, error } = storeToRefs(region);
const steps = ["Upload KTP & Data Diri", "Wilayah Pendaftaran", "Cetak KTA"];
const currentStep = ref(0);
const isEdit = ref(!!route.params.id);
// const error = ref("");

// const form = reactive({
//   nik: "",
//   nama: "",
//   tempatLahir: "",
//   tanggalLahir: "",
//   jenisKelamin: "",
//   statusPerkawinan: "",
//   statusPekerjaan: "",
//   minatBakat: "",
//   alamat: "",
//   provinsiId: "",
//   kabupatenId: "",
//   kecamatanId: "",
//   kelurahanId: "",
//   noKta: "",
//   penerbitKta: "DPP",
//   fotoKtp: null,
//   fotoKtpUrl: "",
//   fotoKtpProcessedUrl: "",
//   isConfirmed: false,
// });
const form = reactive({
  nik: null,
  ktaNumber: null,
  name: null,
  gender: null,
  birthPlace: null,
  birthDate: null,
  address: null,
  phone: null,
  email: null,
  maritalStatus: null,
  occupation: null,
  skills: "",
  interests: "",
  provinceCode: null,
  cityCode: null,
  districtCode: null,
  villageCode: null,
  ktpUrl: null,
  ktpProcessedUrl: null,
  photoUrl: null,
  certificateUrl: null,
  registrationType: "admin",
  registeredById: null,
  isOfficial: false,
  isConfirmed: false,
});

// const provinsiList = ref([]);
// const kabupatenList = ref([]);
// const kecamatanList = ref([]);
// const kelurahanList = ref([]);

// watch(
//   () => form.provinsiId,
//   () => fetchKabupaten()
// );
// watch(
//   () => form.kabupatenId,
//   () => fetchKecamatan()
// );
// watch(
//   () => form.kecamatanId,
//   () => fetchKelurahan()
// );
// watch(
//   () => form.kelurahanId,
//   () => generateKta()
// );
// const stepperRef = ref(null);
// let stepperOffset = 0;

function goToStep(index) {
  if (index <= currentStep.value + 1) {
    currentStep.value = index;
    window.scrollTo(0, 0);
  }
}

function nextStep() {
  if (currentStep.value < steps.length - 1) {
    currentStep.value++;
    window.scrollTo(0, 0);
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--;
    window.scrollTo(0, 0);
  }
}

// async function fetchMember() {
//   try {
//     const { data } = await api.get(`/members/${route.params.id}`);
//     Object.assign(form, data);
//   } catch {
//     error.value = "Gagal memuat data anggota";
//   }
// }

// async function fetchProvinsi() {
//   try {
//     const res = await axios.get("https://wilayah.partaiprima.id/provinsi.json");
//     provinsiList.value = res.data;
//   } catch {
//     provinsiList.value = [];
//   }
// }

async function fetchKabupaten() {
  // if (!form.provinsiId) return;
  if (!form.provinceCode) return;
  // resetWilayah("kabupaten");
  // try {
  //   const res = await axios.get(
  //     `https://wilayah.partaiprima.id/regencies/${form.provinsiId}.json`
  //   );
  //   kabupatenList.value = res.data;
  // } catch {
  //   kabupatenList.value = [];
  // }
  region.fetchCities(form.provinceCode);
}

async function fetchKecamatan() {
  if (!form.cityCode) return;
  // if (!form.kabupatenId) return;
  // resetWilayah("kecamatan");
  // try {
  //   const res = await axios.get(
  //     `https://wilayah.partaiprima.id/districts/${form.kabupatenId}.json`
  //   );
  //   kecamatanList.value = res.data;
  // } catch {
  //   kecamatanList.value = [];
  // }
  region.fetchDistricts(form.cityCode);
}

async function fetchKelurahan() {
  if (!form.districtCode) return;
  // if (!form.kecamatanId) return;
  // resetWilayah("kelurahan");
  // try {
  //   const res = await axios.get(
  //     `https://wilayah.partaiprima.id/villages/${form.kecamatanId}.json`
  //   );
  //   kelurahanList.value = res.data;
  // } catch {
  //   kelurahanList.value = [];
  // }
  region.fetchVillages(form.districtCode);
}

const handleCancel = () => {
  Object.keys(form).forEach((key) => {
    if (form[key] === "registrationType") {
      form[key] = "admin";
    }
    form[key] = null;
  });
  router.back();
};

// function resetWilayah(level) {
//   if (level === "kabupaten") {
//     form.kabupatenId = "";
//     form.kecamatanId = "";
//     form.kelurahanId = "";
//     kabupatenList.value = [];
//     kecamatanList.value = [];
//     kelurahanList.value = [];
//   } else if (level === "kecamatan") {
//     form.kecamatanId = "";
//     form.kelurahanId = "";
//     kecamatanList.value = [];
//     kelurahanList.value = [];
//   } else if (level === "kelurahan") {
//     form.kelurahanId = "";
//     kelurahanList.value = [];
//   }
// }

const generateKTA = async () => {
  if (
    !form.provinceCode ||
    !form.cityCode ||
    !form.districtCode ||
    !form.villageCode
  ) {
    form.ktaNumber = "" || null;
    return;
  }

  const prov = form.provinceCode.slice(0, 2);
  const kab = form.cityCode.slice(3, 5);
  const kec = form.districtCode.slice(6, 8);
  const kel = form.villageCode.slice(9, 13);
  const prefix = `${prov}${kab}${kec}${kel}`;

  try {
    // Ambil nomor terakhir dari backend
    const res = await api.get(`/members/kta/last-num?prefix=${prefix}`);
    console.log(res.data.lastNumber);
    // const data = await res.json();

    let lastNumber = res.data?.lastNumber || null;
    console.log(lastNumber);

    if (!lastNumber) {
      // Kalau belum ada, mulai dari 0001
      form.ktaNumber = `${prefix}0001`;
    } else {
      // Ambil 4 digit terakhir lalu increment
      let lastSeq = parseInt(lastNumber.slice(-4), 10);
      let newSeq = (lastSeq + 1).toString().padStart(4, "0");
      form.ktaNumber = `${prefix}${newSeq}`;
    }
  } catch (err) {
    console.error("Gagal generate KTA:", err);
    form.ktaNumber = `${prefix}0001`; // fallback
  }
};

// function generateKta() {
//   if (
//     !form.provinsiId ||
//     !form.kabupatenId ||
//     !form.kecamatanId ||
//     !form.kelurahanId
//   ) {
//     form.noKta = "";
//     return;
//   }
//   const prov = form.provinsiId.slice(0, 2);
//   const kab = form.kabupatenId.slice(2, 4);
//   const kec = form.kecamatanId.slice(4, 6);
//   form.noKta = `${prov}${kab}${kec}0001`;
// }

function updateForm(updated) {
  Object.assign(form, updated);
}

// const stepper = document.getElementById("stepper");
// const stepperOffset = stepper.offsetTop;

// window.addEventListener("scroll", () => {
//   if (window.scrollY > stepperOffset) {
//     stepper.classList.add("step-scroll");
//     stepper.classList.remove("step-scroll"); // kalau mau margin/padding berubah
//   } else {
//     stepper.classList.remove("step-scroll");
//     // stepper.classList.add("py-2");
//   }
// });

onMounted(() => {
  region.fetchProvinces();
  console.log(region.provinces);
  // fetchProvinsi();
  // if (isEdit.value) fetchMember();

  // if (stepperRef.value) {
  //   stepperOffset = stepperRef.value.offsetTop;
  // }

  // const handleScroll = () => {
  //   if (window.scrollY > stepperOffset) {
  //     stepperRef.value.classList.add("step-scroll");
  //   } else {
  //     stepperRef.value.classList.remove("step-scroll");
  //   }
  // };

  // window.addEventListener("scroll", handleScroll);

  // onUnmounted(() => {
  //   window.removeEventListener("scroll", handleScroll);
  // });
});
</script>
<template>
  <div class="member-form">
    <div class="step-container">
      <!-- Action Buttons -->
      <div ref="stepperRef" class="step-actions">
        <button class="btn-cancel" @click="handleCancel">Cancel</button>
        <!-- <button class="btn-cancel" @click="handleCancel">Cancel</button> -->
        <!-- Step Indicator -->
        <div class="step-indicator">
          <StepIndicator
            :steps="steps || ['Upload KTP', 'Wilayah Pendaftaran', 'Cetak KTA']"
            :currentStep="currentStep"
            @goToStep="goToStep"
          />
        </div>
        <div class="btn-group">
          <!-- <button class="btn" :disabled="currentStep === 0" @click="prevStep">
            Back
          </button>
          <button
            class="btn primary"
            :disabled="currentStep === steps.length - 1"
            @click="nextStep"
          >
            Next
          </button> -->
        </div>
      </div>
    </div>

    <div class="form-card">
      <AppKtpUpload
        v-if="currentStep === 0"
        :form="form"
        :provinsiList="provinces"
        :kabupatenList="cities"
        @update:form="updateForm"
        @next-step="nextStep"
        @fetch-kabupaten="fetchKabupaten"
        @fetch-kecamatan="fetchKecamatan"
      />

      <RegionSelectionStep
        v-if="currentStep === 1"
        :form="form"
        :provinsiList="provinces"
        :kabupatenList="cities"
        :kecamatanList="districts"
        :kelurahanList="villages"
        @update:form="updateForm"
        @prev-step="prevStep"
        @next-step="nextStep"
        @fetch-kabupaten="fetchKabupaten"
        @fetch-kecamatan="fetchKecamatan"
        @fetch-kelurahan="fetchKelurahan"
        @generate-kta="generateKTA"
      />

      <KtaGenerationStep
        v-if="currentStep === 2"
        :form="form"
        :isEdit="isEdit"
        @update:form="updateForm"
        @prev-step="prevStep"
      />
    </div>

    <p v-if="error" class="error">{{ error }}</p>
  </div>
</template>
<style scoped>
.member-form {
  max-width: 100%;
  /* max-width: 800px; */
  margin: 0 auto;
  /* margin-top: -20px; */
  /* padding: 24px; */
}

.title {
  font-size: 1.6rem;
  font-weight: 700;
  color: #3c3c3c;
  margin-bottom: 24px;
  text-align: center;
}

.steps {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  cursor: pointer;
}

.circle {
  width: 34px;
  height: 34px;
  background: #f0f0f0;
  border-radius: 50%;
  line-height: 34px;
  text-align: center;
  font-weight: bold;
  border: 2px solid #ccc;
  transition: all 0.3s;
}

.label {
  margin-top: 6px;
  font-size: 0.75rem;
  text-align: center;
  color: #777;
}

.step.active .circle {
  background-color: #6c63ff;
  border-color: #6c63ff;
  color: white;
}

.step.completed .circle {
  background-color: #4caf50;
  border-color: #4caf50;
  color: white;
}

.step.active .label,
.step.completed .label {
  font-weight: 600;
  color: #333;
}

.form-card {
  background: #ffffff;
  padding: 12px;
  border-radius: 8px;
  /* box-shadow: 0px 6px 20px rgba(0, 0, 0, 0.06); */
}

.error {
  margin-top: 16px;
  color: #e74c3c;
  text-align: center;
}

.step-container {
  background-color: white;
  /* padding: 24px; */
  padding: 0 10px;
  border-radius: 8px;
  margin-bottom: 10px;
  /* box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); */
}

.step-scroll {
  position: sticky; /* atau fixed kalau mau selalu di layar */
  top: 0;
  z-index: 50; /* supaya di atas konten */
  background: white; /* supaya nggak transparan */
  margin: 0; /* hilangkan margin */
  padding: 10px 0; /* opsional, biar ada jarak dalam */
}

.step-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  /* margin-top: 24px; */
}

.btn-group {
  display: flex;
  gap: 8px;
}

.btn,
.btn-cancel {
  padding: 8px 16px;
  border-radius: 4px;
  /* border: 1px solid #ddd; */
  border: none;
  background-color: #f9f9f9;
  cursor: pointer;
  font-size: 14px;
}

.btn-cancel:hover {
  background-color: #e2e2e2;
}

.step-indicator {
  margin-left: -2rem;
}

.btn.primary {
  background-color: #007bff;
  color: white;
  border-color: #007bff;
}

.btn:disabled {
  background-color: #e0e0e0;
  color: #aaa;
  cursor: not-allowed;
}
</style>
