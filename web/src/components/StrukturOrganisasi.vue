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
        <UnitNode v-for="unit in tree" :key="unit.id" :unit="unit" :level="0" @edit="openUnitForm" @add-child="openUnitForm" @delete="deleteUnit" />
      </ul>
    </div>
    <UnitFormDialog v-if="showForm" :unit="selectedUnit" :parent="parentUnit" @close="closeForm" @saved="refresh" />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import UnitNode from './UnitNode.vue';
import UnitFormDialog from './UnitFormDialog.vue';
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
    const deleteUnit = async (unit) => {
      if (!confirm(`Hapus unit ${unit.name}?`)) return;
      try {
        await api.delete(`/officials/${unit.id}`);
        refresh();
      } catch (e) {
        alert('Gagal menghapus unit');
      }
    };

    onMounted(fetchTree);
    return { tree, loading, error, showForm, selectedUnit, parentUnit, openUnitForm, closeForm, refresh, deleteUnit };
  }
};
</script>

<style scoped>
.struktur-organisasi { background: #fff; border-radius: 8px; padding: 18px 18px 8px 18px; box-shadow: var(--shadow); }
.header-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.unit-tree { list-style: none; padding-left: 0; }
.loading, .error, .empty { margin: 18px 0; color: #888; }
</style>
