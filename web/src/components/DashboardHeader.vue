<template>
  <div class="dashboard-header">
    <div class="header-left">
      <h2>Selamat Datang, {{ username }}</h2>
    </div>
    <div class="header-actions">
      <button class="btn" @click="$emit('download')">
        <span class="icon material-icons">download</span>
        <span class="btn-text">Unduh Data</span>
      </button>
      <button class="btn btn-green" @click="$emit('add-member')">
        <span class="icon material-icons">person_add</span>
        <span class="btn-text">Tambah Anggota</span>
      </button>
    </div>
  </div>
</template>
<script>
export default {
  name: 'DashboardHeader',
  props: {
    username: { type: String, default: '' }
  }
};
</script>
<style scoped>
.dashboard-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 18px;
}
.header-left h2 {
  font-size: 1.5em;
  font-weight: 700;
  color: var(--primary);
  margin: 0;
}
.header-actions {
  display: flex;
  gap: 10px;
}
.btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: var(--primary);
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 1em;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.18s;
}
.btn:hover {
  background: var(--primary-dark);
}
.btn-green {
  background: #2ecc40;
}
.btn-green:hover {
  background: #229c2a;
}
.icon.material-icons {
  font-size: 1.2em;
}
.btn-text {
  display: inline;
}
@media (max-width: 600px) {
  .dashboard-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  .header-actions {
    width: 100%;
    gap: 6px;
  }
}
</style>
