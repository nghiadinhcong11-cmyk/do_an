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
    <div className="min-h-screen bg-slate-100 flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md space-y-8">
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-blue-600 rounded-2xl flex items-center justify-center shadow-lg mb-4">
             <span className="text-white text-3xl font-bold">F</span>
          </div>
          <h2 className="text-3xl font-extrabold text-slate-900">FokaPOS</h2>
          <p className="mt-2 text-sm text-slate-600">Hệ thống quản lý nhà hàng thông minh</p>
        </div>

        <form onSubmit={submit} className="bg-white rounded-3xl p-8 shadow-xl border border-slate-200 space-y-5">
          <h1 className="text-xl font-bold text-slate-800 text-center mb-2">Đăng nhập tài khoản</h1>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase mb-1 ml-1">Tên đăng nhập</label>
            <input
              className="w-full border-2 border-slate-100 rounded-xl px-4 py-3 focus:border-blue-500 focus:ring-0 outline-none transition-all"
              placeholder="Username / Email"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase mb-1 ml-1">Mật khẩu</label>
            <input
              className="w-full border-2 border-slate-100 rounded-xl px-4 py-3 focus:border-blue-500 focus:ring-0 outline-none transition-all"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {error && <p className="text-sm text-red-500 text-center font-medium bg-red-50 py-2 rounded-lg">{error}</p>}

          <button className="w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-4 font-bold text-lg shadow-lg shadow-blue-200 active:scale-[0.98] transition-all">
            Đăng nhập ngay
          </button>

          <div className="flex flex-col items-center space-y-4 pt-4 border-t border-slate-100">
            <p className="text-sm text-slate-600">
              Chưa có tài khoản? <Link className="text-blue-600 font-bold hover:underline" to="/register">Đăng ký mới</Link>
            </p>
            <button
              type="button"
              onClick={handleGuestAccess}
              className="text-sm font-semibold text-slate-500 hover:text-blue-600 transition-colors"
            >
              Tiếp tục với Khách vãng lai →
            </button>
          </div>
        </form>

        <p className="text-center text-xs text-slate-400">© 2024 FokaPOS Team. All rights reserved.</p>
      </div>
    </div>
  );
}
