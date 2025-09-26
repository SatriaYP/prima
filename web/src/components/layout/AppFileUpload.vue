<script setup>
import { ref } from "vue";
// eslint-disable-next-line
const props = defineProps({
  title: {
    type: String,
    default: "Upload KTP",
  },
});
// const emit = defineEmits(["ocr-finished"]);
const emit = defineEmits(["upload:file"]);

// const file = ref(null);
// const fileInput = ref(null);
// const progress = ref(0);
// const uploading = ref(false);
// const ocr = reactive({
//   image: "",
//   nik: "",
//   name: "",
//   dob: "",
//   gender: "",
//   address: "",
// });

const fileInput = ref(null);

const selectedFile = ref(null);
const uploadProgress = ref(0);
const uploading = ref(false);
// const ocrResult = reactive({
//   image: "",
//   nik: "",
//   name: "",
//   address: "",
//   dob: "",
//   gender: "",
// });

function triggerFileInput() {
  fileInput.value?.click();
}
function onFilesChange(event) {
  const files = Array.from(event.target.files);
  if (files.length === 0) {
    emit("upload:files", []);
    return;
  }

  const validFiles = files.filter(
    (file) => ["image/jpeg", "image/jpg", "image/png"].includes(file.type)
  );

  if (validFiles.length === 0) {
    alert("Format file hanya boleh JPG atau PNG.");
    return;
  }

  emit("upload:files", validFiles); // 👈 KIRIM ARRAY FILE
}
// eslint-disable-next-line
const handleFileUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;
  selectedFile.value = file;
  uploading.value = true;

  // Simulasi upload & OCR
  const fakeProgress = setInterval(() => {
    if (uploadProgress.value < 100) {
      uploadProgress.value += 10;
    } else {
      clearInterval(fakeProgress);
      uploading.value = false;
      // Simulasi hasil OCR dari backend
      // ocrResult.image = URL.createObjectURL(file);
      // ocrResult.nik = "1234567890123456";
      // ocrResult.name = "Hira R";
      // ocrResult.dob = "12-08-1990";
      // ocrResult.gender = "P";
      // ocrResult.address = "Jl. Melati No. 123, Jakarta";

      // emit("ocr-finished", { ...ocrResult });
      emit("upload:file", file);
      // console.log({ ...ocrResult });

      // Isi otomatis form
      //   Object.assign(member, ocrResult);
      uploadProgress.value = 0;
    }
  }, 300);
};
// eslint-disable-next-line
const resetUpload = () => {
  selectedFile.value = null;
  uploadProgress.value = 0;
  uploading.value = false;

  // Hapus hasil OCR
  // Object.keys(ocrResult).forEach((key) => {
  //   ocrResult[key] = "";
  // });

  // emit("ocr-finished", { ...ocrResult });

  // Reset form member
  //   Object.keys(member).forEach((key) => {
  //     member[key] = "";
  //   });
  fileInput.value.value = null;
  emit("upload:file", selectedFile.value);
};
</script>
<template>
  <div class="ktp-upload-block">
    <label class="upload-label" @click="triggerFileInput">
      {{ title }}
    </label>
    <input type="file" accept="image/jpeg,image/png" multiple @change="onFilesChange" style="display: none"
      ref="fileInput" />
  </div>
</template>
<style scoped>
.upload-area {
  border: 2px dashed #ccc;
  border-radius: 12px;
  background-color: #fafafa;
  text-align: center;
  padding: 2rem;
  cursor: pointer;
  transition: background 0.2s;
  height: 150px;
  /* width: 10px; */
}

.upload-area:hover {
  background-color: #f0f0f0;
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #666;
}

.upload-icon {
  width: 40px;
  margin-bottom: 0.5rem;
  animation: bounce 3s infinite;
}

.upload-text {
  font-weight: 500;
  margin-top: 15px;
  margin-bottom: 0.25rem;
}

.upload-subtext {
  font-size: smaller;
  color: #999;
}

.upload-status {
  margin-top: 1rem;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 12px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.file-icon {
  width: 32px;
}

/* .file-icon svg {
  background-color: #4a90e2;
  border-radius: 50%;
  padding: 2rem;
  z-index: 999;
} */

.file-name {
  font-weight: 600;
  font-size: smaller;
}

.file-size {
  font-size: 0.85rem;
  color: #666;
  margin-top: 2px;
}

.close-btn {
  margin-left: auto;
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  color: #888;
}

.progress-container {
  background-color: #e0e0e0;
  height: 3px !important;
  /* border-radius: 4px; */
  border-radius: 999px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background-color: #4a90e2;
  transition: width 0.3s ease-in-out;
  border-radius: 999px;
}

.upload-section h3,
.preview-section h3,
.right-panel h2 {
  margin-bottom: 1rem;
  color: #4a4a4a;
  font-weight: 700;
  font-size: medium;
}

.preview-section {
  margin-top: 2rem;
}

.upload-box {
  display: block;
  padding: 1rem;
  border: 2px dashed #ccc;
  border-radius: 12px;
  text-align: center;
  cursor: pointer;
  background-color: #f3f3fb;
  color: #888;
}

.progress-container {
  margin-top: 1rem;
  background-color: #eee;
  border-radius: 8px;
  overflow: hidden;
  position: relative;
  height: 20px;
}

.progress-bar {
  height: 100%;
  background-color: #8b5cf6;
  transition: width 0.3s;
}

.reset-button {
  margin-top: 1rem;
  background-color: #fceaea;
  color: #d32f2f;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}

.reset-button:hover {
  background-color: #f8d7da;
}

.ktp-image {
  /* margin-top: 1rem; */
  width: 100%;
  border-radius: 12px;
  border: 1px solid #ddd;
}

@keyframes bounce {

  0%,
  100% {
    transform: translateY(0);
  }

  50% {
    transform: translateY(-8px);
  }
}

.upload-label {
  display: block;
  padding: 16px 24px;
  background-color: #f0f0f0;
  border-radius: 8px;
  text-align: center;
  cursor: pointer;
  font-weight: 600;
  color: #333;
  transition: background-color 0.3s;
}

.upload-label:hover {
  background-color: #e0e0e0;
}
</style>
