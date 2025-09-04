<script setup>
import { ref } from "vue";
import BaseInput from "../common/BaseInput.vue";
import BaseButton from "../common/BaseButton.vue";

const phone = ref("");
const phoneError = ref("");
const loading = ref(false);

function handleLogin() {
  phoneError.value = "";
  loading.value = true;

  if (!/^628[0-9]{8,12}$/.test(phone.value)) {
    phoneError.value = "Nomor tidak valid. Gunakan format 628xxx";
    loading.value = false;
    return;
  }

  // Simulasi delay login
  setTimeout(() => {
    alert(`Logging in with phone: ${phone.value}`);
    loading.value = false;
  }, 1000);
}
</script>

<template>
  <form class="login-form" @submit.prevent="handleLogin">
    <h2>Hello,</h2>
    <p class="subtitle">Please enter your mobile number</p>

    <BaseInput
      v-model="phone"
      type="tel"
      placeholder="e.g. 6281234567890"
      icon="fas fa-phone"
      :error="phoneError"
      required
    />

    <BaseButton type="submit" :loading="loading" icon="fas fa-arrow-right">
      Continue
    </BaseButton>
  </form>
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
