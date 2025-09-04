<script setup>
import AppBottombar from "@/components/layout/AppBottombar.vue";
import AppFooter from "@/components/layout/AppFooter.vue";
import AppSidebar from "@/components/layout/AppSidebar.vue";
import AppTopbar from "@/components/layout/AppTopbar.vue";
import { ref } from "vue";

const collapsed = ref(false);
const toggleSidebar = () => {
  collapsed.value = !collapsed.value;
};

// import Topbar from "./Topbar.vue";
// import Sidebar from "./Sidebar.vue";
// import Footer from "./Footer.vue";
// import BottomBar from "./BottomBar.vue";
</script>

<template>
  <div class="dashboard-layout">
    <div class="main-container">
      <AppSidebar
        class="sidebar-desktop"
        :collapsed="collapsed"
        @toggle="toggleSidebar"
      />
      <AppBottombar class="sidebar-mobile" />

      <div class="content-wrapper" :class="{ collapsed }">
        <AppTopbar />
        <main class="content">
          <router-view />
        </main>
        <AppFooter />
      </div>
    </div>

    <!-- <AppFooter /> -->
  </div>
</template>

<style scoped>
.dashboard-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-container {
  display: flex;
  flex: 1;
  min-height: 100vh;
  /* overflow: hidden; */
}

.sidebar-desktop {
  display: none;
}

.sidebar-mobile {
  display: flex;
}

.content-wrapper {
  display: flex;
  flex-direction: column;
  flex: 1;
  background: #f9f9f9;
  /* overflow: hidden; */
  height: 100vh;
  margin-left: 220px;
  transition: margin-left 0.3s;
}

.content-wrapper.collapsed {
  margin-left: 70px;
}

.content {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  /* background: #f9f9f9; */
}

/* Media Query for desktop */
@media (min-width: 768px) {
  .sidebar-desktop {
    display: block;
  }

  .sidebar-mobile {
    display: none;
  }
}
</style>
