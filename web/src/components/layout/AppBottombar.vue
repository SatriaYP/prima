<script setup>
const menu = [
  { name: "Dashboard", to: "/dashboard", icon: "fas fa-home" },
  { name: "Users", to: "/users", icon: "fas fa-users" },
  { name: "Settings", to: "/settings", icon: "fas fa-cog" },
];
</script>
\
<template>
  <nav class="bottom-bar">
    <router-link
      v-for="item in menu"
      :key="item.name"
      :to="item.to"
      class="icon-btn"
    >
      <i :class="item.icon"></i>
    </router-link>
  </nav>
</template>

<style scoped>
.bottom-bar {
  display: flex;
  justify-content: space-around;
  align-items: center;
  background: #2d2f33;
  padding: 0.5rem 0;
  position: fixed;
  bottom: 0;
  width: 100%;
  z-index: 1000;
}

.icon-btn {
  color: white;
  font-size: 1.2rem;
  padding: 0.5rem;
  text-decoration: none;
}
</style>
