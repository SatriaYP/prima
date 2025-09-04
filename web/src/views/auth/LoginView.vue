<script setup>
import BaseButton from "@/components/common/BaseButton.vue";
import BaseInput from "@/components/common/BaseInput.vue";
import { ref } from "vue";
import AuthService from "@/services/auth.service";
import { useRouter } from "vue-router";
import { useUserStore } from "@/stores/user.store";
import { useAlert } from "@/composables/useAlert";
const { showAlert } = useAlert();

// const phone = ref("");
const phoneError = ref("");
const username = ref("");
const usernameError = ref("");
const password = ref("");
const loading = ref(false);
// const error = ref(null);

const router = useRouter();
const userStore = useUserStore();

async function handleLogin() {
  phoneError.value = "";
  loading.value = true;

  //   if (!/^628[0-9]{8,12}$/.test(phone.value)) {
  //     phoneError.value = "Nomor tidak valid. Gunakan format 628xxx";
  //     loading.value = false;
  //     return;
  //   }
  try {
    const { user } = await AuthService.login(username.value, password.value);
    userStore.setUser(user);
    router.push("/dashboard");
    showAlert("Login berhasil!", "success");
  } catch (error) {
    // error.value = error.message;
    console.log(error.message);
  } finally {
    loading.value = false;
  }

  // Simulasi delay login
  // setTimeout(() => {
  //   alert(`Logging in with phone: ${phone.value}`);
  //   loading.value = false;
  // }, 1000);
}
</script>

<template>
  <div class="login-form">
    <div class="login-logo">
      <img src="/images/prima_logo.png" alt="" />
    </div>
    <h2>Login</h2>
    <p class="subtitle">Please enter your account credentials.</p>
    <form @submit.prevent="handleLogin">
      <BaseInput
        v-model="username"
        type="text"
        placeholder="Your username"
        icon="fas fa-user"
        :error="usernameError"
        required
      />
      <BaseInput
        v-model="password"
        type="password"
        placeholder="Your password"
        icon="fas fa-eye"
        required
      />
      <!-- <BaseInput
      v-model="phone"
      type="tel"
      placeholder="e.g. 6281234567890"
      icon="fas fa-phone"
      :error="phoneError"
      required
    /> -->

      <BaseButton type="submit" :loading="loading"> Login </BaseButton>
    </form>
  </div>
</template>

<style scoped>
.login-form {
  width: 100%;
  max-width: 400px;
  background: #fff;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.login-logo {
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 20px;
  margin-top: -70px;
  margin-bottom: 20px;
}

.login-logo img {
  border-radius: 12px;
  width: 200px;
}

.login-form form {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.login-form h2 {
  margin: 0;
  font-size: 1.8rem;
  color: #333;
}

.subtitle {
  color: #777;
  font-size: 1rem;
}
</style>
