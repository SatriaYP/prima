<script setup>
import { computed } from "vue";
import html2canvas from "html2canvas";
import jsPDF from "jspdf";
import { useRouter } from "vue-router";
const router = useRouter();
// import api from "@/services/api.service";
// import { useAlert } from "@/composables/useAlert";
// import BaseButton from "../common/BaseButton.vue";

// // const { showAlert } = useAlert();
// console.log("🔍 [KTA-STEP] Props form diterima:", props.form);

// // Buat computed sementara untuk debug
// const debugForm = computed(() => ({
//   ktaNumber: props.form.ktaNumber,
//   name: props.form.name,
//   nik: props.form.nik,
// }));
// console.log("📊 [DEBUG] Nilai aktual di KtaGenerationStep:", debugForm.value);
const props = defineProps({
  form: {
    type: Object,
    required: true,
  },
  isEdit: {
    type: Boolean,
    default: false,
  },
});
// eslint-disable-next-line
const emit = defineEmits(["update:form", "prev-step"]);

const formatTanggalLahir = computed(() => {
  if (!props.form.birthDate) return "";
  const date = new Date(props.form.birthDate);
  return date.toLocaleDateString("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
});

// const updateConfirmation = (event) => {
//   emit("update:form", {
//     ...props.form,
//     isConfirmed: event.target.checked,
//   });
// };

// const downloadKta = () => {
//   if (!props.form.isConfirmed) return;
//   html2canvas(document.querySelector(".kta-card")).then((canvas) => {
//     const imgData = canvas.toDataURL("image/png");
//     const link = document.createElement("a");
//     link.download = `KTA_${props.form.noKta || "anggota"}.png`;
//     link.href = imgData;
//     link.click();
//   });
// };

const printKta = () => {
  if (!props.form.isConfirmed) return;
  html2canvas(document.querySelector(".kta-card")).then((canvas) => {
    const imgData = canvas.toDataURL("image/png");
    const pdf = new jsPDF({
      orientation: "landscape",
      unit: "mm",
      format: [85, 55], // ukuran kartu ID
    });
    pdf.addImage(imgData, "PNG", 0, 0, 85, 55);
    pdf.autoPrint();
    pdf.output("dataurlnewwindow");
  });
};
console.log("🩸 [KTA STEP] FORM AKHIR:", props.form);

// const handleCreateMember = async () => {
//   try {
//     const form = props.form;
//     // const payload = {
//     //   nik: form.nik,
//     //   ktaNumber: form.ktaNumber, // Pastikan nama field sesuai schema
//     //   name: form.name,
//     //   gender: form.jenisKelamin,
//     //   birthPlace: form.birthPlace || null,
//     //   birthDate: form.birthDate || null,
//     //   address: form.alamat || null,
//     //   phone: form.noHp || null,
//     //   email: form.email || null,
//     //   maritalStatus: form.statusPerkawinan || null,
//     //   occupation: form.pekerjaan || null,
//     //   skills: form.keahlian || null,
//     //   interests: form.minat || null,
//     //   ktpUrl: form.ktpUrl || null,
//     //   ktpProcessedUrl: form.ktpProcessedUrl || null,
//     //   photoUrl: form.fotoUrl || null,
//     //   certificateUrl: form.sertifikatUrl || null,
//     //   registrationType: form.tipeRegistrasi || null,
//     //   isOfficial: form.isOfficial ?? false,
//     //   province: form.provinceId
//     //     ? { connect: { id: form.provinceId } }
//     //     : undefined,
//     //   city: form.cityId ? { connect: { id: form.cityId } } : undefined,
//     //   district: form.districtId
//     //     ? { connect: { id: form.districtId } }
//     //     : undefined,
//     //   village: form.villageId ? { connect: { id: form.villageId } } : undefined,
//     //   registeredBy: form.registeredById
//     //     ? { connect: { id: form.registeredById } }
//     //     : undefined,
//     // };
//     const payload = {
//       nik: form.nik,
//       ktaNumber: form.ktaNumber,
//       name: form.name,
//       gender: form.gender,
//       birthPlace: form.birthPlace || null,
//       birthDate: form.birthDate ? new Date(form.birthDate) : null, // ✅ fix Date
//       address: form.address || null,
//       phone: form.phone || null,
//       email: form.email || null,
//       maritalStatus: form.maritalStatus || null,
//       occupation: form.occupation || null,
//       skills: form.skills || null,
//       interests: form.interests || null,
//       provinceCode: form.provinceCode || null,
//       cityCode: form.cityCode || null,
//       districtCode: form.districtCode || null,
//       villageCode: form.villageCode || null,
//       ktpUrl: form.ktpUrl || null,
//       ktpProcessedUrl: form.ktpProcessedUrl || null,
//       photoUrl: form.photoUrl || null,
//       certificateUrl: form.certificateUrl || null,
//       registrationType: form.registrationType || "admin",
//       registeredById: form.registeredById || null,
//       isOfficial: form.isOfficial ?? false,
//     };
//     const res = await api.post("/members", payload);
//     if (res) {
//       showAlert("Anggota berhasil ditambahkan", "success");
//     }
//   } catch (error) {
//     const message = error.response?.data?.message || "Terjadi kesalahan.";
//     showAlert(message, "error");
//   }
// };

const handleEdit = () => {
  if (!props.form.id) {
    alert("Data belum tersimpan. Silakan simpan terlebih dahulu.");
    return;
  }
  router.push(`/member/${props.form.id}/edit`); // ✅ BENAR — sesuai route Anda
};

// ✅ TAMBAH ANGGOTA BARU: BUKA FORM BARU (kosong)
const handleAddNew = () => {
  router.push("/member/create-new-member"); // ✅ SESUAI ROUTE ANDA
};

// ✅ SELESAI: KEMBALI KE DAFTAR ANGGOTA
const handleFinish = () => {
  router.push("/member");
};
</script>
<!-- <script>
import html2canvas from "html2canvas";
import jsPDF from "jspdf";

export default {
  name: "KtaGenerationStep",
  props: {
    form: {
      type: Object,
      required: true,
    },
    isEdit: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    formatTanggalLahir() {
      if (!this.form.tanggalLahir) return "";

      const date = new Date(this.form.tanggalLahir);
      return date.toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
      });
    },
  },
  methods: {
    updateConfirmation(event) {
      this.$emit("update:form", {
        ...this.form,
        isConfirmed: event.target.checked,
      });
    },
    prevStep() {
      this.$emit("prev-step");
    },
    downloadKta() {
      if (!this.form.isConfirmed) return;

      html2canvas(document.querySelector(".kta-card")).then((canvas) => {
        // Create image
        const imgData = canvas.toDataURL("image/png");

        // Create link and trigger download
        const link = document.createElement("a");
        link.download = `KTA_${this.form.noKta || "anggota"}.png`;
        link.href = imgData;
        link.click();
      });
    },
    printKta() {
      if (!this.form.isConfirmed) return;

      html2canvas(document.querySelector(".kta-card")).then((canvas) => {
        const imgData = canvas.toDataURL("image/png");

        // Create PDF
        const pdf = new jsPDF({
          orientation: "landscape",
          unit: "mm",
          format: [85, 55], // ID card size
        });

        // Add image to PDF
        pdf.addImage(imgData, "PNG", 0, 0, 85, 55);

        // Print PDF
        pdf.autoPrint();
        pdf.output("dataurlnewwindow");
      });
    },
  },
};
</script> -->
<template>
  <div class="kta-generation-step">
    <h3>Cetak Kartu Tanda Anggota</h3>

    <div class="kta-preview">
      <div class="kta-card">
        <div class="kta-header">
          <div class="kta-logo">
            <img src="../../assets/prima_logo.png" alt="Logo Partai" />
          </div>
          <div class="kta-title">
            <h4>KARTU TANDA ANGGOTA</h4>
            <h5>PARTAI PRIMA INDONESIA</h5>
          </div>
        </div>

        <div class="kta-body">
          <div class="kta-photo">
            <div class="kta-photo-placeholder">
              <span>Foto 3x4</span>
            </div>
          </div>

          <div class="kta-data">
            <div class="kta-field">
              <span class="kta-label">No. KTA:</span>
              <span class="kta-value">{{ form.ktaNumber || 'KOSONG!' }}</span> <!-- 👈 TAMBAHKAN || 'KOSONG!' -->
            </div>
            <div class="kta-field">
              <span class="kta-label">Nama:</span>
              <span class="kta-value">{{ form.name || 'KOSONG!' }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">NIK:</span>
              <span class="kta-value">{{ form.nik || 'KOSONG!' }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">TTL:</span>
              <span class="kta-value">{{ form.birthPlace ? `${form.birthPlace}, ${formatTanggalLahir}` : 'KOSONG!'
              }}</span>
            </div>
            <div class="kta-field">
              <span class="kta-label">Alamat:</span>
              <span class="kta-value">{{ form.address || 'KOSONG!' }}</span>
            </div>
          </div>
        </div>

        <div class="kta-footer">
          <div class="kta-qr">
            <div class="kta-qr-placeholder">
              <span>QR Code</span>
            </div>
          </div>

          <div class="kta-signature">
            <p></p>
            <div class="kta-sign-placeholder"></div>
            <p>Ketua Umum</p>
          </div>
        </div>
      </div>
    </div>

    <!-- <div class="form-group form-checkbox">
      <input
        type="checkbox"
        :checked="form.isConfirmed"
        @change="updateConfirmation($event)"
        id="isConfirmed"
        required
      />
      <label for="isConfirmed">Saya menyatakan data di atas benar</label>
    </div> -->

    <div class="kta-actions">
      <!-- <BaseButton>Download KTA</BaseButton> -->
      <button type="button" class="btn btn-blue" @click="downloadKta" :disabled="!form.isConfirmed">
        <i class="fas fa-download"></i> Download KTA
      </button>
      <button type="button" class="btn btn-green" @click="printKta">
        <i class="fas fa-print"></i> Cetak KTA
      </button>
    </div>

    <!-- Navigation -->
    <div class="step-navigation">
      <!-- Tombol Edit -->
      <button type="button" class="btn btn-blue" @click="handleEdit" :disabled="!form.id">
        🖊️ Edit Data
      </button>

      <!-- Tombol Tambah Anggota Baru -->
      <button type="button" class="btn btn-green" @click="handleAddNew">
        ➕ Tambah Anggota Baru
      </button>

      <!-- Tombol Selesai -->
      <button type="button" class="btn btn-primary" @click="handleFinish">
        ✅ Selesai
      </button>
    </div>
  </div>
</template>
<style scoped>
.step-navigation {
  margin-top: 30px;
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 140px;
}

.btn-blue {
  background-color: #3498db;
  color: white;
}

.btn-blue:hover {
  background-color: #2980b9;
}

.btn-green {
  background-color: #27ae60;
  color: white;
}

.btn-green:hover {
  background-color: #219955;
}

.btn-primary {
  background-color: #6c63ff;
  color: white;
}

.btn-primary:hover {
  background-color: #5a57e0;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

h3 {
  margin-bottom: 20px;
  color: var(--primary);
}

.kta-preview {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

.kta-card {
  width: 340px;
  height: 220px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 15px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #ddd;
}

.kta-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  border-bottom: 1px solid #eee;
  padding-bottom: 8px;
}

.kta-logo {
  width: 40px;
  height: 40px;
  margin-right: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.kta-logo img {
  max-width: 100%;
  max-height: 100%;
}

.kta-title h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 700;
  color: var(--primary);
}

.kta-title h5 {
  margin: 2px 0 0;
  font-size: 12px;
  font-weight: 600;
}

.kta-body {
  display: flex;
  flex-grow: 1;
}

.kta-photo {
  width: 80px;
  padding-right: 10px;
}

.kta-photo-placeholder {
  width: 70px;
  height: 90px;
  background: #f5f5f5;
  border: 1px dashed #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  color: #888;
}

.kta-data {
  flex-grow: 1;
}

.kta-field {
  margin-bottom: 5px;
  font-size: 11px;
  display: flex;
}

.kta-label {
  width: 60px;
  font-weight: 600;
}

.kta-value {
  flex-grow: 1;
}

.kta-footer {
  display: flex;
  margin-top: 10px;
  border-top: 1px solid #eee;
  padding-top: 8px;
}

.kta-qr {
  width: 50px;
}

.kta-qr-placeholder {
  width: 40px;
  height: 40px;
  background: #f5f5f5;
  border: 1px dashed #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 8px;
  color: #888;
}

.kta-signature {
  flex-grow: 1;
  text-align: center;
  font-size: 9px;
}

.kta-sign-placeholder {
  height: 20px;
  margin: 2px 0;
}

.kta-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin: 20px 0;
}

.step-navigation {
  margin-top: 24px;
  display: flex;
  justify-content: space-between;
}
</style>
