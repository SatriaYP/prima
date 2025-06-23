<template>
  <div class="tingkat-form-dialog">
    <div class="dialog-backdrop" @click="$emit('close')"></div>
    <div class="dialog-content">
      <h3>{{ tingkat ? 'Edit Tingkat' : 'Tambah Tingkat' }}</h3>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label>Nama Tingkat</label>
          <input v-model="form.name" required />
        </div>
        <div class="form-group">
          <label>Urutan</label>
          <input v-model.number="form.sequence" type="number" required min="1" />
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
import { ref, watch } from 'vue';
import api from '../services/api';

export default {
  name: 'TingkatFormDialog',
  props: { tingkat: Object },
  setup(props, { emit }) {
    const form = ref({ name: '', sequence: 1 });
    const error = ref('');

    watch(() => props.tingkat, (val) => {
      if (val) {
        form.value = { name: val.name, sequence: val.sequence };
      } else {
        form.value = { name: '', sequence: 1 };
      }
    }, { immediate: true });

    const handleSubmit = async () => {
      error.value = '';
      try {
        if (props.tingkat) {
          await api.put(`/officials/levels/${props.tingkat.id}`, form.value);
        } else {
          await api.post('/officials/levels', form.value);
        }
        emit('saved');
      } catch (e) {
        error.value = 'Gagal menyimpan data';
      }
    };

    return { form, error, handleSubmit };
  }
};
</script>

<style scoped>
.tingkat-form-dialog { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1000; }
.dialog-backdrop { position: absolute; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.25); }
.dialog-content { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #fff; border-radius: 10px; padding: 32px 32px 24px 32px; min-width: 340px; box-shadow: var(--shadow-lg); }
h3 { margin-bottom: 18px; }
.form-group { margin-bottom: 16px; }
.form-actions { margin-top: 10px; display: flex; gap: 12px; }
.error { color: #E74C3C; margin-top: 8px; }
</style>
