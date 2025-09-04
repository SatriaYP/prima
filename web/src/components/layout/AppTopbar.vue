<script setup>
import UserDropDown from "@/components/common/UserDropDown.vue";
import { useAppMenuStore } from "@/stores/appmenu.store";
import BaseBreadcrumb from "../common/BaseBreadcrumb.vue";
// import { useRoute, useRouter } from "vue-router";
// import { computed } from "vue";

// const route = useRoute();
const appmenu = useAppMenuStore();

// const breadcrumbs = computed(() => {
//   return route.matched
//     .filter((r) => r.meta.breadcrumb)
//     .map((r) => ({
//       name: r.meta.breadcrumb,
//       path: r.path,
//     }));
// });
</script>

<template>
  <header class="topbar">
    <div class="topbar-left">
      <h1>{{ appmenu.activeMenu.title }}</h1>
      <BaseBreadcrumb />
      <!-- <div class="breadcrumb">
        <a href="#">Main Page</a>
        <span
          ><svg
            xmlns="http://www.w3.org/2000/svg"
            width="15"
            height="15"
            viewBox="0 0 20 20"
          >
            <path
              fill="none"
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M9 6s6 4.419 6 6s-6 6-6 6"
            /></svg
        ></span>
        <span>Sub Page</span>
      </div> -->
    </div>

    <!-- <div class="topbar-center">
      <div class="search-box">
        <i class="fas fa-search"></i>
        <input type="text" placeholder="Search here..." />
        <i class="fas fa-sliders-h filter-icon"></i>
      </div>
    </div> -->

    <div class="topbar-right">
      <i class="fas fa-moon"></i>
      <i class="fas fa-bell"></i>
      <UserDropDown />

      <!-- <div class="user-info">
        <img src="https://i.pravatar.cc/40?img=3" alt="User" class="avatar" />
        <div class="user-details">
          <span class="user-name">Natasha Bunny</span>
          <span class="user-email">natashabunny@email.com</span>
        </div>
        <i class="fas fa-chevron-down chevron"></i>
      </div> -->
    </div>
  </header>
</template>

<style scoped>
.topbar {
  /* width: 100vw; */
  position: sticky;
  top: 0;
  z-index: 99;
  background: white;
  padding: 12px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  /* border-radius: 12px; */
  /* box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05); */
  gap: 16px;
}

/* Left: Breadcrumb + Title */
.topbar-left {
  display: flex;
  flex-direction: column;
}

.breadcrumb {
  font-size: 13px;
  color: #9ca3af;
  margin-top: 9px;
  display: flex;
  align-items: center;
}

.breadcrumb a {
  color: #3b82f6;
  text-decoration: none;
  margin-right: 2px;
}

.breadcrumb span {
  margin: 0 2px;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.topbar-left h1 {
  font-size: 18px;
  color: #111827;
  font-weight: 600;
  margin: 0;
}

/* Middle: Search */
.topbar-center {
  flex: 1;
  max-width: 400px;
}

.search-box {
  position: relative;
  display: flex;
  align-items: center;
}

.search-box input {
  width: 100%;
  padding: 8px 34px 8px 32px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  font-size: 14px;
  color: #374151;
  background-color: #f9fafb;
  outline: none;
}

.search-box i {
  position: absolute;
  color: #9ca3af;
  font-size: 14px;
}

.search-box .fa-search {
  left: 10px;
}

.search-box .filter-icon {
  right: 10px;
  cursor: pointer;
}

/* Right: Icons + User */
.topbar-right {
  display: flex;
  align-items: center;
  gap: 16px;
  color: #6b7280;
  font-size: 16px;
}

.topbar-right i:hover {
  color: #303747;
  cursor: pointer;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  transition: all 0.3s ease;
}

.avatar:hover {
  transform: scale(1.05);
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
}

@media (max-width: 500px) {
  .user-email {
    display: none;
  }
}
</style>

<!-- <template>
  <header class="topbar">
    <h1 class="logo">MyApp</h1>
  </header>
</template>

<style scoped>
.topbar {
  background-color: #fff;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e2e2e2;
  font-weight: bold;
  font-size: 1.2rem;
}
</style> -->
