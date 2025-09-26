<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import BaseTable from "@/components/common/BaseTable.vue";
import BaseTableFilter from "@/components/common/BaseTableFilter.vue";
import BaseButton from "@/components/common/BaseButton.vue";
import MemberService from "@/services/member.service";
import { useAlert } from "@/composables/useAlert";
const { showAlert } = useAlert();
const router = useRouter();

// Data state
const members = ref([]);
const loading = ref(false);
const selectedItems = ref([]); // 👈 Untuk multi-select
const currentPage = ref(1);
const totalPages = ref(1);
const itemsPerPage = ref(100);

// Filter
const search = ref("");
const provinsi = ref("");
const kota = ref("");
const kecamatan = ref("");
const desa = ref("");

// Kolom tabel
const columns = [
  { key: "hasilVerminAwal", label: "Hasil Vermin Awal", width: "100px", type: "text", default: " " },
  { key: "hasilVerminPerbaikan", label: "Hasil Vermin Perbaikan", width: "100px", type: "text", default: " " },
  { key: "hasilFaktual", label: "Hasil Faktual", width: "100px" },
  { key: "ktaNumber", label: "No. KTA", width: "100px" },
  { key: "name", label: "Nama", width: "150px" },
  { key: "nik", label: "NIK", width: "140px" },
  { key: "gender", label: "Gender", width: "100px" },
  { key: "province.name", label: "Provinsi", width: "120px" },
  { key: "city.name", label: "Kota/Kabupaten", width: "120px" },
  { key: "district.name", label: "Kecamatan", width: "120px" },
  { key: "pengurus", label: "Pengurus", width: "100px", type: "text", default: " " },
];

// Filtered data dengan pagination
const filteredMembers = computed(() => {
  return members.value.filter((m) => {
    const matchSearch =
      !search.value ||
      m.name.toLowerCase().includes(search.value.toLowerCase()) ||
      m.nik.includes(search.value);
    m.ktaNumber.includes(search.value);
    const matchProvinsi = !provinsi.value || m.provinceCode === provinsi.value;
    const matchKota = !kota.value || m.cityCode === kota.value;
    const matchKecamatan =
      !kecamatan.value || m.districtCode === kecamatan.value;
    const matchDesa = !desa.value || m.villageCode === desa.value;

    return (
      matchSearch && matchProvinsi && matchKota && matchKecamatan && matchDesa
    );
  });
});

const paginatedMembers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return filteredMembers.value.slice(start, end);
});

const totalPagesComputed = computed(() => {
  return Math.ceil(filteredMembers.value.length / itemsPerPage.value);
});

// Fetch Members
const fetchMembers = async () => {
  loading.value = true;
  try {
    const data = await MemberService.getMembers({
      page: currentPage.value,
      limit: itemsPerPage.value,
      search: search.value,
      provinceCode: provinsi.value,
      cityCode: kota.value,
      districtCode: kecamatan.value,
    });
    members.value = data.data;
    totalPages.value = data.totalPages || 1; // Sesuaikan dengan response backend
  } catch (err) {
    console.error("Gagal ambil data member:", err);
    members.value = [];
  } finally {
    loading.value = false;
  }
};
const onItemsPerPageChange = () => {
  currentPage.value = 1; // reset ke halaman 1
  fetchMembers();
};

// Event Handlers
const handleAddMember = () => {
  router.push({ name: "AddMember" });
};

const handleEdit = (member) => {
  router.push({ name: "EditMember", params: { id: member.id } });
};

const handleDelete = async (member) => {
  console.log("🚀 [DELETE] Member data:", member); // 👈 TAMBAHKAN INI!
  if (confirm(`Hapus ${member.name}?`)) {
    loading.value = true;
    try {
      const response = await MemberService.deleteMember(member.id);
      console.log("✅ [DELETE SUCCESS]", response);
      showAlert("Anggota berhasil dihapus.", "success");
      members.value = members.value.filter((m) => m.id !== member.id);
      if (members.value.length === 0 && currentPage.value > 1) {
        currentPage.value = 1;
        fetchMembers();
      }
    } catch (err) {
      console.error("❌ [DELETE FAILED]:", err);
      showAlert("Gagal menghapus anggota. Coba lagi.", "error");
    } finally {
      loading.value = false;
    }
  }
};

const showingInfo = computed(() => {
  const total = filteredMembers.value.length;
  if (total === 0) return "Tidak ada data";

  const start = (currentPage.value - 1) * itemsPerPage.value + 1;
  const end = Math.min(start + itemsPerPage.value - 1, total);

  return `Menampilkan ${start}–${end} dari ${total} anggota`;
});

const handleSelectionChange = (selected) => {
  selectedItems.value = selected;
};

const handleBulkDelete = async () => {
  if (selectedItems.value.length === 0) {
    alert("Tidak ada anggota yang dipilih.");
    return;
  }

  const names = selectedItems.value.map((m) => m.name).join(", ");
  const confirmText = `Hapus ${selectedItems.value.length} anggota:\n${names}\n\nIni akan dihapus dari database secara permanen.`;

  if (!confirm(confirmText)) return;

  loading.value = true;

  try {
    // Hapus satu per satu (karena biasanya API tidak support bulk delete)
    const promises = selectedItems.value.map((member) =>
      MemberService.deleteMember(member.id)
    );

    await Promise.all(promises);

    // Berhasil → hapus dari state
    members.value = members.value.filter(
      (m) => !selectedItems.value.some((sel) => sel.id === m.id)
    );

    // Reset seleksi
    selectedItems.value = [];

    showAlert("Berhasil menghapus anggota.", "success");
  } catch (err) {
    console.error("Gagal menghapus anggota:", err);
    showAlert("Gagal menghapus anggota. Coba lagi.", "error");
  } finally {
    loading.value = false;
  }
};

const resetFilter = () => {
  search.value = "";
  provinsi.value = "";
  kota.value = "";
  kecamatan.value = "";
  desa.value = "";
  currentPage.value = 1; // Reset ke halaman 1 saat filter direset
  fetchMembers();
};

const onPageChange = (page) => {
  currentPage.value = page;
  fetchMembers(); // Load data baru berdasarkan halaman
};

onMounted(() => {
  fetchMembers();
});
</script>

<template>
  <div class="container">
    <div class="header">
      <h2>Daftar Anggota</h2>
      <BaseButton icon-start="fa fa-plus" @click="handleAddMember">
        Tambah Anggota
      </BaseButton>
    </div>
    <!-- Filter -->
    <BaseTableFilter v-model:search="search" v-model:provinsi="provinsi" v-model:kota="kota"
      v-model:kecamatan="kecamatan" v-model:desa="desa" @reset="resetFilter" />
    <!-- Info jumlah item & dropdown per page -->
    <div class="table-footer">
      <div class="table-info">
        {{ showingInfo }}
      </div>
      <div class="per-page">
        <label for="perPage">Tampilkan: </label>
        <select id="perPage" v-model.number="itemsPerPage" @change="onItemsPerPageChange">
          <option :value="10">10</option>
          <option :value="25">25</option>
          <option :value="50">50</option>
          <option :value="100">100</option>
        </select>
        <span>per halaman</span>
      </div>
    </div>
    <!-- Table dengan Multi-Select & Pagination -->
    <BaseTable :columns="columns" :items="paginatedMembers" :rows-per-page="itemsPerPage" :loading="loading"
      :selectable="true" :selected-items="selectedItems" :current-page="currentPage" :total-pages="totalPagesComputed"
      @selection-change="handleSelectionChange" @edit="handleEdit" @delete="handleDelete" @page-change="onPageChange" />
    <!-- Tombol Hapus Massal -->
    <div class="bulk-actions">
      <button type="button" class="btn-delete" :disabled="selectedItems.length === 0" @click="handleBulkDelete">
        🗑️ Hapus Terpilih ({{ selectedItems.length }})
      </button>
    </div>
  </div>
</template>
<style scoped>
.table-footer {
  margin-top: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.per-page {
  display: flex;
  align-items: center;
  gap: 6px;
}

.per-page select {
  padding: 4px 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
  font-size: 14px;
}

.table-info {
  margin-top: 10px;
  font-size: 14px;
  color: #555;
  font-style: italic;
}

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

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
  background: #f9f9ff;
  border-radius: 16px;
  min-height: calc(100vh - 120px);
}


.bulk-actions {
  margin-top: 20px;
  text-align: right;
}

.btn-delete {
  padding: 10px 16px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.btn-delete:disabled {
  background-color: #ccc;
  cursor: not-allowed;
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
