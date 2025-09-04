<template>
  <!-- <h2>Form Anggota Baru</h2> -->
  <form class="form-container" @submit.prevent="handleSubmit">
    <div class="form-group" v-for="field in fields" :key="field.model">
      <!-- <label :for="field.model">{{ field.label }}</label> -->
      <!-- <input
        :id="field.model"
        v-model="localMember[field.model]"
        :placeholder="field.placeholder"
        class="form-input"
      /> -->
      <BaseInput
        :label="field.label"
        v-model="localMember[field.model]"
        :type="field.type"
        :placeholder="field.placeholder"
        required
      />
    </div>
    <button class="submit-button">💾 Simpan</button>
  </form>
</template>
<script setup>
import { reactive, watch } from "vue";
import BaseInput from "../common/BaseInput.vue";
const props = defineProps({
  member: Object,
  fields: Array,
});

const localMember = reactive({ ...props.member });
const emit = defineEmits([]);

watch(
  () => props.member,
  (newVal) => {
    Object.assign(localMember, newVal);
  },
  { deep: true }
);

const handleSubmit = () => {
  emit("submit", localMember);
};

// const fields = [
//   { model: "nik", label: "NIK", placeholder: "Nomor Induk Kependudukan" },
//   { model: "name", label: "Nama Lengkap", placeholder: "Nama sesuai KTP" },
//   { model: "dob", label: "Tanggal Lahir", placeholder: "DD-MM-YYYY" },
//   { model: "gender", label: "Jenis Kelamin", placeholder: "L/P" },
//   { model: "address", label: "Alamat", placeholder: "Alamat lengkap" },
// ];
</script>
<style scoped>
.form-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-input {
  margin-top: 10px;
  padding: 0.75rem 1rem;
  border: 1px solid #ccc;
  border-radius: 12px;
  font-size: 1rem;
  font-family: "Plus Jakarta Sans", sans-serif;
}

.submit-button {
  padding: 0.8rem;
  background-color: #6c5ce7;
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: bold;
}
</style>
