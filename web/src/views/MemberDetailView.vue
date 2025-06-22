<template>
  <div class="member-detail-container" v-if="member">
    <h1>Detail Anggota</h1>
    <table>
      <tr><th>Nama</th><td>{{ member.name }}</td></tr>
      <tr><th>Email</th><td>{{ member.email }}</td></tr>
      <tr><th>No. KTP</th><td>{{ member.ktp }}</td></tr>
      <tr><th>Alamat</th><td>{{ member.address }}</td></tr>
      <tr><th>Telepon</th><td>{{ member.phone }}</td></tr>
      <!-- Tambahkan field lain sesuai kebutuhan -->
    </table>
    <button @click="$router.push('/members')">Kembali</button>
    <button @click="editMember">Edit</button>
  </div>
  <div v-else>
    <p>Memuat data anggota...</p>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'MemberDetailView',
  data() {
    return {
      member: null
    };
  },
  mounted() {
    this.fetchMember();
  },
  methods: {
    async fetchMember() {
      const id = this.$route.params.id;
      try {
        const res = await api.get(`/members/${id}`);
        this.member = res.data;
      } catch (err) {
        this.member = null;
      }
    },
    editMember() {
      this.$router.push({ name: 'MemberEdit', params: { id: this.member.id } });
    }
  }
};
</script>

<style scoped>
.member-detail-container {
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
  background: #42b983;
  color: #fff;
  cursor: pointer;
}
</style>
