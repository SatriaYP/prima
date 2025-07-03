import axios from 'axios';

// Environment-based API configuration
const getApiBaseUrl = () => {
  const hostname = window.location.hostname;
  
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    return 'http://localhost:4000/api';
  } else if (hostname.includes('staging')) {
    return 'https://web-staging.partaiprima.id/api';
  } else if (hostname.includes('partaiprima.id')) {
    return 'https://web.partaiprima.id/api';
  } else {
    // Fallback untuk development
    return 'http://localhost:4000/api';
  }
};

const api = axios.create({
  baseURL: getApiBaseUrl(),
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
