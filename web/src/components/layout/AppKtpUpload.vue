<template>
  <div class="ktp-upload-step">
    <div class="form-group ktp-upload-block">
      <AppFileUpload title="Upload KTP" @upload:files="handleFileUpload" />

      <!-- Preview KTP -->
      <div class="ktp-upload-preview-container">
        <div class="ktp-images-comparison">
          <!-- Slot Original -->
          <div class="ktp-image-container">
            <h4>Foto KTP</h4>
            <template v-if="form.ktpUrl">
              <img :src="form.ktpUrl" alt="Foto KTP" class="ktp-preview" :class="{ zoomed: zoomKtp }"
                @click="toggleZoom" />
            </template>
            <template v-else>
              <div class="ktp-placeholder">Belum ada foto</div>
            </template>
          </div>
        </div>

        <button v-if="form.ktpUrl && !ocrLoading" type="button" class="btn btn-blue" @click="prosesKtpOcr">
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
          <span class="ocr-error-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
              <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M3 12a9 9 0 1 0 18 0a9 9 0 1 0-18 0m9-3v4m0 3v.01" />
            </svg>
          </span>{{ ocrError }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
// import api from "@/services/api.service";
// import MemberService from "@/services/member.service";
import AppFileUpload from "./AppFileUpload.vue";
import api from "@/services/api.service";
const zoomKtp = ref(false);

function toggleZoom() {
  zoomKtp.value = !zoomKtp.value;
}
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


const ocrLoading = ref(false);
const ocrError = ref("");
const ocrResult = ref(null);
// eslint-disable-next-line
const initialForm = {
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
  occupation: "LAINNYA",
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
};
// Fungsi Upload File
// const handleFileUpload = (file) => {
//   if (!file) {
//     emit("update:form", { ...initialForm }); // ✅ AMAN — TIDAK MUTASI PROP!
//     return;
//   }
//   // eslint-disable-next-line
//   emit("update:form", {
//     ...props.form,
//     // eslint-disable-next-line
//     ktpUrl: URL.createObjectURL(file),
//     ktpProcessedUrl: "", // reset processed URL saat upload baru
//   });
// };
const handleFileUpload = async (file) => {
  if (!file) {
    emit("update:form", {
      ...props.form,
      ktpUrl: null,
      ktpProcessedUrl: "",
    });
    return;
  }

  const allowedTypes = ["image/jpeg", "image/jpg", "image/png"];
  if (!allowedTypes.includes(file.type)) {
    alert("Format file hanya boleh JPG atau PNG.");
    return;
  }

  const ktpUrl = URL.createObjectURL(file);
  let processedUrl = "";

  try {
    processedUrl = await autoCropKtp(file);
  } catch (err) {
    console.error("Crop gagal:", err);
  }

  emit("update:form", {
    ...props.form,
    ktpUrl,
    ktpProcessedUrl: processedUrl || "",
  });
};
// Proses OCR (tetap seperti semula)
// async function prosesKtpOcr() {
//   if (!props.form.ktpUrl) return;

//   ocrLoading.value = true;
//   ocrError.value = "";
//   ocrResult.value = null;

//   try {
//     // Ambil file dari URL (convert dari blob ke File)
//     const response = await fetch(props.form.ktpUrl);
//     const blob = await response.blob();
//     const file = new File([blob], "ktp.jpg", { type: "image/jpeg" });

//     const formData = new FormData();
//     formData.append("image", file);

//     // 👇 INI YANG PENTING — ENDPOINT BARU DI MODUL MEMBER
//     // const res = await api.post("/members/crop-ktp", formData, {
//     //   headers: {
//     //     "Content-Type": "multipart/form-data",
//     //   },
//     // });
//     const res = await api.post("/members/crop-ktp", formData);
//     if (res.data.success && res.data.processed_image_url) {
//       emit("update:form", {
//         ...props.form,
//         ktpProcessedUrl: res.data.processed_image_url, // 👈 UPDATE FORM DENGAN GAMBAR CROP
//       });

//       ocrResult.value = JSON.stringify(res.data, null, 2);
//     } else {
//       throw new Error("Respon tidak valid");
//     }
//   } catch (err) {
//     console.error("Error cropping KTP:", err);
//     if (err.response?.status === 400) {
//       ocrError.value = "Gambar tidak jelas. Pastikan KTP terlihat utuh.";
//     } else if (err.response?.status === 500) {
//       ocrError.value = "Gagal memproses KTP. Silakan coba lagi.";
//     } else {
//       ocrError.value =
//         err.response?.data?.message ||
//         "Gagal memproses KTP. Pastikan gambar jelas dan tidak blur.";
//     }
//   } finally {
//     ocrLoading.value = false;
//   }
// }
async function ensureOpenCv() {
  return new Promise((resolve, reject) => {
    if (window.cv && window.cv.Mat) return resolve(window.cv);
    let tries = 0;
    const t = setInterval(() => {
      tries++;
      if (window.cv && window.cv.Mat) {
        clearInterval(t);
        resolve(window.cv);
      }
      if (tries > 40) {
        clearInterval(t);
        reject(new Error("OpenCV.js gagal load"));
      }
    }, 100);
  });
}

async function autoCropKtp(file) {
  const cv = await ensureOpenCv();

  // Convert File → Image
  const imgUrl = URL.createObjectURL(file);
  const img = await new Promise((res) => {
    const i = new Image();
    i.onload = () => res(i);
    i.src = imgUrl;
  });
  const tempCanvas = document.createElement("canvas");
  tempCanvas.width = img.width;
  tempCanvas.height = img.height;
  const ctx = tempCanvas.getContext("2d");
  ctx.drawImage(img, 0, 0);

  // OpenCV Mat
  let src = cv.imread(tempCanvas);
  const orig = src.clone();

  // Resize untuk performance
  const maxDim = 800;
  let scale = 1;
  if (src.cols > maxDim || src.rows > maxDim) {
    scale = Math.max(src.cols / maxDim, src.rows / maxDim);
    const dsize = new cv.Size(
      Math.round(src.cols / scale),
      Math.round(src.rows / scale)
    );
    cv.resize(src, src, dsize, 0, 0, cv.INTER_AREA);
  }

  // Preprocessing
  let gray = new cv.Mat();
  cv.cvtColor(src, gray, cv.COLOR_RGBA2GRAY, 0);
  cv.GaussianBlur(gray, gray, new cv.Size(5, 5), 0);

  let edged = new cv.Mat();
  cv.Canny(gray, edged, 50, 150);
  let kernel = cv.getStructuringElement(cv.MORPH_RECT, new cv.Size(5, 5));
  cv.dilate(edged, edged, kernel);

  // Cari kontur terbesar (4 sisi)
  let contours = new cv.MatVector();
  let hierarchy = new cv.Mat();
  cv.findContours(
    edged,
    contours,
    hierarchy,
    cv.RETR_LIST,
    cv.CHAIN_APPROX_SIMPLE
  );

  let biggestQuad = null;
  let maxArea = 0;
  for (let i = 0; i < contours.size(); i++) {
    const cnt = contours.get(i);
    const peri = cv.arcLength(cnt, true);
    const approx = new cv.Mat();
    cv.approxPolyDP(cnt, approx, 0.02 * peri, true);
    if (approx.rows === 4) {
      const area = cv.contourArea(approx);
      if (area > maxArea) {
        maxArea = area;
        biggestQuad = approx.clone();
      }
    }
    approx.delete();
    cnt.delete();
  }

  let resultDataUrl = null;
  if (biggestQuad) {
    // Ambil titik
    const pts = [];
    for (let i = 0; i < 4; i++) {
      pts.push({
        x: biggestQuad.intPtr(i, 0)[0] * scale,
        y: biggestQuad.intPtr(i, 0)[1] * scale,
      });
    }

    // Urutkan titik (tl, tr, br, bl)
    // eslint-disable-next-line
    function orderPoints(pts) {
      const rect = [null, null, null, null];
      const sum = pts.map((p) => p.x + p.y);
      const diff = pts.map((p) => p.x - p.y);
      rect[0] = pts[sum.indexOf(Math.min(...sum))]; // tl
      rect[2] = pts[sum.indexOf(Math.max(...sum))]; // br
      rect[1] = pts[diff.indexOf(Math.min(...diff))]; // tr
      rect[3] = pts[diff.indexOf(Math.max(...diff))]; // bl
      return rect;
    }
    const ordered = orderPoints(pts);

    // Hitung ukuran output
    const widthA = Math.hypot(
      ordered[2].x - ordered[3].x,
      ordered[2].y - ordered[3].y
    );
    const widthB = Math.hypot(
      ordered[1].x - ordered[0].x,
      ordered[1].y - ordered[0].y
    );
    const maxWidth = Math.max(Math.round(widthA), Math.round(widthB));

    const heightA = Math.hypot(
      ordered[1].x - ordered[2].x,
      ordered[1].y - ordered[2].y
    );
    const heightB = Math.hypot(
      ordered[0].x - ordered[3].x,
      ordered[0].y - ordered[3].y
    );
    const maxHeight = Math.max(Math.round(heightA), Math.round(heightB));

    // Transformasi perspektif
    const srcMat = cv.matFromArray(4, 1, cv.CV_32FC2, [
      ordered[0].x,
      ordered[0].y,
      ordered[1].x,
      ordered[1].y,
      ordered[2].x,
      ordered[2].y,
      ordered[3].x,
      ordered[3].y,
    ]);
    const dstMat = cv.matFromArray(4, 1, cv.CV_32FC2, [
      0,
      0,
      maxWidth - 1,
      0,
      maxWidth - 1,
      maxHeight - 1,
      0,
      maxHeight - 1,
    ]);

    const M = cv.getPerspectiveTransform(srcMat, dstMat);
    const fullOrig = cv.imread(img);
    const dst = new cv.Mat();
    const dsize = new cv.Size(maxWidth, maxHeight);
    cv.warpPerspective(
      fullOrig,
      dst,
      M,
      dsize,
      cv.INTER_LINEAR,
      cv.BORDER_CONSTANT,
      new cv.Scalar()
    );

    // Convert ke DataURL
    const canvas = document.createElement("canvas");
    canvas.width = dst.cols;
    canvas.height = dst.rows;
    cv.imshow(canvas, dst);
    resultDataUrl = canvas.toDataURL("image/jpeg");

    // Cleanup
    srcMat.delete();
    dstMat.delete();
    M.delete();
    fullOrig.delete();
    dst.delete();
  }

  // Bersihkan memory
  src.delete();
  orig.delete();
  gray.delete();
  edged.delete();
  kernel.delete();
  contours.delete();
  hierarchy.delete();
  if (biggestQuad) biggestQuad.delete();

  return resultDataUrl;
}
async function prosesKtpOcr() {
  const member = members.value[currentMemberIndex.value];
  if (!member.ktpFile) {
    ocrError.value = "Gambar belum diupload.";
    return;
  }

  ocrLoading.value = true;
  ocrError.value = "";
  ocrResult.value = null;

  try {
    const formData = new FormData();
    formData.append("image", member.ktpFile);

    const res = await api.post("/members/crop-ktp", formData);

    if (res.data.success && res.data.processed_image_url) {
      member.ktpProcessedUrl = res.data.processed_image_url;
      member.isProcessed = true;
      ocrResult.value = JSON.stringify(res.data, null, 2);
    } else {
      throw new Error("Respon tidak valid");
    }
  } catch (err) {
    console.error("❌ Error cropping KTP:", err);
    if (err.response?.status === 400) {
      ocrError.value = "Gambar tidak jelas. Pastikan KTP terlihat utuh.";
    } else if (err.response?.status === 500) {
      ocrError.value = "Gagal memproses KTP. Silakan coba lagi.";
    } else {
      ocrError.value =
        err.response?.data?.message ||
        "Gagal memproses KTP. Pastikan gambar jelas dan tidak blur.";
    }
  } finally {
    ocrLoading.value = false;
  }
}
// eslint-disable-next-line
function downloadProcessedImage() {
  if (!props.form.ktpProcessedUrl) return;

  const link = document.createElement("a");
  link.href = props.form.ktpProcessedUrl;
  link.download = `ktp_cropped_${new Date().getTime()}.jpg`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
// function downloadProcessedImage() {
//   if (!props.form.ktpProcessedUrl) return;
//   const a = document.createElement("a");
//   a.href = props.form.ktpProcessedUrl;
//   a.download = "ktp_processed_" + new Date().getTime() + ".jpg";
//   document.body.appendChild(a);
//   a.click();
//   document.body.removeChild(a);
// }
// eslint-disable-next-line
function onImageLoad() {
  console.log("Image loaded successfully:", props.form.ktpProcessedUrl);
}
// eslint-disable-next-line
function onImageError(event) {
  console.error("Image failed to load:", props.form.ktpProcessedUrl);
  ocrError.value = "Gagal memuat gambar hasil proses. Silakan coba lagi.";
}
</script>

<style scoped>
/* gambar normal */
.ktp-preview {
  margin-top: 6px;
  max-width: 280px;
  border-radius: 6px;
  border: 1.5px solid #d0d7e2;
  cursor: zoom-in;
  transition: all 0.3s ease;
}

/* gambar saat zoom (mengisi penuh .upload-column) */
.ktp-preview.zoomed {
  max-width: 100%;
  /* penuh selebar upload-column */
  /* max-height: 100vh; */
  /* biar tidak terlalu panjang */
  cursor: zoom-out;
  object-fit: contain;
  /* supaya proporsi tetap */
}

/* --- SAMA SEPERTI SEBELUMNYA --- */
/* Hanya sisakan styling untuk upload & preview */
.ktp-upload-step {
  display: flex;
  flex-direction: column;
  gap: 20px;
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
  width: 200%;
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

@media (max-width: 700px) {
  .ktp-images-comparison {
    flex-direction: column;
  }

  .ktp-arrow {
    transform: rotate(90deg);
    margin: 10px 0;
  }
}
</style>