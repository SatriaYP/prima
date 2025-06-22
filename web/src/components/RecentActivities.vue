<template>
  <div class="recent-activities card">
    <h3>Aktivitas Terbaru</h3>
    <ul>
      <li v-for="activity in activities" :key="activity.id">
        <span class="activity-icon">
          <span class="material-icons">{{ activity.icon }}</span>
        </span>
        <div class="activity-info">
          <div class="activity-title">{{ activity.title }}</div>
          <div class="activity-subtitle">{{ activity.subtitle }}</div>
        </div>
        <div class="activity-time">{{ activity.timeAgo }}</div>
      </li>
      <li v-if="!activities.length" style="text-align:center;color:var(--text-muted)">Tidak ada aktivitas terbaru</li>
    </ul>
  </div>
</template>
<script>
export default {
  name: 'RecentActivities',
  props: {
    activities: { type: Array, default: () => [] }
  }
};
</script>
<style scoped>
.recent-activities {
  margin-top: 18px;
}
.recent-activities h3 {
  margin-bottom: 12px;
  color: var(--primary);
}
ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
li {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid #e6ecf3;
}
.activity-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e6f0fa;
  border-radius: 50%;
  color: var(--primary);
  font-size: 1.3em;
}
.activity-info {
  flex: 1;
}
.activity-title {
  font-weight: 600;
}
.activity-subtitle {
  color: var(--text-muted);
  font-size: 0.97em;
}
.activity-time {
  color: var(--text-muted);
  font-size: 0.92em;
  min-width: 70px;
  text-align: right;
}
</style>
