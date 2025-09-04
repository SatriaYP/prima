<script setup>
// import { ref } from "vue";
import { useAppMenuStore } from "@/stores/appmenu.store";

defineProps({
  collapsed: Boolean,
});

const appmenu = useAppMenuStore();

// const collapsed = ref(false);
const menu = [
  {
    name: "Dashboard",
    to: "/dashboard",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="M15 17c-.8.622-1.85 1-3 1s-2.2-.378-3-1"/><path d="M2.352 13.214c-.354-2.298-.53-3.446-.096-4.465s1.398-1.715 3.325-3.108L7.021 4.6C9.418 2.867 10.617 2 12.001 2c1.382 0 2.58.867 4.978 2.6l1.44 1.041c1.927 1.393 2.89 2.09 3.325 3.108c.434 1.019.258 2.167-.095 4.464l-.301 1.96c-.5 3.256-.751 4.884-1.919 5.856S16.554 22 13.14 22h-2.28c-3.415 0-5.122 0-6.29-.971c-1.168-.972-1.418-2.6-1.918-5.857z"/></g></svg>`,
  },
  {
    name: "Anggota",
    to: "/member",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 19.5c0-1.657-2.239-3-5-3s-5 1.343-5 3m14-3c0-1.23-1.234-2.287-3-2.75M3 16.5c0-1.23 1.234-2.287 3-2.75m12-4.014a3 3 0 1 0-4-4.472M6 9.736a3 3 0 0 1 4-4.472m2 8.236a3 3 0 1 1 0-6a3 3 0 0 1 0 6"/></svg>`,
  },
  {
    name: "Pengurus",
    to: "/pengurus",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="M9.713 3.64c.581-.495.872-.743 1.176-.888a2.58 2.58 0 0 1 2.222 0c.304.145.595.393 1.176.888c.599.51 1.207.768 2.007.831c.761.061 1.142.092 1.46.204c.734.26 1.312.837 1.571 1.572c.112.317.143.698.204 1.46c.063.8.32 1.407.83 2.006c.496.581.744.872.889 1.176c.336.703.336 1.52 0 2.222c-.145.304-.393.595-.888 1.176a3.3 3.3 0 0 0-.831 2.007c-.061.761-.092 1.142-.204 1.46a2.58 2.58 0 0 1-1.572 1.571c-.317.112-.698.143-1.46.204c-.8.063-1.407.32-2.006.83c-.581.496-.872.744-1.176.889a2.58 2.58 0 0 1-2.222 0c-.304-.145-.595-.393-1.176-.888a3.3 3.3 0 0 0-2.007-.831c-.761-.061-1.142-.092-1.46-.204a2.58 2.58 0 0 1-1.571-1.572c-.112-.317-.143-.698-.204-1.46a3.3 3.3 0 0 0-.83-2.006c-.496-.581-.744-.872-.89-1.176a2.58 2.58 0 0 1 .001-2.222c.145-.304.393-.595.888-1.176c.52-.611.769-1.223.831-2.007c.061-.761.092-1.142.204-1.46a2.58 2.58 0 0 1 1.572-1.571c.317-.112.698-.143 1.46-.204a3.3 3.3 0 0 0 2.006-.83"/><path d="M14.5 9.25a2.5 2.5 0 1 1-5 0a2.5 2.5 0 0 1 5 0M17 19.2c-.317-6.187-9.683-6.187-10 0"/></g></svg>`,
  },
  {
    name: "kepengurusan",
    to: "/kepengurusan",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="M5 20.25c0 .414.336.75.75.75h10.652C17.565 21 18 20.635 18 19.4v-1.445M5 20.25A2.25 2.25 0 0 1 7.25 18h10.152q.339 0 .598-.045M5 20.25V6.2c0-1.136-.072-2.389 1.092-2.982C6.52 3 7.08 3 8.2 3h9.2c1.236 0 1.6.437 1.6 1.6v11.8c0 .995-.282 1.425-1 1.555"/><path d="M15 14c0-3.861-6-3.861-6 0"/><path d="M12 11a2 2 0 1 0 0-4a2 2 0 0 0 0 4"/></g></svg>`,
  },
];
// const menu = [
//   { name: "Dashboard", to: "/dashboard", icon: "fas fa-home" },
//   { name: "Anggota", to: "/member", icon: "fas fa-users" },
//   { name: "Pengurus", to: "/pengurus", icon: "fas fa-cog" },
// ];
</script>

<template>
  <aside :class="['sidebar', { collapsed }]">
    <div class="sidebar-header">
      <!-- <button class="toggle-btn" @click="collapsed = !collapsed"> -->
      <button class="toggle-btn" @click="$emit('toggle')">
        <!-- <i class="fas fa-bars"></i> -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="21"
          height="21"
          viewBox="0 0 24 24"
        >
          <path
            fill="none"
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M15 3.5v17M3 9.4c0-2.24 0-3.36.436-4.216a4 4 0 0 1 1.748-1.748C6.04 3 7.16 3 9.4 3h5.2c2.24 0 3.36 0 4.216.436a4 4 0 0 1 1.748 1.748C21 6.04 21 7.16 21 9.4v5.2c0 2.24 0 3.36-.436 4.216a4 4 0 0 1-1.748 1.748C17.96 21 16.84 21 14.6 21H9.4c-2.24 0-3.36 0-4.216-.436a4 4 0 0 1-1.748-1.748C3 17.96 3 16.84 3 14.6z"
          />
        </svg>
      </button>
      <img
        src="/images/prima_logo.png"
        alt="Logo"
        :class="['logo', { collapsed }]"
      />
    </div>

    <!-- <button class="toggle-btn" @click="collapsed = !collapsed">
      <i class="fas fa-bars"></i>
    </button> -->

    <nav>
      <ul>
        <li
          v-for="item in menu"
          :key="item.name"
          class="menu-item"
          :class="{ active: appmenu.activeMenu.path === item.to }"
        >
          <router-link :to="item.to" class="tooltip-container">
            <!-- <i :class="[item.icon, 'menu-icon']"></i> -->
            <span class="menu-icon" v-html="item.icon"></span>
            <span v-if="!collapsed" class="label">{{ item.name }}</span>
            <span v-else class="tooltip">{{ item.name }}</span>
          </router-link>
        </li>
        <!-- <li
          v-for="item in menu"
          :key="item.name"
          class="menu-item"
          :class="{ active: $route.path === item.to }"
        >
          <router-link :to="item.to" class="tooltip-container">
            <span class="menu-icon" v-html="item.icon"></span>
            <span v-if="!collapsed" class="label">{{ item.name }}</span>
            <span v-else class="tooltip">{{ item.name }}</span>
          </router-link>
        </li> -->
      </ul>
    </nav>
  </aside>
</template>

<!-- <template>
  <aside :class="['sidebar', { collapsed }]">
    <button class="toggle-btn" @click="collapsed = !collapsed">
      <i class="fas fa-bars"></i>
    </button>

    <nav>
      <ul>
        <li v-for="item in menu" :key="item.name" class="menu-item">
          <router-link :to="item.to" class="tooltip-container">
            <i :class="item.icon"></i>
            <span v-if="!collapsed" class="label">{{ item.name }}</span>
            <span v-else class="tooltip">{{ item.name }}</span>
          </router-link>
        </li>
      </ul>
    </nav>
  </aside>
</template> -->

<style scoped>
.sidebar {
  width: 220px;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 100;
  /* overflow-y: auto; */
  /* background: #292424;
  color: #fff; */
  background: #fff;
  color: #575757;
  transition: width 0.3s ease;
  padding: 0.5rem;
  padding-top: 1rem;
  border-right: 1px solid #e6e6e6;
}

.sidebar.collapsed {
  width: 70px;
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: start;
  padding: 0 1rem;
  gap: 1rem;
  margin-bottom: 2rem;
  /* background-color: #00bcd4; */
}

.logo {
  height: 42px;
  transition: transform 0.3s;
  border-radius: 10px;
}

.logo.collapsed {
  display: none;
}

.toggle-btn {
  background: none;
  /* color: white; */
  color: #575757;
  border: none;
  padding: 0.5rem;
  /* margin-left: 1rem; */
  cursor: pointer;
}

nav li {
  list-style: none;
}

.menu-item {
  margin: 0.5rem 0;
}

.menu-item.active .tooltip-container {
  /* background: #444; */
  background: #e6e4e4;
  font-weight: bold;
  border-left: 4px solid #1a4bd4;
  border-radius: 10px;
}

.menu-item.active .tooltip {
  font-weight: bold;
  background-color: #1a4bd4;
  color: #fff;
}

.tooltip-container {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.5rem 1rem;
  /* color: white; */
  color: #575757;
  text-decoration: none;
  position: relative;
  transition: background 0.2s;
  /* background: #1a4bd4; */
}

.menu-icon {
  transition: transform 0.3s ease;
  /* background: #af7272; */
  display: flex;
  align-items: center;
  justify-content: center;
}

.toggle-btn:hover,
.tooltip-container:hover {
  background: #eeeeee;
  border-radius: 10px;
}
.tooltip-container:hover .menu-icon {
  transform: rotate(12deg);
}

.label {
  font-size: 14px;
  margin-top: -2px;
  /* background-color: aquamarine; */
}

.tooltip {
  position: absolute;
  left: 73px;
  background: #444;
  color: #fff;
  padding: 0.3rem 0.6rem;
  border-radius: 6px;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transform: translateY(-45%);
  top: 50%;
  transition: opacity 0.2s;
  font-size: 14px;
}

.sidebar.collapsed .tooltip-container:hover .tooltip {
  opacity: 1;
}

/* .sidebar {
  width: 220px;
  background: #2d2f33;
  color: #fff;
  transition: width 0.3s ease;
  padding-top: 1rem;
}

.sidebar.collapsed {
  width: 70px;
}

.toggle-btn {
  background: none;
  color: white;
  border: none;
  padding: 0.5rem;
  margin-left: 1rem;
  cursor: pointer;
}

.menu-item {
  margin: 1rem 0;
}

.tooltip-container {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem 1rem;
  color: white;
  text-decoration: none;
  position: relative;
}

.tooltip {
  position: absolute;
  left: 70px;
  background: #444;
  padding: 0.3rem 0.6rem;
  border-radius: 4px;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transform: translateY(-50%);
  top: 50%;
  transition: opacity 0.2s;
}

.sidebar.collapsed .tooltip-container:hover .tooltip {
  opacity: 1;
} */
</style>
