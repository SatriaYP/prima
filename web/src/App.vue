<script setup>
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useAuth } from "./composables/useAuth";
import AlertNotification from "@/components/common/AlertNotification.vue";

// Import layouts
// import DefaultLayout from "@/layouts/DefaultLayout.vue";
import AuthLayout from "@/layouts/AuthLayout.vue";
import DashboardLayout from "@/layouts/DashboardLayout.vue";

import { ref, provide } from "vue";

const alertRef = ref(null);
provide("alert", alertRef);

const route = useRoute();
const { isAuthenticated } = useAuth();

// Daftar layout
const layouts = {
  // DefaultLayout,
  AuthLayout,
  DashboardLayout,
};

// Layout yang dipakai saat ini
const currentLayout = computed(() => {
  const layoutName = route.meta.layout
    ? route.meta.layout
    : isAuthenticated
    ? "DashboardLayout"
    : "AuthLayout";

  // return layouts[layoutName] || DefaultLayout;
  return layouts[layoutName];
});
</script>

<template>
  <component :is="currentLayout">
    <router-view />
  </component>
  <AlertNotification ref="alertRef" />
</template>

<style>
/* @import '@/assets/styles/global.css'; */
</style>
