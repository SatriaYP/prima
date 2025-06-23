<template>
  <div class="unit-form-dialog">
    <div class="dialog-backdrop" @click="$emit('close')"></div>
    <div class="dialog-content">
      <h3>{{ unit ? 'Edit Unit Kepengurusan' : 'Tambah Unit Kepengurusan' }}</h3>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label>Nama Unit</label>
          <input v-model="form.name" required />
        </div>
        <div class="form-group">
          <label>Kode</label>
          <input v-model="form.code" required />
        </div>
        <div class="form-group">
          <label>Tingkat</label>
          <select v-model="form.tingkatId" required>
            <option value="">Pilih Tingkat</option>
            <option v-for="t in tingkatList" :key="t.id" :value="t.id">{{ t.name }}</option>
          </select>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-green">Simpan</button>
          <button type="button" class="btn" @click="$emit('close')">Batal</button>
        </div>
        <div v-if="error" class="error">{{ error }}</div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, watch, onMounted } from 'vue';
import api from '../services/api';

export default {
  name: 'UnitFormDialog',
  props: { unit: Object, parent: Object },
  setup(props, { emit }) {
    const form = ref({ name: '', code: '', tingkatId: '' });
    const tingkatList = ref([]);
    const error = ref('');

    const fetchTingkat = async () => {
      try {
        const res = await api.get('/officials/levels');
        tingkatList.value = res.data;
      } catch {
        tingkatList.value = [];
      }
    };

    watch(() => props.unit, (val) => {
      if (val) {
        form.value = {
          name: val.name,
          code: val.code,
          tingkatId: val.tingkat?.id || ''
        };
      } else {
        form.value = { name: '', code: '', tingkatId: '' };
      }
    }, { immediate: true });

    onMounted(fetchTingkat);

    const handleSubmit = async () => {
      error.value = '';
      try {
        if (props.unit) {
          await api.put(`/officials/${props.unit.id}`, form.value);
        } else {
          await api.post('/officials', { ...form.value, parentId: props.parent?.id });
        }
        emit('saved');
      } catch (e) {
        error.value = 'Gagal menyimpan data';
      }
    };

    return { form, tingkatList, error, handleSubmit };
  }
};
</script>

<style scoped>
.unit-form-dialog { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1000; }
.dialog-backdrop { position: absolute; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.25); }
.dialog-content { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #fff; border-radius: 10px; padding: 32px 32px 24px 32px; min-width: 340px; box-shadow: var(--shadow-lg); }
h3 { margin-bottom: 18px; }
.form-group { margin-bottom: 16px; }
.form-actions { margin-top: 10px; display: flex; gap: 12px; }
.error { color: #E74C3C; margin-top: 8px; }
</style>
