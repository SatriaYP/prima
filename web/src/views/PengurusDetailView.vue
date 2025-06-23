<template>
  <div class="pengurus-detail-container" v-if="pengurus">
    <h1>Detail Pengurus</h1>
    <table>
      <tbody>
        <tr><th>Nama</th><td>{{ pengurus.name }}</td></tr>
        <tr><th>Jabatan</th><td>{{ pengurus.position }}</td></tr>
        <tr><th>Wilayah</th><td>{{ pengurus.region }}</td></tr>
        <tr><th>Email</th><td>{{ pengurus.email }}</td></tr>
        <tr><th>Telepon</th><td>{{ pengurus.phone }}</td></tr>
        <!-- Tambahkan field lain sesuai kebutuhan -->
      </tbody>
    </table>
    <button @click="$router.push('/pengurus')">Kembali</button>
    <button @click="editPengurus">Edit</button>
  </div>
  <div v-else>
    <p>Memuat data pengurus...</p>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'PengurusDetailView',
  data() {
    return {
      pengurus: null
    };
  },
  mounted() {
    this.fetchPengurus();
  },
  methods: {
    async fetchPengurus() {
      const id = this.$route.params.id;
      try {
        const res = await api.get(`/officials/${id}`);
        this.pengurus = res.data;
      } catch (err) {
        this.pengurus = null;
      }
    },
    editPengurus() {
      this.$router.push({ name: 'PengurusEdit', params: { id: this.pengurus.id } });
    }
  }
};
</script>

<style scoped>
.pengurus-detail-container {
  max-width: 600px;
  margin: 40px auto;
  padding: 24px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fff;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 24px;
}
th, td {
  text-align: left;
  padding: 8px 12px;
}
th {
  background: #f5f5f5;
  width: 160px;
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
</style>
