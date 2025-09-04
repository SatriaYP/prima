<script setup>
import { ref } from "vue";
const props = defineProps({
  title: String,
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

const triggerFileInput = () => fileInput.value?.click();

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
  <div class="upload-section">
    <h3>{{ props.title }}</h3>
    <div class="upload-area" @click="triggerFileInput">
      <input type="file" ref="fileInput" @change="handleFileUpload" hidden />
      <div class="upload-placeholder">
        <!-- <img src="/upload-icon.svg" alt="Upload Icon" class="upload-icon" /> -->
        <span class="upload-icon">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="35"
            height="35"
            viewBox="0 0 24 24"
          >
            <g
              fill="none"
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
            >
              <path
                d="M5 21c4.21-4.751 8.941-11.052 16-6.327M17 4.5c.491-.506 1.8-2.5 2.5-2.5M22 4.5c-.491-.506-1.8-2.5-2.5-2.5m0 0v8"
              />
              <path
                d="M21 13c-.002 4.147-.053 6.27-1.391 7.609C18.217 22 15.979 22 11.5 22c-4.478 0-6.718 0-8.109-1.391S2 16.979 2 12.5c0-4.478 0-6.718 1.391-8.109S7.021 3 11.5 3H14"
              />
            </g>
          </svg>
        </span>
        <p class="upload-text">Upload a KTP scan</p>
        <p class="upload-subtext">Max size: 5 MB | Format: JPG, PNG</p>
      </div>
    </div>

    <div v-if="selectedFile" class="upload-status">
      <div class="file-info">
        <span class="file-icon">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
          >
            <g
              fill="none"
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
            >
              <circle cx="7.5" cy="7.5" r="1.5" />
              <path
                d="M2.5 12c0-4.478 0-6.718 1.391-8.109S7.521 2.5 12 2.5c4.478 0 6.718 0 8.109 1.391S21.5 7.521 21.5 12c0 4.478 0 6.718-1.391 8.109S16.479 21.5 12 21.5c-4.478 0-6.718 0-8.109-1.391S2.5 16.479 2.5 12"
              />
              <path d="M5 21c4.372-5.225 9.274-12.116 16.498-7.458" />
            </g>
          </svg>
        </span>
        <!-- <img src="/file-icon.svg" alt="File" class="file-icon" /> -->
        <div>
          <p class="file-name">{{ selectedFile.name }}</p>
          <p class="file-size">
            {{ (selectedFile.size / 1024 / 1024).toFixed(2) }} MB
          </p>
        </div>
        <button class="close-btn" @click="resetUpload">✖</button>
      </div>

      <div class="progress-container" v-if="uploadProgress < 100 && uploading">
        <div
          class="progress-bar"
          :style="{ width: uploadProgress + '%' }"
        ></div>
      </div>
    </div>
  </div>

  <!-- Section Preview Foto -->
  <!-- <div v-if="ocrResult.image" class="preview-section">
    <h3>Preview KTP</h3>
    <img :src="ocrResult.image" alt="Preview KTP" class="ktp-image" />
  </div> -->
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
</style>
