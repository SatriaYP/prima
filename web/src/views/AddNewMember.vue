<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAlert } from "@/composables/useAlert";
const { showAlert } = useAlert();

import RegionSelectionStep from "@/components/member/RegionSelectionStep.vue";
import PersonalDataForm from "@/components/member/PersonalDataForm.vue";
import AppFileUpload from "@/components/layout/AppFileUpload.vue";
import KtaGenerationStep from "@/components/member/KtaGenerationStep.vue";
import StepIndicator from "@/components/common/StepIndicator.vue";
import MemberService from "@/services/member.service";
import { useRegionStore } from "@/stores/region.store";
import { storeToRefs } from "pinia";
import { useUserStore } from "@/stores/user.store";
import api from "@/services/api.service";

const route = useRoute();
const router = useRouter();
const region = useRegionStore();
const { provinces, cities, districts, villages, error } = storeToRefs(region);

const steps = ["Upload KTP & Data Diri", "Cetak KTA"];
const currentStep = ref(0);
const isEdit = ref(!!route.params.id);
const userStore = useUserStore();
const isAdmin = computed(() => {
  return userStore.user?.role === "admin";
});
const zoomedThumbnailIndex = ref(null);
// ✅ GANTI SEMUA FORM MENJADI ARRAY members
const members = ref([]);

const currentMemberIndex = ref(0);
const loading = ref(false);

// ❌ HAPUS SEMUA VARIABEL LAMA: form, stepperRef, dll

// ✅ FUNGSI UNTUK MEMILIH MEMBER
function selectMember(index) {
  // Jika klik thumbnail yang sama → toggle zoom
  if (zoomedThumbnailIndex.value === index) {
    zoomedThumbnailIndex.value = null; // Zoom out
  } else {
    // Zoom in ke thumbnail ini, dan jadikan anggota aktif
    zoomedThumbnailIndex.value = index;
    currentMemberIndex.value = index; // Tetap pilih anggota ini untuk form
  }
}

// ✅ FUNGSI UNTUK NAIK/TURUN MEMBER
// eslint-disable-next-line
function nextMember() {
  if (currentMemberIndex.value < members.value.length - 1) {
    currentMemberIndex.value++;
  }
}

function prevMember() {
  if (currentMemberIndex.value > 0) {
    currentMemberIndex.value--;
  }
}

// ✅ UPDATE DATA MEMBER AKTIF
function updateMember(updated) {
  members.value[currentMemberIndex.value] = {
    ...members.value[currentMemberIndex.value],
    ...updated,
  };
}

// ✅ UPLOAD BANYAK FILE → Tambahkan ke members
const handleFileUpload = (files) => {
  if (!files || files.length === 0) return;

  if (isEdit.value) {
    showAlert("Mode edit tidak mendukung upload banyak KTP.", "warning");
    return;
  }

  files.forEach((file) => {
    const newMember = {
      id: null,
      ktpUrl: URL.createObjectURL(file),
      ktpFile: file,
      ktpProcessedUrl: '',
      nik: '',
      name: '',
      gender: '',
      birthPlace: '',
      birthDate: '',
      address: '',
      phone: '',
      email: '',
      maritalStatus: '',
      occupation: 'LAINNYA',
      skills: '',
      interests: '',
      provinceCode: '',
      cityCode: '',
      districtCode: '',
      villageCode: '',
      isUploaded: true,
      isConfirmed: false, // 👈 TETAP FALSE — USER HARUS CEKLIST
      isProcessed: false, // 👈 TETAP FALSE — USER HARUS KLIK “PROSES”
      isProcessing: false,
    };
    members.value.push(newMember);
  });

  // 👇 SET INDEX KE ANGGOTA TERAKHIR (yang baru diupload)
  currentMemberIndex.value = members.value.length - 1;
};
async function prosesKtp(member, index) {
  if (member.isProcessed || !member.ktpFile) return;

  member.isProcessing = true;

  try {
    const formData = new FormData();
    formData.append("image", member.ktpFile);

    // 👇 GANTI ENDPOINT KE upload-ktp — TIDAK ADA CROP, HANYA UPLOAD FILE ASLI
    const res = await api.post("/members/upload-ktp", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });

    if (res.data.success && res.data.file_url) {
      // 👇 SIMPAN URL FILE ASLI — BUKAN HASIL CROP
      members.value[index] = {
        ...member,
        ktpProcessedUrl: res.data.file_url, // ✅ File asli yang di-upload
        isProcessed: true,
        isProcessing: false,
      };

      // Update form jika ini anggota aktif
      if (currentMemberIndex.value === index) {
        updateMember({
          ktpProcessedUrl: res.data.file_url,
          isProcessed: true,
        });
      }

      showAlert("KTP berhasil disimpan!", "success");
    } else {
      throw new Error("Gagal menyimpan file");
    }
  } catch (err) {
    console.error("Error menyimpan KTP:", err);
    showAlert(
      "Gagal menyimpan KTP. Pastikan gambar valid dan tidak rusak.",
      "error"
    );
    members.value[index].isProcessing = false;
  }
}

// ✅ SIMPAN SEMUA ANGGOTA
async function saveAllMembers() {
  const membersToSave = members.value.filter(
    (m) => m.isConfirmed
  );

  if (membersToSave.length === 0) {
    showAlert("Tidak ada anggota yang siap disimpan.", "warning");
    return;
  }

  const invalidMembers = membersToSave.filter(
    (m) =>
      !m.nik ||
      !m.name ||
      !m.birthPlace ||
      !m.provinceCode ||
      !m.cityCode ||
      !m.districtCode ||
      !m.villageCode
  );

  if (invalidMembers.length > 0) {
    const names = invalidMembers.map(m => m.name || 'Anggota tanpa nama').join(', ');
    showAlert(
      `Data tidak lengkap untuk anggota: ${names}. Silakan lengkapi semua field.`,
      "error"
    );
    return;
  }

  loading.value = true;

  try {
    const promises = membersToSave.map(async (member) => {
      // 👇 BEDAKAN: JIKA ADA ID → UPDATE, JIKA TIDAK ADA → CREATE
      if (member.id) {
        // 👈 MODE EDIT: UPDATE
        return await MemberService.updateMember(member.id, {
          nik: member.nik,
          ktaNumber: member.ktaNumber,
          name: member.name,
          gender: member.gender,
          birthPlace: member.birthPlace || null,
          birthDate: member.birthDate ? new Date(member.birthDate) : null,
          address: member.address || null,
          phone: member.phone || null,
          email: member.email || null,
          maritalStatus: member.maritalStatus || null,
          occupation: member.occupation || null,
          skills: member.skills || null,
          interests: member.interests || null,
          provinceCode: member.provinceCode || null,
          cityCode: member.cityCode || null,
          districtCode: member.districtCode || null,
          villageCode: member.villageCode || null,
          ktpUrl: member.ktpUrl || null,
          ktpProcessedUrl: member.ktpProcessedUrl || null,
          photoUrl: member.photoUrl || null,
          certificateUrl: member.certificateUrl || null,
          registrationType: member.registrationType || "admin",
          registeredById: userStore.user?.id || null,
          isOfficial: member.isOfficial ?? false,
        });
      } else {
        // 👈 MODE CREATE: CREATE BARU
        return await MemberService.createMember({
          nik: member.nik,
          ktaNumber: member.ktaNumber,
          name: member.name,
          gender: member.gender,
          birthPlace: member.birthPlace || null,
          birthDate: member.birthDate ? new Date(member.birthDate) : null,
          address: member.address || null,
          phone: member.phone || null,
          email: member.email || null,
          maritalStatus: member.maritalStatus || null,
          occupation: member.occupation || null,
          skills: member.skills || null,
          interests: member.interests || null,
          provinceCode: member.provinceCode || null,
          cityCode: member.cityCode || null,
          districtCode: member.districtCode || null,
          villageCode: member.villageCode || null,
          ktpUrl: member.ktpUrl || null,
          ktpProcessedUrl: member.ktpProcessedUrl || null,
          photoUrl: member.photoUrl || null,
          certificateUrl: member.certificateUrl || null,
          registrationType: "admin",
          registeredById: userStore.user?.id || null,
          isOfficial: member.isOfficial ?? false,
        });
      }
    });

    const savedMembers = await Promise.all(promises);

    showAlert(`${savedMembers.length} anggota berhasil disimpan!`, "success");
    router.push("/member");
  } catch (err) {
    console.error("Gagal menyimpan anggota:", err);

    if (err.message.includes("Gagal menyimpan anggota")) {
      showAlert(err.message, "error");
    } else if (err.response?.data?.message) {
      showAlert(`Gagal menyimpan: ${err.response.data.message}`, "error");
    } else {
      showAlert("Gagal menyimpan salah satu anggota. Cek NIK dan data lainnya.", "error");
    }
  } finally {
    loading.value = false;
  }
}

// ✅ GENERATE KTA UNTUK MEMBER AKTIF
const generateKTA = async () => {
  const member = members.value[currentMemberIndex.value];

  if (
    !member.provinceCode ||
    !member.cityCode ||
    !member.districtCode
  ) {
    member.ktaNumber = null;
    return;
  }

  const prov = member.provinceCode.slice(0, 2);
  const kab = member.cityCode.slice(-2);
  const kec = member.districtCode.slice(-2);
  const prefix = `${prov}${kab}${kec}`;

  try {
    const res = await api.get(`/members/kta/last-num?prefix=${prefix}`);
    let lastNumber = res.data?.lastNumber || null;

    if (!lastNumber) {
      member.ktaNumber = `${prefix}0001`;
    } else {
      const lastSeq = parseInt(lastNumber.slice(-4), 10);
      const newSeq = (lastSeq + 1).toString().padStart(4, "0");
      member.ktaNumber = `${prefix}${newSeq}`;
    }
  } catch (err) {
    console.error("Gagal generate KTA:", err);
    member.ktaNumber = `${prefix}0001`;
  }
};

// ✅ FETCH MEMBER UNTUK EDIT MODE
async function fetchMember() {
  if (!isEdit.value) return;

  try {
    const member = await MemberService.getMemberById(route.params.id);

    // 👇 TAMBAHKAN isConfirmed: true — KARENA DATA SUDAH ADA DAN TELAH DIVERIFIKASI
    members.value = [{
      id: member.id,
      nik: member.nik,
      ktaNumber: member.ktaNumber,
      name: member.name,
      gender: member.gender,
      birthPlace: member.birthPlace ? member.birthPlace.split(' ')[0] : null,
      birthDate: member.birthDate ? member.birthDate.split(' ')[0] : null,
      address: member.address,
      phone: member.phone,
      email: member.email,
      maritalStatus: member.maritalStatus,
      occupation: member.occupation,
      skills: member.skills,
      interests: member.interests,
      provinceCode: member.provinceCode,
      cityCode: member.cityCode,
      districtCode: member.districtCode,
      villageCode: member.villageCode,
      ktpUrl: member.ktpUrl,
      ktpProcessedUrl: member.ktpProcessedUrl,
      photoUrl: member.photoUrl,
      certificateUrl: member.certificateUrl,
      registrationType: member.registrationType,
      registeredById: member.registeredById,
      isOfficial: member.isOfficial,
      isUploaded: !!member.ktpUrl,
      isProcessed: !!member.ktpProcessedUrl, // 👈 JIKA ADA KTP PROSES, SET TRUE
      isProcessing: false,
    }];

    // Set index ke 0 (hanya satu anggota saat edit)
    currentMemberIndex.value = 0;

    // Fetch wilayah berdasarkan kode yang sudah ada
    if (member.provinceCode) {
      await region.fetchCities(member.provinceCode);
    }
    if (member.cityCode) {
      await region.fetchDistricts(member.cityCode);
    }
    if (member.districtCode) {
      await region.fetchVillages(member.districtCode);
    }
  } catch (err) {
    console.error("Gagal load data anggota:", err);
    alert("Gagal memuat data anggota");
    router.push({ name: "Member" });
  }
}

// ✅ NAVIGASI STEP
function goToStep(index) {
  if (index <= currentStep.value + 1) {
    currentStep.value = index;
    window.scrollTo(0, 0);
  }
}

// ✅ LANJUT KE STEP 2 (CETAK KTA)
import { nextTick } from "vue";
// eslint-disable-next-line
async function nextStep() {
  // eslint-disable-next-line
  const member = members.value[currentMemberIndex.value];

  await nextTick();
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

// ✅ FETCH WILAYAH
async function fetchKabupaten() {
  const member = members.value[currentMemberIndex.value];
  if (!member.provinceCode) return;
  region.fetchCities(member.provinceCode);
}

async function fetchKecamatan() {
  const member = members.value[currentMemberIndex.value];
  if (!member.cityCode) return;
  region.fetchDistricts(member.cityCode);
}

async function fetchKelurahan() {
  const member = members.value[currentMemberIndex.value];
  if (!member.districtCode) return;
  region.fetchVillages(member.districtCode);
}

// ✅ CANCEL
const handleCancel = () => {
  router.back();
};

onMounted(async () => {
  region.fetchProvinces();
  console.log(region.provinces);

  if (isEdit.value) {
    await fetchMember();
    currentStep.value = 0; // Tetap di step 0 saat edit
  }
});
</script>
<template>
  <div class="member-form">
    <div class="step-container">
      <!-- Action Buttons -->
      <div ref="stepperRef" class="step-actions">
        <button class="btn-cancel" @click="handleCancel">Cancel</button>
        <!-- Step Indicator -->
        <div class="step-indicator">
          <StepIndicator :steps="isEdit ? ['Data Anggota', 'Cetak KTA'] : steps" :currentStep="currentStep"
            @goToStep="goToStep" />
        </div>
      </div>
    </div>

    <div class="form-card">
      <!-- STEP 0: UPLOAD KTP + FORM -->
      <div v-if="currentStep === 0" class="upload-and-form-container">
        <!-- Kolom Kiri: Upload KTP -->
        <div class="upload-column">
          <AppFileUpload title="Upload KTP" @upload:files="handleFileUpload" />
          <div class="member-list-container">
            <div class="member-list">
              <h4>KTP yang Diupload</h4>
              <div class="member-thumbnails">
                <div v-for="(member, index) in members" :key="index" class="member-thumbnail" :class="{
                  active: currentMemberIndex === index,
                  'is-zoomed': zoomedThumbnailIndex === index
                }" @click="selectMember(index)">
                  <img :src="member.ktpUrl" alt="KTP" class="thumbnail"
                    :class="{ 'zoomed-image': zoomedThumbnailIndex === index }" />
                  <span class="badge">{{ index + 1 }}</span>

                  <!-- 👇 TOMBOL PROSES KTP -->
                  <button type="button" class="btn btn-blue btn-sm" @click.stop="prosesKtp(member, index)"
                    :disabled="member.isProcessed" style="
      position: absolute;
      bottom: 4px;
      right: 4px;
      padding: 4px 8px;
      font-size: 0.7em;
      background: #3498db;
      color: white;
      border: none;
      border-radius: 4px;
    ">
                    Proses
                  </button>

                  <span v-if="member.isProcessed" class="status processed">✓</span>
                  <span v-else-if="member.isUploaded" class="status uploaded">⏳</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Kolom Kanan: Form Data Diri + Wilayah -->
        <div class="form-column">
          <!-- Data Diri -->
          <PersonalDataForm :form="members[currentMemberIndex]" :provinsiList="provinces" :is-admin="isAdmin"
            @update:form="updateMember" />

          <!-- Wilayah Pendaftaran -->
          <RegionSelectionStep :form="members[currentMemberIndex]" :provinsiList="provinces" :kabupatenList="cities"
            :kecamatanList="districts" :kelurahanList="villages" :is-edit="isEdit" @update:form="updateMember"
            @fetch-kabupaten="fetchKabupaten" @fetch-kecamatan="fetchKecamatan" @fetch-kelurahan="fetchKelurahan"
            @generate-kta="generateKTA" @prev-step="() => { }" @next-step="() => { }" />

          <!-- Tombol Navigasi -->
          <div class="step-navigation">
            <button type="button" class="btn" @click="prevMember" :disabled="currentMemberIndex === 0">
              ← Sebelumnya
            </button>

            <button type="button" class="btn btn-green" @click="nextMember"
              :disabled="currentMemberIndex >= members.length - 1">
              Berikutnya →
            </button>

            <button type="button" class="btn btn-primary" @click="saveAllMembers">
              Simpan Semua Anggota
            </button>
          </div>
        </div>
      </div>

      <!-- STEP 1: CETAK KTA -->
      <KtaGenerationStep v-if="currentStep === 1" :form="members[currentMemberIndex]" :isEdit="isEdit"
        @update:form="updateMember" @prev-step="prevStep" />
    </div>

    <!-- LIST THUMBNAIL KTP -->


    <p v-if="error" class="error">{{ error }}</p>

  </div>
</template>
<style scoped>
.member-list-container {
  display: flex;
  gap: 24px;
  margin-top: 20px;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  justify-content: center;
  align-items: center;
}

.member-list {
  width: 200px;
  background: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  height: fit-content;

}

.member-list h4 {
  margin-bottom: 12px;
  font-size: 0.9em;
  color: #555;
}

.member-thumbnails {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.member-thumbnail {
  position: relative;
  cursor: pointer;
  border: 2px solid #ddd;
  border-radius: 6px;
  overflow: hidden;
  width: 100%;
  height: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.member-thumbnail.is-zoomed {
  z-index: 10;
  transform: scale(2.5);
  /* 👈 Zoom hingga 2.5x */
  width: 250px !important;
  /* Perlebar lebar container */
  height: 150px !important;
  /* Perlebar tinggi container */
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  border-color: var(--primary);
}

.thumbnail {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
  transition: transform 0.3s ease;
}

.thumbnail.zoomed-image {
  transform: scale(1.2);
  /* 👈 Sedikit diperbesar lagi agar lebih tajam */
}

.badge,
.status {
  transition: opacity 0.3s ease;
}

.member-thumbnail.is-zoomed .badge,
.member-thumbnail.is-zoomed .status {
  opacity: 0.9;
}

.member-thumbnail.active {
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(108, 99, 255, 0.2);
}

.thumbnail {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}

.badge {
  position: absolute;
  top: 4px;
  right: 4px;
  background: #6c63ff;
  color: white;
  font-size: 0.7em;
  padding: 2px 6px;
  border-radius: 10px;
  font-weight: bold;
}

.status {
  position: absolute;
  bottom: 4px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 0.7em;
  font-weight: bold;
}

.status.processed {
  color: #27ae60;
}

.status.uploaded {
  color: #3498db;
}

.upload-and-form-container {
  display: flex;
  gap: 32px;
  margin-top: 20px;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  align-items: flex-start;
}


.form-column {
  flex: 1;
  min-width: 300px;
}

.upload-column {
  flex: 1.2;
  min-width: 400px;
  padding: 24px;
  background-color: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e0e0e0;

  /* 🔑 ini kuncinya */
  position: sticky;
  top: 20px;
  /* jarak dari atas layar */
  align-self: flex-start;
  /* supaya sticky bekerja dalam flexbox */
  height: fit-content;
  /* tinggi menyesuaikan isi, bukan full */
}

.form-column {
  padding: 20px;
  background-color: white;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  display: flex;
  flex-direction: column;
  gap: 24px;
  /* Jarak antara form data diri dan wilayah */
}

.region-selection-step {
  margin-top: 0;
  /* Hilangkan margin atas dari RegionSelectionStep */
  padding-top: 0;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

/* Mobile */
@media (max-width: 768px) {
  .upload-and-form-container {
    flex-direction: column;
    gap: 20px;
  }
}

.edit-preview-step {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background: #f9f9f9;
  border-radius: 8px;
}

.preview-card {
  background: white;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.preview-row {
  margin-bottom: 8px;
  padding: 6px 0;
  border-bottom: 1px solid #eee;
}

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
  justify-content: center;
  align-items: center;
  /* box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); */
}

.step-scroll {
  position: relative;
  /* atau fixed kalau mau selalu di layar */
  top: 0;
  z-index: 50;
  /* supaya di atas konten */
  background: white;
  /* supaya nggak transparan */
  margin: 0;
  /* hilangkan margin */
  padding: 10px 0;
  /* opsional, biar ada jarak dalam */
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

.step-indicator {}

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
