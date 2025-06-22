<template>
  <div class="main-layout">
    <aside :class="['sidebar', { collapsed: !sidebarOpen }]">
      <div class="sidebar-header">
        <img src="/prima_logo.png" alt="Logo" class="sidebar-logo" />
        <button class="sidebar-toggle" @click="toggleSidebar">
          <svg width="28" height="28" viewBox="0 0 24 24"><path fill="#0057B8" d="M4 6h16M4 12h16M4 18h16" stroke="#0057B8" stroke-width="2" stroke-linecap="round"/></svg>
        </button>
      </div>
      <nav v-if="sidebarOpen">
        <ul>
          <li><router-link to="/dashboard"><span>Dashboard</span></router-link></li>
          <li><router-link to="/members"><span>Anggota</span></router-link></li>
          <li><router-link to="/pengurus"><span>Pengurus</span></router-link></li>
        </ul>
      </nav>
    </aside>
    <div class="content">
      <header class="topbar">
        <div class="topbar-left">
          <button class="sidebar-toggle" @click="toggleSidebar">
            <svg width="28" height="28" viewBox="0 0 24 24"><path fill="#0057B8" d="M4 6h16M4 12h16M4 18h16" stroke="#0057B8" stroke-width="2" stroke-linecap="round"/></svg>
          </button>
        </div>
        <div class="topbar-center">
          <span class="greeting">{{ greeting }}, {{ userDisplayName }}</span>
        </div>
        <div class="topbar-user" @click="toggleDropdown">
          <img :src="avatarUrl" alt="avatar" class="user-avatar" />
          <span class="user-name">{{ userDisplayName }}</span>
          <svg class="arrow-down" width="18" height="18" viewBox="0 0 20 20"><path fill="#0057B8" d="M5.5 8l4.5 4 4.5-4" stroke="#0057B8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          <div v-if="showDropdown" class="dropdown-menu">
            <a href="#" @click.prevent="openProfile">Profile Settings</a>
            <a href="#" @click.prevent="logout">Logout</a>
          </div>
        </div>
      </header>
      <main>
        <router-view/>
      </main>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

export default {
  name: 'MainLayout',
  setup() {
    const router = useRouter();
    const user = ref(null);
    if (localStorage.getItem('user')) {
      user.value = JSON.parse(localStorage.getItem('user'));
    }
    // Sidebar state
    const sidebarOpen = ref(true);
    function toggleSidebar() {
      sidebarOpen.value = !sidebarOpen.value;
    }
    // Greeting sesuai waktu
    function getGreeting() {
      const hour = new Date().getHours();
      if (hour < 12) return 'Selamat Pagi';
      if (hour < 15) return 'Selamat Siang';
      if (hour < 18) return 'Selamat Sore';
      return 'Selamat Malam';
    }
    const greeting = computed(() => getGreeting());
    const userDisplayName = computed(() => user.value ? user.value.username : '');
    const avatarUrl = computed(() => {
      return 'https://ui-avatars.com/api/?name=' + encodeURIComponent(userDisplayName.value) + '&background=0057B8&color=fff&size=128';
    });
    // Dropdown
    const showDropdown = ref(false);
    function toggleDropdown() {
      showDropdown.value = !showDropdown.value;
    }
    function closeDropdown() {
      showDropdown.value = false;
    }
    function openProfile() {
      closeDropdown();
      alert('Profile settings coming soon!');
    }
    function logout() {
      closeDropdown();
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      router.push('/');
    }
    // Tutup dropdown jika klik di luar
    if (typeof window !== 'undefined') {
      window.addEventListener('click', (e) => {
        if (!e.target.closest('.topbar-user')) {
          showDropdown.value = false;
        }
      });
    }
    return { user, userDisplayName, greeting, avatarUrl, showDropdown, toggleDropdown, closeDropdown, openProfile, logout, sidebarOpen, toggleSidebar };
  }
};
</script>

<style scoped>
.main-layout {
  display: flex;
  height: 100vh;
}
.sidebar {
  width: 220px;
  background: #0057B8;
  color: #fff;
  display: flex;
  flex-direction: column;
  padding: 0;
  transition: width 0.2s;
  z-index: 20;
  position: relative;
  min-width: 60px;
}
.sidebar.collapsed {
  width: 60px;
}
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 16px 0 12px;
  border-bottom: 1px solid #004fa1;
  background: #0057B8;
}
.sidebar-logo {
  height: 36px;
  width: auto;
  margin-right: 0;
}
.sidebar-toggle {
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px;
  margin-left: 2px;
  display: flex;
  align-items: center;
}
.sidebar nav {
  margin-top: 14px;
}
.sidebar nav ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.sidebar nav ul li {
  margin: 0;
}
.sidebar nav ul li a {
  display: flex;
  align-items: center;
  padding: 14px 24px;
  color: #fff;
  text-decoration: none;
  font-weight: 500;
  transition: background 0.2s, color 0.2s;
  border-radius: 6px 0 0 6px;
}
.sidebar nav ul li a.router-link-exact-active {
  background: #003e87;
  color: #fff;
}
.sidebar nav ul li a:hover {
  background: #004fa1;
  color: #fff;
}
.sidebar.collapsed nav ul li a span {
  display: none;
}
.sidebar.collapsed nav ul li a {
  justify-content: center;
  padding: 14px 8px;
}
.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.topbar {
  background: #fff;
  padding: 0 32px;
  border-bottom: 1px solid #e0e0e0;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  z-index: 10;
}
.topbar-left {
  display: flex;
  align-items: center;
}
.topbar-logo {
  height: 40px;
  width: auto;
  margin-right: 16px;
}
.topbar-center {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.greeting {
  font-size: 1.1em;
  color: #0057B8;
  font-weight: 500;
  letter-spacing: 0.5px;
}
.topbar-user {
  display: flex;
  align-items: center;
  gap: 10px;
  position: relative;
  cursor: pointer;
  user-select: none;
}
.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 2px solid #0057B8;
  object-fit: cover;
  background: #eee;
}
.user-name {
  font-weight: 500;
  color: #222;
  margin-right: 2px;
}
.arrow-down {
  margin-left: 2px;
  vertical-align: middle;
}
.dropdown-menu {
  position: absolute;
  top: 48px;
  right: 0;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0,87,184,0.10), 0 1px 2px rgba(0,0,0,0.06);
  min-width: 160px;
  padding: 10px 0;
  display: flex;
  flex-direction: column;
  z-index: 100;
  animation: fadeIn 0.2s;
}
.dropdown-menu a {
  padding: 10px 20px;
  color: #0057B8;
  text-decoration: none;
  font-weight: 500;
  transition: background 0.2s;
  cursor: pointer;
}
.dropdown-menu a:hover {
  background: #f0f6ff;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-8px); }
  to { opacity: 1; transform: translateY(0); }
}

main {
  flex: 1;
  padding: 32px;
}
</style>
