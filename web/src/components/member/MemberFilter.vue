<template>
  <div class="filter-wrapper">
    <input
      type="text"
      placeholder="Cari nama..."
      :value="search"
      @input="updateSearch($event.target.value)"
    />

    <select :value="province" @change="updateProvince($event.target.value)">
      <option value="">Semua Provinsi</option>
      <option>Jawa Barat</option>
      <option>Jawa Tengah</option>
    </select>

    <select :value="city" @change="updateCity($event.target.value)">
      <option value="">Semua Kota</option>
      <option>Bandung</option>
      <option>Semarang</option>
    </select>

    <select :value="district" @change="updateDistrict($event.target.value)">
      <option value="">Semua Kecamatan</option>
      <option>Cicendo</option>
      <option>Tembalang</option>
    </select>
  </div>
</template>

<script setup>
import { computed } from "vue";
const props = defineProps({
  modelValueSearch: String,
  modelValueProvince: String,
  modelValueCity: String,
  modelValueDistrict: String,
});

const emit = defineEmits([
  "update:modelValueSearch",
  "update:modelValueProvince",
  "update:modelValueCity",
  "update:modelValueDistrict",
]);

const search = computed(() => props.modelValueSearch);
const province = computed(() => props.modelValueProvince);
const city = computed(() => props.modelValueCity);
const district = computed(() => props.modelValueDistrict);

function updateSearch(value) {
  emit("update:modelValueSearch", value);
}

function updateProvince(value) {
  emit("update:modelValueProvince", value);
}

function updateCity(value) {
  emit("update:modelValueCity", value);
}

function updateDistrict(value) {
  emit("update:modelValueDistrict", value);
}
</script>

<style scoped>
.filter-wrapper {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}

.filter-wrapper input,
.filter-wrapper select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 6px;
  min-width: 160px;
}
</style>
