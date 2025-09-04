import { defineStore } from "pinia";
import { computed } from "vue";
import { useRoute } from "vue-router";

export const useAppMenuStore = defineStore("appmenu", () => {
  const route = useRoute();

  const activeMenu = computed(() => {
    if (route.path.startsWith("/dashboard"))
      return { path: "/dashboard", title: "" };
    if (route.path.startsWith("/member"))
      return { path: "/member", title: route.meta.title || "" };
    if (route.path.startsWith("/pengurus"))
      return { path: "/pengurus", title: route.meta.title || "" };
    return "";
  });

  return {
    activeMenu,
  };
});
