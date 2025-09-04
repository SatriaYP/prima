<script setup>
import { ref, watch, computed, toRefs } from "vue";
import api from "@/services/api.service";
import AppFileUpload from "./AppFileUpload.vue";
// import BaseButton from "../common/BaseButton.vue";

const props = defineProps({
  form: {
    type: Object,
    required: true,
  },
  provinsiList: {
    type: Array,
    required: true,
  },
  kabupatenList: {
    type: Array,
    required: true,
  },
});

const emit = defineEmits([
  "update:form",
  "next-step",
  "fetch-kabupaten",
  "fetch-kecamatan",
]);

// const { form, provinsiList, kabupatenList } = toRefs(props);
const { form } = toRefs(props);
// const ktpInput = ref(null);

const ocrLoading = ref(false);
const ocrError = ref("");
const ocrResult = ref(null);
const regionOptions = ref(props.provinsiList);
console.log(regionOptions.value, "qwqwqw");

// Computed Date Formatted
const dateFormatted = computed({
  get() {
    if (!form.value.birthDate) return "";
    const [day, month, year] = form.value.birthDate.split("-");
    // const [year, month, day] = form.value.birthDate.split("-");
    // return `${day}/${month}/${year}`;
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  },
  set(val) {
    const parts = val.split("/");
    if (parts.length === 3) {
      const [d, m, y] = parts;
      if (y && m && d) {
        emit("update:form", {
          ...form.value,
          birthDate: `${y}-${m.padStart(2, "0")}-${d.padStart(2, "0")}`,
        });
      }
    }
  },
});

// const handleOcr = (ocrData) => {
//   if (ocrData) {
//     Object.assign(member, ocrData);
//   } else {
//     Object.keys(member).forEach((key) => (member[key] = ""));
//   }
//   // console.log(`Data member: ${ocrData}`);
// };

watch(
  () => form.value.birthDate,
  (val) => {
    if (val && val.length >= 3) {
      fetchRegionOptions(val);
    }
  }
);

// Utility
// function toTitleCase(str) {
//   return str
//     .toLowerCase()
//     .split(" ")
//     .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
//     .join(" ");
// }

async function fetchRegionOptions(query) {
  try {
    const res = await api.get(
      `/regions/search?query=${encodeURIComponent(query)}`
    );
    regionOptions.value = res.data;
  } catch (e) {
    console.error("Error fetching region options:", e);
    regionOptions.value = [];
  }
}

function nextStep() {
  emit("next-step");
}

const handleFileUpload = (file) => {
  const fileData = file;
  // if (!fileData) return;
  if (!fileData) {
    Object.keys(form.value).forEach((key) => {
      form.value[key] = null;
    });
    emit("update:form", {
      ...form.value,
    });
  }
  emit("update:form", {
    ...form.value,
    ktpUrl: fileData ? URL.createObjectURL(fileData) : null,
    ktpProcessedUrl: "",
  });
};

// function handleFileUpload(e) {
//   const file = e.target.files[0];
//   if (file) {
//     emit("update:form", {
//       ...form.value,
//       fotoKtp: file,
//       fotoKtpUrl: URL.createObjectURL(file),
//       fotoKtpProcessedUrl: "",
//     });
//     // emit("update:form", {
//     //   ...form.value,
//     //   fotoKtp: file,
//     //   fotoKtpUrl: URL.createObjectURL(file),
//     //   fotoKtpProcessedUrl: "",
//     // });
//     // ocrResult.value = null;
//     // ocrError.value = "";
//   }
// }

// function resetKtpUpload() {
//   emit("update:form", {
//     ...form.value,
//     fotoKtp: null,
//     fotoKtpUrl: "",
//     fotoKtpProcessedUrl: "",
//   });
//   ocrResult.value = null;
//   ocrError.value = "";
//   if (ktpInput.value) ktpInput.value.value = "";
// }

function downloadProcessedImage() {
  if (!form.value.fotoKtpProcessedUrl) return;
  const a = document.createElement("a");
  a.href = form.value.fotoKtpProcessedUrl;
  a.download = "ktp_processed_" + new Date().getTime() + ".jpg";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

function onImageLoad() {
  console.log("Image loaded successfully:", form.value.fotoKtpProcessedUrl);
}

function onImageError(event) {
  console.error("Image failed to load:", form.value.fotoKtpProcessedUrl);
  console.error("Error event:", event);
  ocrError.value = "Gagal memuat gambar hasil proses. Silakan coba lagi.";
}

async function prosesKtpOcr() {
  // if (!form.value.fotoKtp) return;
  if (!form.value.ktpUrl) return;
  ocrLoading.value = true;
  ocrError.value = "";
  ocrResult.value = null;

  try {
    // const formData = new FormData();
    // formData.append("image", form.value.fotoKtp);

    // const res = await api.post("/ktp-ocr", formData, {
    //   headers: { "Content-Type": "multipart/form-data" },
    //   timeout: 120000,
    // });

    // if (res.data.success && res.data.data) {
    //   ocrResult.value = JSON.stringify(res.data, null, 2);

    //   let imageUrl = res.data.processed_image_url;
    //   if (!imageUrl && res.data.file_paths?.processed_image) {
    //     const baseUrl =
    //       window.location.protocol + "//" + window.location.hostname;
    //     imageUrl = `${baseUrl}/api${res.data.file_paths.processed_image}`;
    //   }

    //   const ocr = res.data.data;
    //   const updatedForm = { ...form.value };

    //   if (imageUrl) updatedForm.fotoKtpProcessedUrl = imageUrl;
    //   if (ocr.nik) {
    //     updatedForm.nik = ocr.nik;
    //     if (ocr.nik.length === 16) {
    //       const provCode = ocr.nik.substring(0, 2);
    //       const kabCode = ocr.nik.substring(0, 4);
    //       const matchingProv = provinsiList.value.find((p) =>
    //         p.id.startsWith(provCode)
    //       );
    //       if (matchingProv) {
    //         updatedForm.provinsiId = matchingProv.id;
    //         emit("fetch-kabupaten");
    //         setTimeout(() => {
    //           const matchingKab = kabupatenList.value.find(
    //             (k) => k.id === kabCode
    //           );
    //           if (matchingKab) {
    //             updatedForm.kabupatenId = matchingKab.id;
    //             emit("fetch-kecamatan");
    //           }
    //         }, 500);
    //       }
    //     }
    //   }
    //   if (!updatedForm.nama && ocr.nama)
    //     updatedForm.nama = toTitleCase(ocr.nama);
    //   if (ocr.alamat) updatedForm.alamat = toTitleCase(ocr.alamat);

    //   if (ocr.ttl) {
    //     const ttlParts = ocr.ttl.split(/[,.-]/);
    //     if (ttlParts.length >= 4) {
    //       updatedForm.tempatLahir = ttlParts[0].trim();
    //       updatedForm.tanggalLahir = `${ttlParts[3]}-${ttlParts[2].padStart(
    //         2,
    //         "0"
    //       )}-${ttlParts[1].padStart(2, "0")}`;
    //     }
    //   }

    //   if (ocr.kelamin) {
    //     const kelamin = ocr.kelamin.toUpperCase();
    //     if (kelamin.includes("LAKI")) updatedForm.jenisKelamin = "Laki-laki";
    //     else if (kelamin.includes("PEREMPUAN") || kelamin.includes("WANITA"))
    //       updatedForm.jenisKelamin = "Perempuan";
    //   }

    //   if (ocr.kawin) {
    //     const kawin = ocr.kawin.toUpperCase();
    //     if (kawin.includes("BELUM"))
    //       updatedForm.statusPerkawinan = "Belum Kawin";
    //     else if (kawin.includes("KAWIN"))
    //       updatedForm.statusPerkawinan = "Kawin";
    //     else if (kawin.includes("CERAI"))
    //       updatedForm.statusPerkawinan = "Cerai";
    //   }

    //   if (ocr.kerja) updatedForm.statusPekerjaan = ocr.kerja;

    //   if (!updatedForm.tempatLahir && ocr.tempat_lahir)
    //     updatedForm.tempatLahir = toTitleCase(ocr.tempat_lahir);
    //   if (!updatedForm.tanggalLahir && ocr.tanggal_lahir)
    //     updatedForm.tanggalLahir = ocr.tanggal_lahir;
    //   if (!updatedForm.jenisKelamin && ocr.jenis_kelamin)
    //     updatedForm.jenisKelamin = ocr.jenis_kelamin;
    //   if (!updatedForm.statusPerkawinan && ocr.status_perkawinan)
    //     updatedForm.statusPerkawinan = ocr.status_perkawinan;
    //   if (!updatedForm.statusPekerjaan && ocr.status_pekerjaan)
    //     updatedForm.statusPekerjaan = ocr.status_pekerjaan;

    //   // emit("update:form", updatedForm);
    // } else {
    //   throw new Error("Response OCR tidak valid");
    // }
    emit("update:form", {
      ...form.value,
      nik: "12345678901238745",
      ktaNumber: "",
      name: "King Salman",
      gender: "Laki-laki",
      birthPlace: "Bandung",
      birthDate: "12-05-2001",
      address: "Jl. Merdeka 2",
      phone: "",
      email: "",
      maritalStatus: "Kawin",
      occupation: "Wiraswasta",
      skills: "Organisasi, Kepemimpinan",
      interests: "Politik, Sosial",
      provinceCode: "32",
      cityCode: "32.04",
      districtCode: "32.04.05",
      villageCode: "32.04.05.2005",
      ktpProcessedUrl: null,
      photoUrl: null,
      certificateUrl: null,
      registrationType: "admin",
      registeredById: null,
      isOfficial: false,
    });
  } catch (err) {
    console.error("Error OCR:", err);
    if (err.code === "ECONNABORTED") {
      ocrError.value =
        "Proses OCR memakan waktu terlalu lama. Silakan coba lagi atau gunakan gambar yang lebih jelas.";
    } else if (err.response?.status === 413) {
      ocrError.value =
        "File gambar terlalu besar. Gunakan gambar dengan ukuran maksimal 5MB.";
    } else if (err.response?.status === 400) {
      ocrError.value =
        "Format file tidak didukung. Gunakan file gambar (JPG, PNG, dll).";
    } else if (err.response?.status >= 500) {
      ocrError.value =
        "Server OCR sedang bermasalah. Silakan coba beberapa saat lagi.";
    } else {
      ocrError.value =
        err.response?.data?.message ||
        "Gagal memproses KTP. Pastikan gambar jelas dan server OCR aktif.";
    }
  } finally {
    ocrLoading.value = false;
  }
}
</script>
<template>
  <div class="ktp-upload-step">
    <div class="form-group ktp-upload-block">
      <!-- <label>Upload Foto KTP</label>
      <input
        type="file"
        @change="handleFileUpload"
        accept="image/*"
        ref="ktpInput"
      /> -->
      <AppFileUpload title="Upload KTP" @upload:file="handleFileUpload" />

      <!-- Preview KTP -->
      <div class="ktp-upload-preview-container">
        <div class="ktp-images-comparison">
          <!-- Slot Original -->
          <div class="ktp-image-container">
            <h4>Foto KTP</h4>
            <template v-if="form.ktpUrl">
              <img :src="form.ktpUrl" alt="Foto KTP" class="ktp-preview" />
            </template>
            <template v-else>
              <div class="ktp-placeholder">Belum ada foto</div>
            </template>
          </div>
          <div class="ktp-arrow">&#x2192;</div>
          <div class="ktp-image-container">
            <h4>Foto Hasil Proses</h4>
            <template v-if="form.ktpProcessedUrl">
              <img
                :src="form.ktpProcessedUrl"
                :key="form.ktpProcessedUrl + Date.now()"
                alt="KTP hasil proses"
                class="ktp-preview processed"
                @load="onImageLoad"
                @error="onImageError"
              />
              <button
                type="button"
                class="btn btn-blue btn-sm"
                @click="downloadProcessedImage"
              >
                Download Foto
              </button>
            </template>
            <template v-else>
              <div class="ktp-placeholder">Menunggu proses...</div>
            </template>
          </div>
        </div>

        <button
          v-if="form.ktpUrl && !ocrLoading"
          type="button"
          class="btn btn-blue"
          @click="prosesKtpOcr"
        >
          Proses dan Isi Otomatis
        </button>

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
          <div class="loading-tip">
            Tips: Pastikan gambar KTP jelas dan tidak blur
          </div>
        </div>
        <div v-if="ocrError" class="ocr-error">
          <span class="ocr-error-icon"
            ><svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
            >
              <path
                fill="none"
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 12a9 9 0 1 0 18 0a9 9 0 1 0-18 0m9-3v4m0 3v.01"
              /></svg></span
          >{{ ocrError }}
        </div>
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
        <input v-model="form.name" required />
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Tempat Lahir</label>
        <input
          v-model="form.birthPlace"
          list="birthplace-list"
          placeholder="Kota / Kabupaten"
          required
        />
        <datalist id="birthplace-list">
          <option
            v-for="r in regionOptions"
            :key="r.id"
            :value="r.name"
          ></option>
        </datalist>
      </div>
      <div class="form-group">
        <label>Tanggal Lahir</label>
        <input
          v-model="dateFormatted"
          placeholder="DD/MM/YYYY"
          required
          type="date"
        />
      </div>
    </div>
    <!-- Row Tempat & Tanggal + Alamat -->
    <div class="form-group">
      <label>Alamat</label>
      <input v-model="form.address" />
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Jenis Kelamin</label>
        <select v-model="form.gender" required>
          <option value="">Pilih</option>
          <option value="Laki-laki">Laki-laki</option>
          <option value="Perempuan">Perempuan</option>
        </select>
      </div>
      <div class="form-group">
        <label>Status Perkawinan</label>
        <select v-model="form.maritalStatus" required>
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
        <input v-model="form.occupation" />
      </div>
      <div class="form-group">
        <label>Minat/Bakat</label>
        <input v-model="form.interests" />
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Email</label>
        <input v-model="form.email" />
      </div>
      <div class="form-group">
        <label>No. Hp</label>
        <input v-model="form.phone" />
      </div>
    </div>

    <!-- Navigation -->
    <div class="step-navigation">
      <button type="button" class="btn btn-green" @click="nextStep">
        Next
      </button>
      <!-- <BaseButton @click="nextStep">Next</BaseButton> -->
      <!-- <button type="button" class="btn btn-green" @click="nextStep">
        Lanjut ke Wilayah Pendaftaran
      </button> -->
    </div>
  </div>
</template>
<style scoped>
.ktp-upload-step {
  display: flex;
  flex-direction: column;
  gap: 20px;
  /* background-color: #3498db; */
  max-width: 600px;
  margin: auto;
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
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.ocr-error {
  display: flex;
  align-items: center;
  justify-content: start;
  gap: 10px;
  margin: 10px 0;
  color: #b11d0c;
  font-weight: 500;
  font-size: 14px;
  background: #ffcece;
  border-radius: 6px;
  padding: 8px;
}

.ocr-error-icon {
  background-color: #ff6060;
  padding: 3px;
  border-radius: 50%;
  color: #fff;
  line-height: 50%;
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
