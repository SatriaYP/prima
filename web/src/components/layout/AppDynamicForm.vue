<template>
  <form @submit.prevent="submitForm" class="dynamic-form">
    <div v-for="field in fields" :key="field.model" class="form-group">
      <!-- <label :for="field.model">{{ field.label }}</label> -->

      <!-- Input biasa -->
      <!-- <input
        v-if="
          field.type === 'text' ||
          field.type === 'email' ||
          field.type === 'tel' ||
          field.type === 'date'
        "
        :type="field.type"
        :id="field.model"
        :placeholder="field.placeholder"
        v-model="formData[field.model]"
        class="form-input"
      /> -->
      <BaseInput
        v-if="
          field.type === 'text' ||
          field.type === 'email' ||
          field.type === 'tel' ||
          field.type === 'date'
        "
        :label="field.label"
        v-model="formData[field.model]"
        :type="field.type"
        :placeholder="field.placeholder"
        required
      />

      <!-- Select -->
      <BaseSelect
        v-else-if="field.type === 'select'"
        v-model="formData[field.model]"
        :options="field.options"
        label="Provinsi"
      />
      <!-- <select
        v-else-if="field.type === 'select'"
        :id="field.model"
        v-model="formData[field.model]"
        class="form-select"
      >
        <option value="" disabled selected hidden>
          {{ field.placeholder }}
        </option>
        <option
          v-for="option in field.options || []"
          :key="option.value"
          :value="option.value"
        >
          {{ option.label }}
        </option>
      </select> -->

      <!-- Tipe belum didukung -->
      <div v-else class="unsupported">
        Unsupported input type: {{ field.type }}
      </div>
    </div>

    <slot name="footer">
      <!-- <button type="submit" class="submit-button">Submit</button> -->
      <div class="footer">
        <BaseButton color="gray" @click="handleCancel">Cancel </BaseButton>
        <BaseButton type="submit" :loading="loading" color="primary"
          >Create
        </BaseButton>
      </div>
    </slot>
  </form>
</template>

<script setup>
import { reactive, watch, ref } from "vue";
import BaseInput from "../common/BaseInput.vue";
import BaseSelect from "../common/BaseSelect.vue";
import BaseButton from "../common/BaseButton.vue";
import { useRouter } from "vue-router";

const props = defineProps({
  fields: {
    type: Array,
    required: true,
  },
  modelValue: {
    type: Object,
    required: true,
  },
});

const loading = ref(false);
const router = useRouter();

const emit = defineEmits(["update:modelValue", "submit"]);

const formData = reactive({ ...props.modelValue });

// Watch perubahan local dan emit ke parent
watch(
  () => props.modelValue,
  (newVal) => {
    emit("update:modelValue", { ...newVal });
    Object.assign(formData, newVal);
  },
  { deep: true }
);

// Emit saat submit
const submitForm = () => {
  loading.value = true;
  try {
    emit("submit", { ...formData });
  } catch (error) {
    throw new Error("Gagal add member!");
  }
};

const handleCancel = () => {
  router.push({ name: "Member" });
};
</script>

<style scoped>
.dynamic-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-input,
.form-select {
  padding: 0.5rem;
  font-family: "Segoe UI", sans-serif;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.submit-button {
  padding: 0.6rem 1rem;
  background: #007bff;
  color: white;
  font-weight: bold;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.footer {
  display: flex;
  align-items: center;
  justify-content: end;
  gap: 8px;
}

.unsupported {
  color: red;
  font-style: italic;
}
</style>
