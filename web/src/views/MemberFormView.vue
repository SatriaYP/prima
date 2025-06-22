<template>
  <div class="member-form-container">
    <h1>{{ isEdit ? 'Edit Anggota' : 'Tambah Anggota' }}</h1>
    <form @submit.prevent="handleSubmit">
      <div>
        <label>Nama</label>
        <input v-model="form.name" required />
      </div>
      <div>
        <label>Email</label>
        <input v-model="form.email" type="email" required />
      </div>
      <div>
        <label>No. KTP</label>
        <input v-model="form.ktp" required />
      </div>
      <div>
        <label>Alamat</label>
        <input v-model="form.address" />
      </div>
      <div>
        <label>Telepon</label>
        <input v-model="form.phone" />
      </div>
      <!-- Tambahkan field lain sesuai kebutuhan -->
      <button type="submit">{{ isEdit ? 'Simpan Perubahan' : 'Tambah Anggota' }}</button>
      <button type="button" @click="$router.push('/members')">Batal</button>
      <div v-if="error" class="error">{{ error }}</div>
    </form>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'MemberFormView',
  data() {
    return {
      form: {
        name: '',
        email: '',
        ktp: '',
        address: '',
        phone: ''
      },
      error: '',
      isEdit: false
    };
  },
  mounted() {
    if (this.$route.params.id) {
      this.isEdit = true;
      this.fetchMember();
    }
  },
  methods: {
    async fetchMember() {
      try {
        const res = await api.get(`/members/${this.$route.params.id}`);
        this.form = res.data;
      } catch (err) {
        this.error = 'Gagal memuat data anggota';
      }
    },
    async handleSubmit() {
      this.error = '';
      try {
        if (this.isEdit) {
          await api.put(`/members/${this.$route.params.id}`, this.form);
        } else {
          await api.post('/members', this.form);
        }
        this.$router.push('/members');
      } catch (err) {
        this.error = err.response?.data?.message || 'Gagal menyimpan data';
      }
    }
  }
};
</script>

<style scoped>
.member-form-container {
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
  background: #42b983;
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
