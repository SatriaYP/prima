<script setup>
import { ref } from "vue";

const alerts = ref([]);

const showAlert = (message, type = "info", duration = 3000) => {
  const id = Date.now();
  alerts.value.push({ id, message, type });

  setTimeout(() => {
    alerts.value = alerts.value.filter((a) => a.id !== id);
  }, duration);
};

defineExpose({ showAlert });

const iconMap = {
  success: "fas fa-check-circle",
  error: "fas fa-exclamation-circle",
  info: "fas fa-info-circle",
};
</script>

<template>
  <div class="alert-container">
    <transition-group name="fade" tag="div">
      <div
        v-for="alert in alerts"
        :key="alert.id"
        class="alert"
        :class="`alert-${alert.type}`"
      >
        <i :class="iconMap[alert.type]" class="icon"></i>
        <span class="message">{{ alert.message }}</span>
      </div>
    </transition-group>
  </div>
</template>

<style scoped>
.alert-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.alert {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 10px;
  padding: 12px 16px;
  border-radius: 6px;
  font-size: 14px;
  color: #fff;
  min-width: 240px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
  animation: fadeIn 0.3s ease;
}

.icon {
  font-size: 18px;
}

.alert-info {
  background-color: #3498db;
}
.alert-success {
  background-color: #2ecc71;
}
.alert-error {
  background-color: #e74c3c;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
