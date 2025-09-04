<script setup>
import { ref, computed } from "vue";
// import BaseInput from "./BaseInput.vue";

const props = defineProps({
  modelValue: [Object, String, Number],
  options: {
    type: Array,
    required: true,
  },
  label: {
    type: String,
    default: "item",
  },
  valueKey: {
    type: String,
    default: "id",
  },
  labelKey: {
    type: String,
    default: "name",
  },
});

const emit = defineEmits(["update:modelValue"]);

const open = ref(false);
const search = ref("");
const wrapper = ref(null);

// Toggle dropdown
const toggleDropdown = () => (open.value = !open.value);

// Current selected option
const selectedOption = computed(() => {
  return props.options.find((opt) =>
    typeof props.modelValue === "object"
      ? opt[props.valueKey] === props.modelValue?.[props.valueKey]
      : opt[props.valueKey] === props.modelValue
  );
});

// Search filter
const filteredOptions = computed(() =>
  props.options.filter((item) =>
    item[props.labelKey].toLowerCase().includes(search.value.toLowerCase())
  )
);

// Select item
function selectItem(item) {
  emit("update:modelValue", item);
  open.value = false;
}

// Close dropdown when clicked outside
document.addEventListener("click", (e) => {
  if (!wrapper.value?.contains(e.target)) open.value = false;
});
</script>

<template>
  <div class="select-wrapper" ref="wrapper">
    <div class="selected" @click="toggleDropdown">
      <template v-if="selectedOption">
        <img
          v-if="selectedOption.flag"
          :src="selectedOption.flag"
          class="flag"
        />
        <span>{{ selectedOption[labelKey] }}</span>
      </template>
      <!-- <span class="arrow">&#9662;</span> -->
      <span class="arrow">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="20"
          height="20"
          viewBox="0 0 24 24"
        >
          <path
            fill="none"
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M18 9s-4.419 6-6 6s-6-6-6-6"
          />
        </svg>
      </span>
    </div>

    <div v-if="open" class="dropdown">
      <input
        type="text"
        v-model="search"
        :placeholder="`Cari ${label}...`"
        class="search"
      />
      <hr />

      <ul class="option-list">
        <li
          v-for="item in filteredOptions"
          :key="item[valueKey]"
          @click="selectItem(item)"
          class="option"
        >
          <img v-if="item.flag" :src="item.flag" class="flag" />
          {{ item[labelKey] }}
        </li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.select-wrapper {
  position: relative;
  /* width: 100%;
  max-width: 300px; */
  flex: 1 1 180px;
  font-family: "Plus Jakarta Sans", sans-serif;
}

.selected {
  border: 1px solid #ccc;
  border-radius: 10px;
  /* padding: 8px 12px; */
  padding: 0.6rem 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  background-color: #fff;
}

.selected .flag {
  width: 20px;
  margin-right: 8px;
}
.selected span {
  font-size: 1rem;
}

.arrow {
  margin-left: auto;
  margin-right: -10px;
  font-size: 12px;
  color: #666;
}

.dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  margin-top: 7px;
  padding: 10px;
  background: #fff;
  z-index: 1000;
  border: 1px solid #ccc;
  /* border-top: none; */
  /* border-radius: 0 0 8px 8px; */
  border-radius: 8px;
  max-height: 250px;
  overflow: auto;
}

.search {
  width: 100%;
  padding: 8px 12px;
  /* border-bottom: 1px solid #eee; */
  border-radius: 5px;
  border: 1px solid #ccc;
  box-sizing: border-box;
  font-family: "Plus Jakarta Sans", sans-serif;
}

.dropdown hr {
  margin: 0.5rem 0;
  border: none;
  border-bottom: 0.5px solid #ccc;
}

.option-list {
  list-style: none;
  margin: 0;
  padding: 0;
  /* max-height: 200px; 
  overflow-y: auto;  */
  /* display: flex;  */
  /* overflow-y: auto;
  white-space: nowrap;
  gap: 0.5rem;
  padding: 0.5rem; */
}

/* .option {
  display: inline-flex;
  align-items: center;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background: #f7f7f7;
  cursor: pointer;
  flex-shrink: 0;
  font-size: small;
} */
.option {
  padding: 8px 12px;
  display: flex;
  align-items: center;
  cursor: pointer;
  font-size: small;
}

.option .flag {
  width: 20px;
  margin-right: 8px;
}

.option:hover {
  background-color: #f0f0f0;
  border-radius: 5px;
}
</style>
