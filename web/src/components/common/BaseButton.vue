<script setup>
import { computed } from "vue";
const props = defineProps({
  type: {
    type: String,
    default: "button",
  },
  disabled: Boolean,
  loading: Boolean,
  iconStart: String,
  icon: String, // e.g. 'fas fa-check'
  color: {
    type: String,
    default: "primary",
  },
  size: {
    type: String,
    default: "medium", // small | medium | large
  },
});

const colorClass = computed(() => {
  switch (props.color) {
    case "primary":
      return "btn-primary";
    case "secondary":
      return "btn-secondary";
    case "danger":
      return "btn-danger";
    case "gray":
      return "btn-gray";
    default:
      return "btn-primary";
  }
});

const sizeClass = computed(() => {
  switch (props.size) {
    case "small":
      return "btn-sm";
    case "large":
      return "btn-lg";
    default:
      return "btn-md";
  }
});
</script>

<template>
  <button
    class="base-button"
    :class="[colorClass, sizeClass]"
    :type="props.type"
    :disabled="disabled || loading"
    @click="$emit('click')"
  >
    <span v-if="props.loading" class="spinner" />
    <i
      v-if="props.iconStart && !props.loading"
      :class="props.iconStart"
      class="button-icon"
    />
    <slot />
    <i
      v-if="props.icon && !props.loading"
      :class="props.icon"
      class="button-icon"
    />
  </button>
</template>

<style scoped>
.base-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  /* padding: 0.8rem 1rem; */
  padding: 8px 16px;
  /* background-color: #6c63ff;
  color: white; */
  border: none;
  border-radius: 10px;
  /* font-weight: 500; */
  /* font-size: 1rem; */
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  font-family: "Plus Jakarta Sans", sans-serif;
}

/* ===== Size Variants ===== */
.btn-sm {
  padding: 0.4rem 0.6rem;
  font-size: 0.8rem;
}

.btn-md {
  padding: 0.5rem 1rem;
  font-size: 1rem;
}

.btn-lg {
  padding: 1rem 1.4rem;
  font-size: 1.2rem;
}

.btn-sm .button-icon {
  font-size: 0.8rem;
}

.btn-lg .button-icon {
  font-size: 1.2rem;
}

/* Color Variants */
.btn-primary {
  background-color: #6c63ff;
  color: white;
}

.btn-primary:hover:enabled {
  background-color: #5548e0;
}

.btn-secondary {
  background-color: white;
  color: #6c63ff;
  border: 2px solid #6c63ff;
}

.btn-secondary:hover:enabled {
  background-color: #f0eeff;
}

.btn-danger {
  background-color: #e63946;
  color: white;
}

.btn-danger:hover:enabled {
  background-color: #c5303d;
}

.btn-gray {
  background-color: #ccc;
  color: black;
}

.btn-gray:hover:enabled {
  background-color: #aaa !important;
}

.base-button:hover:enabled {
  background-color: #5548e0;
}

.base-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.button-icon {
  font-size: 1rem;
}

.spinner {
  width: 1rem;
  height: 1rem;
  border: 2px solid #fff;
  border-top: 2px solid transparent;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
