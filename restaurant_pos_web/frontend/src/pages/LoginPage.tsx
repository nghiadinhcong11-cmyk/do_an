import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api/client";
import { saveAuthSession } from "../api/authStorage";
import type { AuthResponse } from "../types";

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    try {
      const { data } = await api.post<AuthResponse>("/auth/login", { username, password });
      saveAuthSession(data);
      navigate("/");
    } catch {
      setError("Sai tên đăng nhập hoặc mật khẩu.");
    }
  };

  const handleGuestAccess = () => {
    // Guest access logic - navigate to a public part of the app or home
    // For now, we clear storage and go home as guest
    localStorage.removeItem("auth_session");
    navigate("/");
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center px-4">
      <form onSubmit={submit} className="w-full max-w-md bg-white rounded-2xl p-8 shadow-lg space-y-4">
        <h1 className="text-2xl font-bold text-slate-800 text-center">Đăng nhập FokaPOS</h1>
        <input className="w-full border rounded-lg px-3 py-2" placeholder="Tên đăng nhập" value={username} onChange={(e) => setUsername(e.target.value)} required />
        <input className="w-full border rounded-lg px-3 py-2" type="password" placeholder="Mật khẩu" value={password} onChange={(e) => setPassword(e.target.value)} required />

        {error && <p className="text-sm text-red-600 text-center">{error}</p>}

        <button className="w-full bg-blue-600 hover:bg-blue-700 text-white rounded-lg py-2 font-medium transition-colors">Đăng nhập</button>

        <div className="flex flex-col items-center space-y-2 pt-2">
          <p className="text-sm text-slate-600">Chưa có tài khoản? <Link className="text-blue-600 font-semibold" to="/register">Đăng ký ngay</Link></p>
          <button
            type="button"
            onClick={handleGuestAccess}
            className="text-sm text-slate-500 hover:text-slate-800 underline transition-colors"
          >
            Vào với tư cách Khách vãng lai
          </button>
        </div>
      </form>
    </div>
  );
}
