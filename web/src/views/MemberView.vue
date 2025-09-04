<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import BaseTable from "@/components/common/BaseTable.vue";
import BaseTableFilter from "@/components/common/BaseTableFilter.vue";
import BaseButton from "@/components/common/BaseButton.vue";
import MemberService from "@/services/member.service";
// import RegionService from "@/services/region.service";
// import MemberCard from "@/components/member/MemberCard.vue";

const router = useRouter();
const members = ref([]);
const loading = ref(false);
// const members = ref([
//   {
//     id: 1,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
//   {
//     id: 2,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
//   {
//     id: 2,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
//   {
//     id: 2,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
//   {
//     id: 2,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
//   {
//     id: 2,
//     name: "Budi Santoso",
//     gender: "Laki-laki",
//     provinsi: "Jawa Tengah",
//     kota: "Semarang",
//     kecamatan: "Candisari",
//     desa: "Tembalang",
//   },
// ]);

const columns = [
  { key: "name", label: "Nama" },
  { key: "gender", label: "Gender" },
  { key: "province.name", label: "Provinsi" },
  { key: "city.name", label: "Kota/Kabupaten" },
  { key: "district.name", label: "Kecamatan" },
];
// const columns = [
//   { key: "name", label: "Nama" },
//   { key: "gender", label: "Gender" },
//   { key: "provinsi", label: "Provinsi" },
//   { key: "kota", label: "Kota/Kabupaten" },
//   { key: "kecamatan", label: "Kecamatan" },
// ];

const search = ref("");
const provinsi = ref("");
const kota = ref("");
const kecamatan = ref("");
const desa = ref("");

// const filteredMembers = computed(() => {
//   return members.value.filter((m) =>
//     m.name.toLowerCase().includes(search.value.toLowerCase())
//   );
// });

const filteredMembers = computed(() => {
  return members.value.filter((m) => {
    const matchSearch =
      !search.value ||
      m.name.toLowerCase().includes(search.value.toLowerCase());
    const matchProvinsi = !provinsi.value || m.provinsiCode === provinsi.value;
    const matchKota = !kota.value || m.kotaCode === kota.value;
    const matchKecamatan =
      !kecamatan.value || m.kecamatanCode === kecamatan.value;
    const matchDesa = !desa.value || m.desaCode === desa.value;

    return (
      matchSearch && matchProvinsi && matchKota && matchKecamatan && matchDesa
    );
  });
});

const handleAddMember = () => {
  router.push({ name: "AddMember" });
};

const fetchMembers = async () => {
  loading.value = true;
  try {
    const data = await MemberService.getMembers({ page: 1, limit: 10 });
    console.log(data);
    members.value = data.data;
  } catch (err) {
    console.error("Gagal ambil data member:", err);
  } finally {
    loading.value = false;
  }
};

function resetFilter() {
  search.value = "";
  provinsi.value = "";
  kota.value = "";
  kecamatan.value = "";
  desa.value = "";
}

function handleDetail(member) {
  alert(`Detail ${member.name}`);
}
function handleEdit(member) {
  alert(`Edit ${member.name}`);
}
function handleDelete(member) {
  if (confirm(`Hapus ${member.name}?`)) {
    members.value = members.value.filter((m) => m.id !== member.id);
  }
}

onMounted(() => {
  fetchMembers();
});
</script>

<template>
  <div class="container">
    <div class="header">
      <h2></h2>
      <!-- <button class="add-button">+ Tambah Anggota</button> -->
      <BaseButton icon-start="fa fa-plus" @click="handleAddMember"
        ><p class="add-button">Tambah Anggota</p></BaseButton
      >
    </div>

    <!-- <div class="filters">
      <input type="text" v-model="search" placeholder="Cari anggota..." />
      <select v-model="provinsi">
        <option>Provinsi</option>
 
      </select>
      <select v-model="kota">
        <option>Kota/Kabupaten</option>
        
      </select>
      <select v-model="kecamatan">
        <option>Kecamatan</option>
       
      </select>
      <select v-model="desa">
        <option>Desa/Kelurahan</option>
        
      </select>
      <button @click="resetFilter" class="reset-button">Reset</button>
    </div> -->

    <BaseTableFilter
      v-model:search="search"
      v-model:provinsi="provinsi"
      v-model:kota="kota"
      v-model:kecamatan="kecamatan"
      v-model:desa="desa"
      @reset="resetFilter"
    />

    <BaseTable
      :columns="columns"
      :items="filteredMembers"
      :rows-per-page="8"
      :loading="isLoading"
      :on-detail="false"
      :on-edit="true"
      :on-delete="true"
      @detail="handleDetail"
      @edit="handleEdit"
      @delete="handleDelete"
    />

    <!-- <MemberCard
      v-for="member in filteredMembers"
      :key="member.id"
      :member="member"
      @detail="handleDetail"
      @edit="handleEdit"
      @delete="handleDelete"
    /> -->
  </div>
</template>

<style scoped>
.container {
  /* max-width: 800px; */
  margin: 0 auto;
  /* padding: 6px; */
  /* padding: 24px; */
  background: #f9f9ff;
  border-radius: 16px;
  height: 100vh;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  font-size: 22px;
  font-weight: bold;
  color: #333;
}

.add-button {
  /* background: #5a4fcf; */
  /* color: white; */
  /* border: none; */
  /* padding: 10px 16px; */
  /* border-radius: 20px; */
  cursor: pointer;
  font-size: small;
  font-weight: 500;
  font-family: "Plus Jakarta Sans", sans-serif;
}

.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 20px;
}

.filters input,
.filters select {
  padding: 8px 12px;
  border-radius: 12px;
  border: 1px solid #ccc;
  font-size: 14px;
}

.reset-button {
  background: #eee;
  border: none;
  padding: 8px 12px;
  border-radius: 12px;
  font-size: 13px;
  cursor: pointer;
}
</style>

<!-- <script setup>
import MemberListView from "./MemberListView.vue";
</script>
<template><MemberListView /></template> -->
<!-- <script setup>
import { ref } from "vue";
import BaseTable from "@/components/common/BaseTable.vue";

const columns = [
  { label: "Nama", key: "nama" },
  { label: "Provinsi", key: "provinsi" },
  { label: "Kota", key: "kota" },
  { label: "Kecamatan", key: "kecamatan" },
  { label: "Kelurahan", key: "kelurahan" },
  { label: "Status", key: "status", badge: true },
];

const members = ref([
  {
    id: 1,
    nama: "Andi Saputra",
    provinsi: "Jawa Barat",
    kota: "Bandung",
    kecamatan: "Coblong",
    kelurahan: "Dago",
    status: "All Asset",
  },
  {
    id: 2,
    nama: "Budi Santoso",
    provinsi: "DKI Jakarta",
    kota: "Jakarta Selatan",
    kecamatan: "Kebayoran Baru",
    kelurahan: "Senayan",
    status: "Subscription Asset",
  },
  {
    id: 3,
    nama: "Citra Dewi",
    provinsi: "Jawa Timur",
    kota: "Surabaya",
    kecamatan: "Wonokromo",
    kelurahan: "Darmo",
    status: "Legality Asset",
  },
]);

const selectedMembers = ref([]);

function handleSelectionChange(data) {
  selectedMembers.value = data;
}

function handleView(member) {
  alert(`Lihat data: ${member.nama}`);
}

function handleEdit(member) {
  alert(`Edit data: ${member.nama}`);
}

function handleDelete(member) {
  if (confirm(`Yakin ingin menghapus ${member.nama}?`)) {
    members.value = members.value.filter((m) => m.id !== member.id);
  }
}

function handleBulkDelete() {
  if (selectedMembers.value.length === 0) {
    alert("Tidak ada data yang dipilih.");
    return;
  }

  const confirmDelete = confirm(
    `Hapus ${selectedMembers.value.length} data terpilih?`
  );
  if (confirmDelete) {
    const idsToDelete = selectedMembers.value.map((m) => m.id);
    members.value = members.value.filter((m) => !idsToDelete.includes(m.id));
    selectedMembers.value = [];
  }
}
</script>

<template>
  <div class="member-view">
    <h2>Daftar Anggota</h2>

    <div class="toolbar">
      <button
        @click="handleBulkDelete"
        :disabled="selectedMembers.length === 0"
      >
        🗑 Hapus Terpilih ({{ selectedMembers.length }})
      </button>
    </div>

    <BaseTable
      :columns="columns"
      :data="members"
      :pageSize="5"
      @view="handleView"
      @edit="handleEdit"
      @delete="handleDelete"
      @selection-change="handleSelectionChange"
    />
  </div>
</template>

<style scoped>
.member-view {
  padding: 20px;
  font-family: Arial, sans-serif;
}

h2 {
  margin-bottom: 12px;
}

.toolbar {
  margin-bottom: 10px;
}

button {
  padding: 8px 14px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}
</style> -->
