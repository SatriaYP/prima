<script setup>
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";

const route = useRoute();
const router = useRouter();

// Buat breadcrumb dari matched route
const breadcrumbs = computed(() =>
  route.matched
    .filter((r) => r.meta && r.meta.title) // hanya route yang punya meta.title
    .map((r) => ({
      title: r.meta.title,
      path: r.path,
    }))
);
</script>

<template>
  <div class="breadcrumb">
    <template v-for="(crumb, index) in breadcrumbs" :key="index">
      <a
        v-if="index !== breadcrumbs.length - 1"
        :href="crumb.path"
        @click.prevent="router.push(crumb.path)"
      >
        {{ crumb.title }}
      </a>
      <span v-else>{{ crumb.title }}</span>

      <span v-if="index !== breadcrumbs.length - 1" class="separator">
        <svg
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
          />
        </svg>
      </span>
    </template>
  </div>
</template>

<style scoped>
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
/* .breadcrumb {
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.breadcrumb a {
  color: #007bff;
  text-decoration: none;
  cursor: pointer;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.breadcrumb .separator {
  color: #888;
}

.breadcrumb span {
  color: #555;
} */
</style>
