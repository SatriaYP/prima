<template>
  <div class="statistics-cards">
    <div class="card stat-card">
      <div class="stat-title">Total Anggota</div>
      <div class="stat-value">{{ stats.totalMembers }}</div>
    </div>
    <div class="card stat-card">
      <div class="stat-title">Distribusi Gender</div>
      <canvas ref="genderChart" height="120"></canvas>
      <div class="legend-row">
        <span class="legend male"></span> Laki-laki ({{ stats.male }})
        <span class="legend female" style="margin-left:16px"></span> Perempuan ({{ stats.female }})
      </div>
    </div>
  </div>
</template>
<script>
import { onMounted, ref, watch } from 'vue';
export default {
  name: 'StatisticsCards',
  props: {
    stats: {
      type: Object,
      required: true
    }
  },
  setup(props) {
    const genderChart = ref(null);
    let chartInstance = null;
    onMounted(() => {
      import('chart.js/auto').then(({ default: Chart }) => {
        if (genderChart.value) {
          chartInstance = new Chart(genderChart.value, {
            type: 'pie',
            data: {
              labels: ['Laki-laki', 'Perempuan'],
              datasets: [{
                data: [props.stats.male, props.stats.female],
                backgroundColor: ['#0057B8', '#E74C3C'],
                borderWidth: 2
              }]
            },
            options: {
              plugins: {
                legend: { display: false }
              }
            }
          });
        }
      });
    });
    watch(() => [props.stats.male, props.stats.female], ([male, female]) => {
      if (chartInstance) {
        chartInstance.data.datasets[0].data = [male, female];
        chartInstance.update();
      }
    });
    return { genderChart };
  }
};
</script>
<style scoped>
.statistics-cards {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-bottom: 18px;
}
.stat-card {
  flex: 1 1 220px;
  min-width: 220px;
  max-width: 320px;
  text-align: center;
  background: linear-gradient(120deg, #e6f0fa 0%, #f7fafd 100%);
  box-shadow: var(--shadow);
  border: 1.5px solid #d0d7e2;
  padding: 24px 0 18px 0;
}
.stat-title {
  color: var(--primary);
  font-weight: 600;
  font-size: 1.1em;
  margin-bottom: 10px;
}
.stat-value {
  font-size: 2.1em;
  font-weight: bold;
  color: #0057B8;
  margin-bottom: 8px;
}
.legend-row {
  margin-top: 12px;
  font-size: 0.98em;
  display: flex;
  align-items: center;
  justify-content: center;
}
.legend {
  display: inline-block;
  width: 16px;
  height: 16px;
  border-radius: 5px;
  margin-right: 6px;
}
.legend.male {
  background: #0057B8;
}
.legend.female {
  background: #E74C3C;
}
</style>
