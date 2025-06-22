<template>
  <div class="member-list-page">
    <div class="member-list-header">
      <h1>Daftar Anggota</h1>
      <button class="btn btn-green" @click="addMember">Tambah Anggota</button>
    </div>
    <MemberFilter v-model:search="search" />
    <MemberTable :members="pagedMembers" @view="viewDetail" @edit="editMember" />
    <div class="pagination-row">
      <button class="btn btn-sm" :disabled="page === 1" @click="page--">&laquo; Prev</button>
      <span>Halaman {{ page }} dari {{ totalPages }}</span>
      <button class="btn btn-sm" :disabled="page === totalPages" @click="page++">Next &raquo;</button>
    </div>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'MemberListView',
  data() {
    return {
      members: []
    };
  },
  mounted() {
    this.fetchMembers();
  },
  methods: {
    async fetchMembers() {
      // Ganti endpoint sesuai backend API
      try {
        const res = await api.get('/members');
        this.members = res.data;
      } catch (err) {
        // Error handling
        this.members = [];
      }
    },
    viewDetail(member) {
      // Navigasi ke halaman detail anggota
      this.$router.push({ name: 'MemberDetail', params: { id: member.id } });
    },
    editMember(member) {
      // Navigasi ke halaman edit anggota
      this.$router.push({ name: 'MemberEdit', params: { id: member.id } });
    },
    addMember() {
      // Navigasi ke halaman tambah anggota
      this.$router.push({ name: 'MemberAdd' });
    }
  }
};
</script>

<style scoped>
.member-list-page {
  max-width: 1100px;
  margin: 36px auto 0 auto;
  padding: 0 14px 32px 14px;
  display: flex;
  flex-direction: column;
}
.member-list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}
.pagination-row {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 14px;
  margin-top: 10px;
}
@media (max-width: 900px) {
  .member-list-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  .pagination-row {
    justify-content: center;
  }
}
</style>
