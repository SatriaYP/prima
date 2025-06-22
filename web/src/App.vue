<template>
  <component :is="layoutComponent" />
</template>

<script>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import MainLayout from './layouts/MainLayout.vue';
import LoginView from './views/LoginView.vue';
import './assets/global.css';

export default {
  name: 'App',
  components: { MainLayout, LoginView },
  setup() {
    const route = useRoute();
    // Tampilkan MainLayout untuk semua halaman kecuali login
    const layoutComponent = computed(() => {
      return route.name === 'Login' ? LoginView : MainLayout;
    });
    return { layoutComponent };
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
