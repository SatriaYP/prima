import axios from 'axios';

// Ganti baseURL sesuai alamat backend API kamu
const api = axios.create({
  baseURL: 'http://localhost:4000/api',
  timeout: 60000, // 60 detik untuk proses OCR yang membutuhkan waktu lama
});

// Interceptor untuk menambahkan Authorization header jika ada token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
