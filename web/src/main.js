import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./App.vue";
import router from "./router";
import "./assets/styles/main.css";
import clickOutside from "@/directives/clickOutside";

const app = createApp(App);
const pinia = createPinia();

// Aktifkan devtools hanya saat development
if (process.env.NODE_ENV === "development") {
  app.config.devtools = true;
}

app.directive("click-outside", clickOutside);
app.use(router);
app.use(pinia);
app.mount("#app");
