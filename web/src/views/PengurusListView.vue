<template>
  <div class="pengurus-list-page">
    <div class="pengurus-list-header">
      <h1>Daftar Pengurus</h1>
      <button class="btn btn-green" @click="addPengurus">Tambah Pengurus</button>
    </div>
    <MemberFilter v-model:search="search" />
    <MemberTable :members="pagedPengurus" @view="viewDetail" @edit="editPengurus" />
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
  name: 'PengurusListView',
  components: { MemberFilter, MemberTable },
  data() {
    return {
      pengurusList: [],
      search: '',
      page: 1,
      perPage: 10
    };
  },
  computed: {
    filteredPengurus() {
      if (!this.search) return this.pengurusList;
      return this.pengurusList.filter(p => p.name.toLowerCase().includes(this.search.toLowerCase()));
    },
    totalPages() {
      return Math.ceil(this.filteredPengurus.length / this.perPage) || 1;
    },
    pagedPengurus() {
      const start = (this.page - 1) * this.perPage;
      return this.filteredPengurus.slice(start, start + this.perPage);
    }
  },
  mounted() {
    this.fetchPengurus();
  },
  methods: {
    async fetchPengurus() {
      try {
        const res = await api.get('/officials');
        this.pengurusList = res.data;
      } catch (err) {
        this.pengurusList = [];
      }
    },
    viewDetail(pengurus) {
      this.$router.push({ name: 'PengurusDetail', params: { id: pengurus.id } });
    },
    editPengurus(pengurus) {
      this.$router.push({ name: 'PengurusEdit', params: { id: pengurus.id } });
    },
    addPengurus() {
      this.$router.push({ name: 'PengurusAdd' });
    }
  },
  watch: {
    search() {
      this.page = 1;
    }
  }
};
</script>

<style scoped>
.pengurus-list-page {
  max-width: 1100px;
  margin: 36px auto 0 auto;
  padding: 0 14px 32px 14px;
  display: flex;
  flex-direction: column;
}
.pengurus-list-header {
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
  .pengurus-list-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  .pagination-row {
    justify-content: center;
  }
}
</style>
