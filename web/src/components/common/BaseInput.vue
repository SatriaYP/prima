<script setup>
import { computed, useAttrs } from "vue";

defineOptions({ inheritAttrs: false });

const props = defineProps({
  modelValue: String,
  label: String,
  type: {
    type: String,
    default: "text",
  },
  placeholder: String,
  required: {
    type: Boolean,
    default: false,
  },
  error: String,
  icon: String,
});

const emit = defineEmits(["update:modelValue"]);
const attrs = useAttrs(); // ambil atribut dari parent

const localValue = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val),
});

// Pisahkan attrs agar bisa ditaruh ke <input>
const inputAttrs = computed(() => {
  const { class: cls, style, ...rest } = attrs;
  return { ...rest, class: cls, style };
});
</script>

<template>
  <div class="base-input" :class="{ 'has-error': error }">
    <label v-if="label">{{ label }}</label>
    <div class="input-wrapper">
      <input
        v-bind="inputAttrs"
        :type="type"
        :placeholder="placeholder"
        v-model="localValue"
        :required="required"
        class="base-input-field"
      />
      <span v-if="icon" class="input-icon">
        <i :class="icon" />
      </span>
    </div>
    <small v-if="error" class="error-msg">{{ error }}</small>
  </div>
</template>

<style scoped>
.base-input {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.input-wrapper {
  position: relative;
}

.base-input-field {
  width: 100%;
  padding: 0.7rem 1rem;
  /* padding-left: 2.8rem; */
  border: 1px solid #ccc;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s;
  font-family: "Plus Jakarta Sans", sans-serif;
}

.input-icon {
  position: absolute;
  right: 0.8rem;
  /* left: 0.8rem; */
  top: 50%;
  transform: translateY(-50%);
  color: #999;
}

.base-input.has-error input {
  border-color: #e74c3c;
}

.error-msg {
  color: #e74c3c;
  font-size: 0.85rem;
}
/* .base-input input {
  padding: 0.8rem 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  font-size: 1rem;
  width: 100%;
  transition: border-color 0.3s;
} */

/* .base-input input:focus {
  outline: none;
  border-color: #6c63ff;
} */
</style>
