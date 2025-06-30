<template>
  <transition name="snackbar-fade">
    <div v-if="show" :class="['snackbar', type]">
      {{ message }}
    </div>
  </transition>
</template>

<script>
export default {
  name: 'Snackbar',
  props: {
    show: Boolean,
    message: String,
    type: { type: String, default: 'info' } // 'info', 'success', 'error'
  }
};
</script>

<style scoped>
.snackbar {
  position: fixed;
  right: 28px;
  bottom: 32px;
  min-width: 220px;
  max-width: 360px;
  background: #222;
  color: #fff;
  border-radius: 8px;
  padding: 14px 22px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.10);
  font-size: 1.08em;
  z-index: 1100;
  opacity: 0.98;
  display: flex;
  align-items: center;
  gap: 10px;
}
.snackbar.success { background: #229c2a; }
.snackbar.error { background: #E74C3C; }
.snackbar.info { background: #0057B8; }
.snackbar-fade-enter-active, .snackbar-fade-leave-active {
  transition: opacity 0.4s, transform 0.3s;
}
.snackbar-fade-enter-from, .snackbar-fade-leave-to {
  opacity: 0;
  transform: translateY(40px);
}
</style>
