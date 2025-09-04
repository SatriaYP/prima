<template>
  <div class="tingkat-kepengurusan">
    <div class="header-row">
      <h2>Tingkat Kepengurusan</h2>
      <button class="btn btn-green" @click="openForm(null)">
        Tambah Tingkat
      </button>
    </div>
    <div v-if="loading" class="loading">Memuat data...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="levels.length === 0" class="empty">
      Belum ada tingkat kepengurusan
    </div>
    <div v-else>
      <table class="levels-table">
        <thead>
          <tr>
            <th>Nama Tingkat</th>
            <th>Deskripsi</th>
            <th style="width: 110px"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="level in levels" :key="level.id">
            <td>{{ level.name }}</td>
            <td>{{ level.description }}</td>
            <td>
              <button class="btn btn-sm" @click="openForm(level)">Edit</button>
              <button
                class="btn btn-sm btn-red"
                @click="confirmDeleteLevel(level)"
              >
                Hapus
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <TingkatFormDialog
      v-if="showForm"
      :level="selectedLevel"
      @close="closeForm"
      @saved="onLevelSaved"
    />
    <div
      v-if="showDeleteDialog"
      class="dialog-backdrop"
      @click="closeDeleteDialog"
    ></div>
    <div v-if="showDeleteDialog" class="dialog-content dialog-confirm">
      <h4>Konfirmasi Hapus</h4>
      <p>
        Hapus tingkat <b>{{ levelToDelete?.name }}</b
        >?
      </p>
      <div class="dialog-actions">
        <button class="btn" @click="closeDeleteDialog">Batal</button>
        <button class="btn btn-red" @click="deleteLevelConfirmed">Hapus</button>
      </div>
    </div>
    <Snackbar
      :show="snackbar.show"
      :message="snackbar.message"
      :type="snackbar.type"
    />
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import TingkatFormDialog from "./TingkatFormDialog.vue";
import Snackbar from "./Snackbar.vue";
import api from "../services/api";

export default {
  name: "TingkatKepengurusan",
  components: { TingkatFormDialog, Snackbar },
  setup() {
    const levels = ref([]);
    const loading = ref(false);
    const error = ref("");
    const showForm = ref(false);
    const selectedLevel = ref(null);

    // Snackbar state
    const snackbar = ref({ show: false, message: "", type: "info" });
    function showSnackbar(message, type = "info") {
      snackbar.value = { show: true, message, type };
      setTimeout(() => (snackbar.value.show = false), 2500);
    }

    // Dialog konfirmasi hapus
    const showDeleteDialog = ref(false);
    const levelToDelete = ref(null);
    function confirmDeleteLevel(level) {
      levelToDelete.value = level;
      showDeleteDialog.value = true;
    }
    function closeDeleteDialog() {
      showDeleteDialog.value = false;
      levelToDelete.value = null;
    }
    async function deleteLevelConfirmed() {
      if (!levelToDelete.value) return;
      try {
        await api.delete(`/officials/levels/${levelToDelete.value.id}`);
        showSnackbar("Tingkat berhasil dihapus", "success");
        fetchLevels();
      } catch (e) {
        showSnackbar("Gagal menghapus tingkat", "error");
      } finally {
        closeDeleteDialog();
      }
    }

    const fetchLevels = async () => {
      loading.value = true;
      error.value = "";
      try {
        const res = await api.get("/officials/levels");
        levels.value = res.data;
      } catch (e) {
        error.value = "Gagal memuat data tingkat kepengurusan";
      } finally {
        loading.value = false;
      }
    };

    const openForm = (level) => {
      selectedLevel.value = level;
      showForm.value = true;
    };
    const closeForm = () => {
      showForm.value = false;
    };
    function onLevelSaved() {
      showSnackbar("Tingkat berhasil disimpan", "success");
      fetchLevels();
      closeForm();
    }

    onMounted(fetchLevels);
    return {
      levels,
      loading,
      error,
      showForm,
      selectedLevel,
      openForm,
      closeForm,
      onLevelSaved,
      confirmDeleteLevel,
      showDeleteDialog,
      levelToDelete,
      closeDeleteDialog,
      deleteLevelConfirmed,
      snackbar,
      showSnackbar,
    };
  },
};
</script>

<style scoped>
.tingkat-kepengurusan {
  background: #fff;
  border-radius: 8px;
  padding: 18px 18px 8px 18px;
  box-shadow: var(--shadow);
}
.header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.levels-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 12px;
}
.levels-table th,
.levels-table td {
  padding: 8px 10px;
  border-bottom: 1px solid #eee;
}
.levels-table th {
  background: #f7f7f7;
  font-weight: 600;
}
.levels-table tr:last-child td {
  border-bottom: none;
}
.loading,
.error,
.empty {
  margin: 18px 0;
  color: #888;
}
.dialog-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.18);
  z-index: 1001;
}
.dialog-content.dialog-confirm {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: #fff;
  border-radius: 10px;
  min-width: 320px;
  padding: 28px 32px 20px 32px;
  box-shadow: var(--shadow-lg);
  z-index: 1002;
}
.dialog-content h4 {
  margin-bottom: 12px;
}
.dialog-actions {
  display: flex;
  gap: 12px;
  margin-top: 18px;
}
</style>
