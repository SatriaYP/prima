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
import MemberFilter from '../components/MemberFilter.vue';
import MemberTable from '../components/MemberTable.vue';

export default {
  name: 'MemberListView',
  components: { MemberFilter, MemberTable },
  data() {
    return {
      members: [],
      search: '',
      page: 1,
      pageSize: 10
    };
  },
  computed: {
    filteredMembers() {
      if (!this.search) return this.members;
      return this.members.filter(m => m.name.toLowerCase().includes(this.search.toLowerCase()));
    },
    totalPages() {
      return Math.max(1, Math.ceil(this.filteredMembers.length / this.pageSize));
    },
    pagedMembers() {
      const start = (this.page - 1) * this.pageSize;
      return this.filteredMembers.slice(start, start + this.pageSize);
    }
  },
  mounted() {
    this.fetchMembers();
  },
  methods: {
    async fetchMembers() {
      try {
        const res = await api.get('/members');
        this.members = res.data;
      } catch (err) {
        this.members = [];
      }
    },
    viewDetail(member) {
      this.$router.push({ name: 'MemberDetail', params: { id: member.id } });
    },
    editMember(member) {
      this.$router.push({ name: 'MemberEdit', params: { id: member.id } });
    },
    addMember() {
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
