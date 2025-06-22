<template>
  <div class="member-table card">
    <table>
      <thead>
        <tr>
          <th>Nama</th>
          <th>Gender</th>
          <th>Wilayah</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="member in members" :key="member.id">
          <td>{{ member.name }}</td>
          <td>{{ member.gender }}</td>
          <td>{{ member.region }}</td>
          <td>
            <button class="btn btn-sm" @click="$emit('view', member)">Detail</button>
            <button class="btn btn-sm btn-green" @click="$emit('edit', member)">Edit</button>
            <button class="btn btn-sm btn-red" @click="$emit('delete', member)">Hapus</button>
          </td>
        </tr>
        <tr v-if="!members.length">
          <td colspan="4" style="text-align:center;color:var(--text-muted)">Tidak ada data</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
export default {
  name: 'MemberTable',
  props: {
    members: { type: Array, default: () => [] }
  },
  emits: ['view', 'edit', 'delete']
};
</script>
<style scoped>
.member-table {
  overflow-x: auto;
  margin-bottom: 18px;
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 1em;
}
th, td {
  padding: 12px 10px;
  border-bottom: 1.5px solid #e6ecf3;
  text-align: left;
}
th {
  background: #f7fafd;
  color: var(--primary);
  font-weight: 700;
}
.btn-sm {
  padding: 4px 12px;
  font-size: 0.95em;
  margin-right: 4px;
}
.btn-red {
  background: #E74C3C;
}
.btn-red:hover {
  background: #b92b23;
}
</style>
