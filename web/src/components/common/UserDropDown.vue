<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import AuthService from "@/services/auth.service";
import { useUserStore } from "@/stores/user.store";

const router = useRouter();
const userStore = useUserStore();
const show = ref(false);

const toggleDropdown = () => {
  show.value = !show.value;
};

const closeDropdown = () => {
  show.value = false;
};

const handleAction = (action) => {
  if (action === "logout") {
    logout();
  }
};

const logout = () => {
  AuthService.logout();
  userStore.logout();
  closeDropdown();
  router.push("/login");
};

const menuItems = [
  {
    label: "Profile",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="M14 9h4m-4 3.5h3"/><rect width="20" height="18" x="2" y="3" rx="5"/><path d="M5 16c1.208-2.581 5.712-2.75 7 0m-1.5-7a2 2 0 1 1-4 0a2 2 0 0 1 4 0"/></g></svg>`,
    to: "/profile",
  },
  {
    label: "Settings",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="m21.318 7.141l-.494-.856c-.373-.648-.56-.972-.878-1.101c-.317-.13-.676-.027-1.395.176l-1.22.344c-.459.106-.94.046-1.358-.17l-.337-.194a2 2 0 0 1-.788-.967l-.334-.998c-.22-.66-.33-.99-.591-1.178c-.261-.19-.609-.19-1.303-.19h-1.115c-.694 0-1.041 0-1.303.19c-.261.188-.37.518-.59 1.178l-.334.998a2 2 0 0 1-.789.967l-.337.195c-.418.215-.9.275-1.358.17l-1.22-.345c-.719-.203-1.078-.305-1.395-.176c-.318.129-.505.453-.878 1.1l-.493.857c-.35.608-.525.911-.491 1.234c.034.324.268.584.736 1.105l1.031 1.153c.252.319.431.875.431 1.375s-.179 1.056-.43 1.375l-1.032 1.152c-.468.521-.702.782-.736 1.105s.14.627.49 1.234l.494.857c.373.647.56.971.878 1.1s.676.028 1.395-.176l1.22-.344a2 2 0 0 1 1.359.17l.336.194c.36.23.636.57.788.968l.334.997c.22.66.33.99.591 1.18c.262.188.609.188 1.303.188h1.115c.694 0 1.042 0 1.303-.189s.371-.519.59-1.179l.335-.997c.152-.399.428-.738.788-.968l.336-.194c.42-.215.9-.276 1.36-.17l1.22.344c.718.204 1.077.306 1.394.177c.318-.13.505-.454.878-1.101l.493-.857c.35-.607.525-.91.491-1.234s-.268-.584-.736-1.105l-1.031-1.152c-.252-.32-.431-.875-.431-1.375s.179-1.056.43-1.375l1.032-1.153c.468-.52.702-.781.736-1.105s-.14-.626-.49-1.234"/><path d="M15.52 12a3.5 3.5 0 1 1-7 0a3.5 3.5 0 0 1 7 0"/></g></svg>`,
    to: "/settings",
  },
  {
    label: "Logout",
    icon: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17.625c-.074 1.852-1.617 3.424-3.684 3.374c-.481-.012-1.076-.18-2.265-.515c-2.861-.807-5.345-2.164-5.941-5.203C3 14.724 3 14.095 3 12.837v-1.674c0-1.257 0-1.886.11-2.445c.596-3.038 3.08-4.395 5.941-5.202c1.19-.335 1.784-.503 2.265-.515c2.067-.05 3.61 1.522 3.684 3.374M21 12H10m11 0c0-.7-1.994-2.008-2.5-2.5M21 12c0 .7-1.994 2.008-2.5 2.5"/></svg>`,
    action: "logout",
  },
];
// const menuItems = [
//   { label: "Profile", icon: "fas fa-user", to: "/profile" },
//   { label: "Settings", icon: "fas fa-cog", to: "/settings" },
//   { label: "Logout", icon: "fas fa-sign-out-alt", action: "logout" },
// ];
</script>
<template>
  <div
    class="user-dropdown"
    @click="toggleDropdown"
    v-click-outside="closeDropdown"
  >
    <img src="https://i.pravatar.cc/40?img=3" alt="User" class="avatar" />
    <div class="user-details">
      <span class="user-name">{{
        userStore.user?.username || "Your Name"
      }}</span>
      <span class="user-email">{{
        userStore.user?.email || "your@email.com"
      }}</span>
    </div>
    <i class="fas fa-chevron-down chevron"></i>

    <div v-if="show" class="dropdown-menu">
      <template v-for="(item, index) in menuItems" :key="index">
        <RouterLink
          v-if="item.to"
          :to="item.to"
          class="dropdown-item"
          @click.stop="closeDropdown"
        >
          <!-- <i :class="item.icon"></i> -->
          <span v-html="item.icon"></span>

          {{ item.label }}
        </RouterLink>
        <button
          v-else
          class="dropdown-item"
          @click.stop="handleAction(item.action)"
        >
          <!-- <i :class="item.icon"></i> -->
          <span v-html="item.icon"></span>
          {{ item.label }}
        </button>
      </template>
    </div>

    <!-- <div v-if="show" class="dropdown-menu">
      <a href="#">Profile</a>
      <a href="#">Settings</a>
      <a href="#">Logout</a>
    </div> -->
  </div>
</template>

<style scoped>
.user-dropdown {
  display: flex;
  align-items: center;
  gap: 8px;
  position: relative;
  cursor: pointer;
  padding: 5px;
  border-radius: 50px;
  background-color: #f7f7f7;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
}

.user-details {
  display: flex;
  flex-direction: column;
  font-size: 12px;
  line-height: 1.2;
}

.user-name {
  font-weight: 500;
  color: #111827;
}

.user-email {
  color: #6b7280;
  font-size: 11px;
}

.chevron {
  font-size: 12px;
  color: #9ca3af;
  margin: 0px 10px;
}

.dropdown-menu {
  position: absolute;
  top: 130%;
  right: 0;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 8px 5px;
  /* padding-left: 1px; */
  width: 150px;
  z-index: 100;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  font-size: 14px;
  color: #333;
  text-decoration: none;
  transition: background 0.2s;
  width: 100%;
  background: none;
  border: none;
  text-align: left;
  cursor: pointer;
}

.dropdown-item:hover {
  background-color: #f0f0f0;
  border-radius: 5px;
}

/* .dropdown-menu a {
  display: block;
  padding: 8px 16px;
  font-size: 14px;
  color: #374151;
  text-decoration: none;
}

.dropdown-menu a:hover {
  background-color: #f3f4f6;
} */
</style>
