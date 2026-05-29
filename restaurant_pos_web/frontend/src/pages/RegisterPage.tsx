import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api/client";
import { saveAuthSession } from "../api/authStorage";
import type { AuthResponse, UserRole } from "../types";

export default function RegisterPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [restaurantId, setRestaurantId] = useState("");
  const [restaurantName, setRestaurantName] = useState("");
  const [branchId, setBranchId] = useState("");
  const [role, setRole] = useState<UserRole>("owner");
  const [adminCode, setAdminCode] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    let finalRole = role;
    let finalRestaurantName = restaurantName;

    if (adminCode === "FOKA@ADMIN") {
      finalRole = "admin" as UserRole;
      finalRestaurantName = "Hệ thống POS";
    }

    if (finalRole === "customer" && !finalRestaurantName) {
      finalRestaurantName = "CustomerAccount";
    }

    try {
      const { data } = await api.post<AuthResponse>("/auth/register", {
        username,
        password,
        restaurantId: restaurantId || null,
        restaurantName: finalRestaurantName || null,
        branchId: branchId || null,
        role: finalRole,
        adminCode: adminCode || null,
      });
      saveAuthSession(data);
      navigate("/");
    } catch {
      setError("Đăng ký thất bại. Tên đăng nhập có thể đã tồn tại.");
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center px-4 py-8 md:py-12">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center mb-4">
           <h2 className="text-2xl md:text-3xl font-extrabold text-slate-900 leading-tight">Tham gia FokaPOS</h2>
           <p className="mt-2 text-sm text-slate-600 px-4 text-center">Giải pháp vận hành quán ăn tối ưu</p>
        </div>

        <form onSubmit={submit} className="bg-white rounded-3xl p-6 md:p-8 shadow-xl border border-slate-200 space-y-4">
          <h1 className="text-lg md:text-xl font-bold text-slate-800 text-center mb-2">Đăng ký tài khoản</h1>

          <div className="flex bg-slate-100 p-1 rounded-xl mb-4 overflow-x-auto">
            <button
              type="button"
              onClick={() => setRole("owner")}
              className={`flex-1 min-w-fit px-2 py-2 text-[10px] md:text-xs font-bold rounded-lg transition-all ${role === 'owner' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'}`}
            >
              CHỦ QUÁN
            </button>
            <button
              type="button"
              onClick={() => setRole("customer")}
              className={`flex-1 min-w-fit px-2 py-2 text-[10px] md:text-xs font-bold rounded-lg transition-all ${role === 'customer' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'}`}
            >
              KHÁCH HÀNG
            </button>
            <button
              type="button"
              onClick={() => setRole("staff")}
              className={`flex-1 min-w-fit px-2 py-2 text-[10px] md:text-xs font-bold rounded-lg transition-all ${role === 'staff' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'}`}
            >
              NHÂN VIÊN
            </button>
          </div>

          <div className="space-y-3">
            <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all text-base" placeholder="Tên đăng nhập" value={username} onChange={(e) => setUsername(e.target.value)} required />
            <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all text-base" type="password" placeholder="Mật khẩu" value={password} onChange={(e) => setPassword(e.target.value)} required />

            {role === 'owner' ? (
              <input className="w-full border-2 border-blue-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-blue-50/30 focus:bg-white transition-all text-base" placeholder="Tên quán của bạn" value={restaurantName} onChange={(e) => setRestaurantName(e.target.value)} required />
            ) : role === 'staff' ? (
              <div className="space-y-3">
                <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all font-mono text-sm" placeholder="Mã nhà hàng (ID)" value={restaurantId} onChange={(e) => setRestaurantId(e.target.value)} required />
                <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all text-base" placeholder="Mã chi nhánh (Tùy chọn)" value={branchId} onChange={(e) => setBranchId(e.target.value)} />
              </div>
            ) : (
              <input className="w-full border-2 border-green-50 rounded-xl px-4 py-3 focus:border-green-500 outline-none bg-green-50/30 focus:bg-white transition-all text-base" placeholder="Họ và tên của bạn" value={restaurantName} onChange={(e) => setRestaurantName(e.target.value)} />
            )}

            <input className="w-full border-2 border-slate-50 border-dashed rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all text-[10px]" placeholder="Mã kích hoạt Admin (nếu có)" value={adminCode} onChange={(e) => setAdminCode(e.target.value)} />
          </div>

          {error && <p className="text-sm text-red-500 text-center font-medium bg-red-50 py-2 rounded-lg px-2">{error}</p>}

          <button className="w-full bg-slate-900 hover:bg-black text-white rounded-xl py-4 font-bold text-lg shadow-lg active:scale-[0.98] transition-all mt-4">
            Đăng ký ngay
          </button>

          <p className="text-sm text-slate-600 text-center pt-2">
            Đã có tài khoản? <Link className="text-blue-600 font-bold hover:underline" to="/login">Đăng nhập</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
