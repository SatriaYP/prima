<template>
  <div class="tingkat-kepengurusan">
    <div class="header-row">
      <h2>Tingkat Kepengurusan</h2>
      <button class="btn btn-green" @click="openForm(null)">Tambah Tingkat</button>
    </div>
    <div v-if="loading" class="loading">Memuat data...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <table class="tingkat-table">
        <thead>
          <tr><th>Nama</th><th>Urutan</th><th>Aksi</th></tr>
        </thead>
        <tbody>
          <tr v-for="t in tingkatList" :key="t.id">
            <td>{{ t.name }}</td>
            <td>{{ t.sequence }}</td>
            <td>
              <button class="btn btn-blue" @click="openForm(t)">Edit</button>
              <button class="btn btn-red" @click="deleteTingkat(t)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <TingkatFormDialog v-if="showForm" :tingkat="selectedTingkat" @close="closeForm" @saved="refresh" />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import TingkatFormDialog from './TingkatFormDialog.vue';
import api from '../services/api';

export default {
  name: 'TingkatKepengurusan',
  components: { TingkatFormDialog },
  setup() {
    const tingkatList = ref([]);
    const loading = ref(false);
    const error = ref('');
    const showForm = ref(false);
    const selectedTingkat = ref(null);

    const fetchList = async () => {
      loading.value = true;
      error.value = '';
      try {
        const res = await api.get('/officials/levels');
        tingkatList.value = res.data;
      } catch (e) {
        error.value = 'Gagal memuat data tingkat kepengurusan';
      } finally {
        loading.value = false;
      }
    };
    const openForm = (tingkat) => { selectedTingkat.value = tingkat; showForm.value = true; };
    const closeForm = () => { showForm.value = false; };
    const refresh = () => { fetchList(); closeForm(); };
    const deleteTingkat = async (tingkat) => {
      if (!confirm(`Hapus tingkat ${tingkat.name}?`)) return;
      try {
        await api.delete(`/officials/levels/${tingkat.id}`);
        refresh();
      } catch (e) {
        alert('Gagal menghapus tingkat');
      }
    };
    onMounted(fetchList);
    return { tingkatList, loading, error, showForm, selectedTingkat, openForm, closeForm, refresh, deleteTingkat };
  }
};
</script>

<style scoped>
.tingkat-kepengurusan { background: #fff; border-radius: 8px; padding: 18px 18px 8px 18px; box-shadow: var(--shadow); }
.header-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.tingkat-table { width: 100%; border-collapse: collapse; margin-bottom: 18px; }
.tingkat-table th, .tingkat-table td { border-bottom: 1px solid #eee; padding: 10px 8px; text-align: left; }
.tingkat-table th { background: #f5f6fa; }
.loading, .error { margin: 18px 0; color: #888; }
</style>
