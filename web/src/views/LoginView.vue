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
          <div class="password-input-container">
            <input 
              v-model="password" 
              :type="showPassword ? 'text' : 'password'" 
              required 
              autocomplete="current-password" 
            />
            <button 
              type="button" 
              class="password-toggle" 
              @click="togglePassword"
              :title="showPassword ? 'Sembunyikan password' : 'Tampilkan password'"
            >
              <svg v-if="showPassword" class="eye-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21"></path>
              </svg>
              <svg v-else class="eye-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
              </svg>
            </button>
          </div>
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
      error: '',
      showPassword: false
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
    },
    togglePassword() {
      this.showPassword = !this.showPassword;
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

.password-input-container {
  position: relative;
  display: flex;
  align-items: center;
}

.password-input-container input {
  padding-right: 45px;
  width: 100%;
}

.password-toggle {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: #666;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.password-toggle:hover {
  background: #f5f5f5;
  color: #0057B8;
}

.password-toggle:focus {
  outline: none;
  background: #f0f8ff;
  color: #0057B8;
}

.eye-icon {
  width: 20px;
  height: 20px;
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
