import axios from "axios";

// Ưu tiên VITE_API_BASE_URL (có /api) hoặc tự động ghép /api vào VITE_API_ROOT_URL
const getBaseUrl = () => {
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL;
  }
  if (import.meta.env.VITE_API_ROOT_URL) {
    return `${import.meta.env.VITE_API_ROOT_URL}/api`;
  }
  return "http://localhost:5000/api";
};

const api = axios.create({
  baseURL: getBaseUrl(),
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
