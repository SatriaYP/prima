<template>
  <div class="struktur-organisasi">
    <div class="header-row">
      <h2>Struktur Organisasi</h2>
      <button class="btn btn-green" @click="openUnitForm(null)">Tambah Unit</button>
    </div>
    <div v-if="loading" class="loading">Memuat data...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="tree.length === 0" class="empty">Tidak ada data kepengurusan</div>
    <div v-else>
      <ul class="unit-tree">
        <UnitNode v-for="unit in tree" :key="unit.id" :unit="unit" :level="0" @edit="openUnitForm" @add-child="openUnitForm" @delete="confirmDeleteUnit" />
      </ul>
    </div>
    <UnitFormDialog v-if="showForm" :unit="selectedUnit" :parent="parentUnit" @close="closeForm" @saved="onUnitSaved" />
    <div v-if="showDeleteDialog" class="dialog-backdrop" @click="closeDeleteDialog"></div>
    <div v-if="showDeleteDialog" class="dialog-content dialog-confirm">
      <h4>Konfirmasi Hapus</h4>
      <p>Hapus unit <b>{{ unitToDelete?.name }}</b>?</p>
      <div class="dialog-actions">
        <button class="btn" @click="closeDeleteDialog">Batal</button>
        <button class="btn btn-red" @click="deleteUnitConfirmed">Hapus</button>
      </div>
    </div>
    <Snackbar :show="snackbar.show" :message="snackbar.message" :type="snackbar.type" />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import UnitNode from './UnitNode.vue';
import UnitFormDialog from './UnitFormDialog.vue';
import Snackbar from './Snackbar.vue';
import api from '../services/api';

export default {
  name: 'StrukturOrganisasi',
  components: { UnitNode, UnitFormDialog },
  setup() {
    const tree = ref([]);
    const loading = ref(false);
    const error = ref('');
    const showForm = ref(false);
    const selectedUnit = ref(null);
    const parentUnit = ref(null);

    // Snackbar state
    const snackbar = ref({ show: false, message: '', type: 'info' });
    function showSnackbar(message, type = 'info') {
      snackbar.value = { show: true, message, type };
      setTimeout(() => snackbar.value.show = false, 2500);
    }

    // Dialog konfirmasi hapus
    const showDeleteDialog = ref(false);
    const unitToDelete = ref(null);
    function confirmDeleteUnit(unit) {
      unitToDelete.value = unit;
      showDeleteDialog.value = true;
    }
    function closeDeleteDialog() {
      showDeleteDialog.value = false;
      unitToDelete.value = null;
    }
    async function deleteUnitConfirmed() {
      if (!unitToDelete.value) return;
      try {
        await api.delete(`/officials/${unitToDelete.value.id}`);
        showSnackbar('Unit berhasil dihapus', 'success');
        fetchTree();
      } catch (e) {
        showSnackbar('Gagal menghapus unit', 'error');
      } finally {
        closeDeleteDialog();
      }
    }

    const fetchTree = async () => {
      loading.value = true;
      error.value = '';
      try {
        const res = await api.get('/officials/tree');
        tree.value = res.data;
      } catch (e) {
        error.value = 'Gagal memuat data struktur organisasi';
      } finally {
        loading.value = false;
      }
    };

    const openUnitForm = (unit, parent = null) => {
      selectedUnit.value = unit;
      parentUnit.value = parent;
      showForm.value = true;
    };
    const closeForm = () => { showForm.value = false; };
    const refresh = () => { fetchTree(); closeForm(); };
    function onUnitSaved() {
      showSnackbar('Unit berhasil disimpan', 'success');
      refresh();
    }

    onMounted(fetchTree);
    return {
      tree, loading, error, showForm, selectedUnit, parentUnit,
      openUnitForm, closeForm, refresh,
      confirmDeleteUnit, showDeleteDialog, unitToDelete, closeDeleteDialog, deleteUnitConfirmed,
      snackbar, showSnackbar, onUnitSaved
    };
  }
};
</script>

<style scoped>
.struktur-organisasi { background: #fff; border-radius: 8px; padding: 18px 18px 8px 18px; box-shadow: var(--shadow); }
.header-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.unit-tree { list-style: none; padding-left: 0; }
.loading, .error, .empty { margin: 18px 0; color: #888; }
.dialog-backdrop { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.18); z-index: 1001; }
.dialog-content.dialog-confirm { position: fixed; top: 50%; left: 50%; transform: translate(-50%,-50%); background: #fff; border-radius: 10px; min-width: 320px; padding: 28px 32px 20px 32px; box-shadow: var(--shadow-lg); z-index: 1002; }
.dialog-content h4 { margin-bottom: 12px; }
.dialog-actions { display: flex; gap: 12px; margin-top: 18px; }
</style>
