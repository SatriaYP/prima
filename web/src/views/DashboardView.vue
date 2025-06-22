<template>
  <div class="dashboard-page">
    <DashboardHeader :username="user.username" @download="onDownloadData" @add-member="onAddMember" />
    <div class="dashboard-row">
      <div class="dashboard-col dashboard-col-filter">
        <MemberFilter />
      </div>
      <div class="dashboard-col dashboard-col-stats">
        <StatisticsCards :stats="statData" />
      </div>
    </div>
    <MemberTable :members="members" @view="onViewMember" @edit="onEditMember" @delete="onDeleteMember" />
    <RecentActivities :activities="activities" />
  </div>
</template>

<script>
import DashboardHeader from '../components/DashboardHeader.vue';
import StatisticsCards from '../components/StatisticsCards.vue';
import MemberFilter from '../components/MemberFilter.vue';
import MemberTable from '../components/MemberTable.vue';
import RecentActivities from '../components/RecentActivities.vue';

export default {
  name: 'DashboardView',
  components: {
    DashboardHeader,
    StatisticsCards,
    MemberFilter,
    MemberTable,
    RecentActivities
  },
  data() {
    return {
      user: {
        username: 'Admin',
      },
      statData: {
        totalMembers: 1234,
        male: 700,
        female: 534
      },
      members: [
        { id: 1, name: 'Budi Santoso', gender: 'Laki-laki', region: 'Jakarta' },
        { id: 2, name: 'Siti Aminah', gender: 'Perempuan', region: 'Bandung' },
        { id: 3, name: 'Ahmad Fauzi', gender: 'Laki-laki', region: 'Surabaya' }
      ],
      activities: [
        { id: 1, icon: 'person_add', title: 'Tambah Anggota', subtitle: 'Budi Santoso ditambahkan', timeAgo: '2 jam lalu' },
        { id: 2, icon: 'edit', title: 'Edit Data', subtitle: 'Profil Siti Aminah diperbarui', timeAgo: '1 jam lalu' },
        { id: 3, icon: 'delete', title: 'Hapus Anggota', subtitle: 'Ahmad Fauzi dihapus', timeAgo: '30 menit lalu' }
      ]
    };
  },
  methods: {
    onDownloadData() {
      alert('Fitur unduh data coming soon!');
    },
    onAddMember() {
      alert('Fitur tambah anggota coming soon!');
    },
    onViewMember(member) {
      alert('Detail anggota: ' + member.name);
    },
    onEditMember(member) {
      alert('Edit anggota: ' + member.name);
    },
    onDeleteMember(member) {
      alert('Hapus anggota: ' + member.name);
    }
  }
};
</script>

<style scoped>
.dashboard-page {
  max-width: 1100px;
  margin: 36px auto 0 auto;
  padding: 0 14px 32px 14px;
  display: flex;
  flex-direction: column;
  gap: 0;
}
.dashboard-row {
  display: flex;
  gap: 24px;
  margin-bottom: 18px;
  flex-wrap: wrap;
}
.dashboard-col-filter {
  flex: 1 1 300px;
  min-width: 260px;
  max-width: 360px;
}
.dashboard-col-stats {
  flex: 2 1 400px;
  min-width: 260px;
}
@media (max-width: 900px) {
  .dashboard-row {
    flex-direction: column;
    gap: 12px;
  }
  .dashboard-col-filter, .dashboard-col-stats {
    max-width: 100%;
    min-width: 0;
  }
}
</style>


<style scoped>
.dashboard-container {
  max-width: 900px;
  margin: 40px auto;
  padding: 24px;
}
.stats {
  display: flex;
  gap: 24px;
  margin-top: 32px;
}
.stat-card {
  flex: 1;
  padding: 24px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fafafa;
  text-align: center;
}
.stat-card h3 {
  margin-bottom: 12px;
}
.stat-card p {
  font-size: 2em;
  font-weight: bold;
  color: #42b983;
}
</style>
