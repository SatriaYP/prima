<template>
  <div class="pengurus-form-container">
    <h1>{{ isEdit ? 'Edit Pengurus' : 'Tambah Pengurus' }}</h1>
    <form @submit.prevent="handleSubmit">
      <div>
        <label>Nama</label>
        <input v-model="form.name" required />
      </div>
      <div>
        <label>Jabatan</label>
        <input v-model="form.position" required />
      </div>
      <div>
        <label>Wilayah</label>
        <input v-model="form.region" />
      </div>
      <div>
        <label>Email</label>
        <input v-model="form.email" type="email" />
      </div>
      <div>
        <label>Telepon</label>
        <input v-model="form.phone" />
      </div>
      <!-- Tambahkan field lain sesuai kebutuhan -->
      <button type="submit">{{ isEdit ? 'Simpan Perubahan' : 'Tambah Pengurus' }}</button>
      <button type="button" @click="$router.push('/pengurus')">Batal</button>
      <div v-if="error" class="error">{{ error }}</div>
    </form>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'PengurusFormView',
  data() {
    return {
      form: {
        name: '',
        position: '',
        region: '',
        email: '',
        phone: ''
      },
      error: '',
      isEdit: false
    };
  },
  mounted() {
    if (this.$route.params.id) {
      this.isEdit = true;
      this.fetchPengurus();
    }
  },
  methods: {
    async fetchPengurus() {
      try {
        const res = await api.get(`/pengurus/${this.$route.params.id}`);
        this.form = res.data;
      } catch (err) {
        this.error = 'Gagal memuat data pengurus';
      }
    },
    async handleSubmit() {
      this.error = '';
      try {
        if (this.isEdit) {
          await api.put(`/officials/${this.$route.params.id}`, this.form);
        } else {
          await api.post('/officials', this.form);
        }
        this.$router.push('/pengurus');
      } catch (err) {
        this.error = err.response?.data?.message || 'Gagal menyimpan data';
      }
    }
  }
};
</script>

<style scoped>
.pengurus-form-container {
  max-width: 600px;
  margin: 40px auto;
  padding: 24px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fff;
}
form > div {
  margin-bottom: 16px;
}
label {
  display: block;
  margin-bottom: 4px;
}
input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  margin-right: 12px;
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  background: #2c3e50;
  color: #fff;
  cursor: pointer;
}
button:last-child {
  background: #aaa;
}
.error {
  color: red;
  margin-top: 10px;
}
</style>
