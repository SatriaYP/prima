import { computed } from "vue";

export const useAuth = () => {
  const isAuthenticated = computed(() => {
    return localStorage.getItem("token") !== null;
  });

  const logout = () => {
    localStorage.removeItem("token");
  };

  return { isAuthenticated, logout };
};
