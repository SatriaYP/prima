<script setup>
import { onMounted, ref, watch } from "vue";
import BaseButton from "./BaseButton.vue";
import BaseSelect from "./BaseSelect.vue";
import BaseInput from "./BaseInput.vue";
import regionService from "@/services/region.service";

const props = defineProps({
  search: String,
  provinsi: String,
  kota: String,
  kecamatan: String,
  desa: String,
});

// const provinsiList = [
//   { id: 1, name: "Jawa Barat" },
//   { id: 2, name: "Jawa Timur" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
//   { id: 3, name: "DKI Jakarta" },
// ];
const provinsiList = ref([]);
const kotaList = ref([]);
const kecamatanList = ref([]);
const desaList = ref([]);

const emits = defineEmits([
  "update:search",
  "update:provinsi",
  "update:kota",
  "update:kecamatan",
  "update:desa",
  "reset",
]);

const localSearch = ref(props.search);
const localProvinsi = ref(props.provinsi);
const localKota = ref(props.kota);
const localKecamatan = ref(props.kecamatan);
const localDesa = ref(props.desa);

watch(localSearch, (val) => emits("update:search", val));
// watch(localProvinsi, (val) => emits("update:provinsi", val));
watch(localProvinsi, async (val) => {
  emits("update:provinsi", val.id);
  localKota.value = "";
  localKecamatan.value = "";
  localDesa.value = "";
  kotaList.value = [];
  kecamatanList.value = [];
  desaList.value = [];

  if (val) {
    const data = await regionService.getCities(val.id);
    kotaList.value = (Array.isArray(data) ? data : []).map((item) => ({
      id: item.code,
      name: item.name,
    }));
  }
});

// watch(localKota, (val) => emits("update:kota", val));
watch(localKota, async (val) => {
  emits("update:kota", val.id);
  localKecamatan.value = "";
  localDesa.value = "";
  kecamatanList.value = [];
  desaList.value = [];

  if (val) {
    const data = await regionService.getDistricts(val.id);
    kecamatanList.value = (Array.isArray(data) ? data : []).map((item) => ({
      id: item.code,
      name: item.name,
    }));
  }
});

// watch(localKecamatan, (val) => emits("update:kecamatan", val));
watch(localKecamatan, async (val) => {
  emits("update:kecamatan", val.id);
  localDesa.value = "";
  desaList.value = [];

  if (val) {
    const data = await regionService.getVillages(val.id);
    desaList.value = (Array.isArray(data) ? data : []).map((item) => ({
      id: item.code,
      name: item.name,
    }));
  }
});

watch(localDesa, (val) => emits("update:desa", val.id));

function reset() {
  localSearch.value = "";
  localProvinsi.value = "";
  localKota.value = "";
  localKecamatan.value = "";
  localDesa.value = "";
  emits("reset");
}
const getProvince = async () => {
  // loading.value = true;
  try {
    const data = await regionService.getProvinces();
    // console.log(data);
    provinsiList.value = (Array.isArray(data) ? data : []).map((item) => ({
      id: item.code,
      name: item.name,
    }));
    // console.log(provinsiList.value);
  } catch (err) {
    console.error("Gagal ambil data member:", err);
  } finally {
    // loading.value = false;
  }
};
onMounted(() => {
  getProvince();
});
</script>
<template>
  <div class="filters">
    <!-- <input type="text" v-model="localSearch" placeholder="Cari anggota..." /> -->
    <BaseInput type="text" v-model="localSearch" placeholder="Cari anggota..." class="search-member" />
    <!-- <select v-model="localProvinsi">
      <option>Provinsi</option>
      Tambahkan opsi provinsi
    </select> -->
    <BaseSelect v-model="localProvinsi" :options="provinsiList" label="Provinsi" />
    <BaseSelect v-model="localKota" :options="kotaList" label="Kota/Kabupaten" />
    <BaseSelect v-model="localKecamatan" :options="kecamatanList" label="Kecamatan" />
    <BaseSelect v-model="localDesa" :options="desaList" label="Desa/Kelurahan" />
    <!-- <select v-model="localKota">
      <option>Kota/Kabupaten</option>
    </select>
    <select v-model="localKecamatan">
      <option>Kecamatan</option>
    </select>
    <select v-model="localDesa">
      <option>Desa/Kelurahan</option>
    </select> -->
    <!-- <button @click="reset" class="reset-button">Reset</button> -->
    <BaseButton @click="reset">
      <p class="reset-button">Reset</p>
    </BaseButton>
  </div>
</template>
<style scoped>
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-bottom: 20px;
}

/* .filters input,
.search-member,
.filters select {
  padding: 8px 12px;
  border-radius: 12px;
  border: 1px solid #ccc;
  font-size: 14px;
  flex: 1 1 180px;
} */

.reset-button {
  /* background: #eee; */
  /* border: none; */
  /* padding: 8px 12px; */
  /* border-radius: 12px; */
  /* font-size: 13px; */
  cursor: pointer;
  font-size: small;
  font-weight: 500;
  font-family: "Plus Jakarta Sans", sans-serif;
}
</style>
