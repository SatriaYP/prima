<template>
  <div class="login-bg">
    <div class="login-card">
      <img src="/prima_logo.png" alt="PRIMA Logo" class="prima-logo" />
      <h1 class="prima-title">PRIMA ID</h1>
      <h2 class="prima-subtitle">Membership Management System</h2>
      <form @submit.prevent="handleLogin" class="login-form">
        <div class="input-group">
          <label>Username</label>
          <input v-model="username" type="text" required autocomplete="username" />
        </div>
        <div class="input-group">
          <label>Password</label>
          <input v-model="password" type="password" required autocomplete="current-password" />
        </div>
        <button type="submit" class="login-btn">Login</button>
        <div v-if="error" class="error">{{ error }}</div>
        <div class="login-links">
          <a href="#" class="forgot-link">Forgot Password?</a>
          <span>|</span>
          <a href="#" class="register-link">Register</a>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import api from '../services/api';

export default {
  name: 'LoginView',
  data() {
    return {
      username: '',
      password: '',
      error: ''
    };
  },
  methods: {
    async handleLogin() {
      this.error = '';
      try {
        const response = await api.post('/auth/login', {
          username: this.username,
          password: this.password
        });
        const { token, user } = response.data;
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
        this.$router.push('/dashboard');
      } catch (err) {
        this.error = err.response?.data?.message || 'Login gagal. Periksa username/password.';
      }
    }
  }
};
</script>

<style scoped>
.login-bg {
  min-height: 100vh;
  background: #0057B8;
  display: flex;
  align-items: center;
  justify-content: center;
}
.login-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 87, 184, 0.08), 0 1.5px 4px rgba(0,0,0,0.07);
  padding: 40px 32px 32px 32px;
  max-width: 380px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.prima-logo {
  width: 120px;
  height: auto;
  margin-bottom: 16px;
}
.prima-title {
  font-size: 2.1rem;
  font-weight: bold;
  color: #0057B8;
  margin-bottom: 4px;
  letter-spacing: 2px;
}
.prima-subtitle {
  font-size: 1.1rem;
  color: #333;
  margin-bottom: 32px;
  font-weight: 500;
  letter-spacing: 1px;
}
.login-form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 18px;
}
.input-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.input-group label {
  font-weight: 500;
  color: #0057B8;
}
.input-group input {
  padding: 10px 14px;
  border: 1.5px solid #d0d7e2;
  border-radius: 8px;
  font-size: 1rem;
  outline: none;
  transition: border 0.2s;
}
.input-group input:focus {
  border: 1.5px solid #0057B8;
}
.login-btn {
  background: #0057B8;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 12px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  margin-top: 10px;
  transition: background 0.2s;
}
.login-btn:hover {
  background: #003e87;
}
.error {
  color: #e74c3c;
  background: #fff2f1;
  padding: 8px 12px;
  border-radius: 6px;
  margin-top: 2px;
  font-size: 0.98rem;
  text-align: center;
}
.login-links {
  margin-top: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 0.96rem;
}
.login-links a {
  color: #0057B8;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}
.login-links a:hover {
  color: #003e87;
}
.login-links span {
  color: #aaa;
  font-size: 1.1em;
}

</style>
