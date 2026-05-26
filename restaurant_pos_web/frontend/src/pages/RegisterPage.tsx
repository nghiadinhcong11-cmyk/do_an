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
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    try {
      const { data } = await api.post<AuthResponse>("/auth/register", {
        username,
        password,
        restaurantId: restaurantId || null,
        restaurantName: restaurantName || null,
        branchId: branchId || null,
        role,
      });
      saveAuthSession(data);
      navigate("/");
    } catch {
      setError("Registration failed. Username may exist or role is not allowed.");
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center px-4">
      <form onSubmit={submit} className="w-full max-w-md bg-white rounded-2xl p-8 shadow-lg space-y-4">
        <h1 className="text-2xl font-bold text-slate-800">Đăng ký tài khoản</h1>
        <input className="w-full border rounded-lg px-3 py-2" placeholder="Tên đăng nhập" value={username} onChange={(e) => setUsername(e.target.value)} />
        <input className="w-full border rounded-lg px-3 py-2" type="password" placeholder="Mật khẩu" value={password} onChange={(e) => setPassword(e.target.value)} />

        <div>
          <label className="text-xs text-slate-500 mb-1 block">Bạn là ai?</label>
          <select className="w-full border rounded-lg px-3 py-2" value={role} onChange={(e) => setRole(e.target.value as UserRole)}>
            <option value="owner">Chủ quán (Tạo quán mới)</option>
            <option value="manager">Quản lý (Vào quán đã có)</option>
            <option value="staff">Nhân viên (Vào quán đã có)</option>
          </select>
        </div>

        {role === 'owner' ? (
          <input className="w-full border rounded-lg px-3 py-2 bg-blue-50" placeholder="Tên quán của bạn" value={restaurantName} onChange={(e) => setRestaurantName(e.target.value)} />
        ) : (
          <>
            <input className="w-full border rounded-lg px-3 py-2" placeholder="Mã nhà hàng (Restaurant ID)" value={restaurantId} onChange={(e) => setRestaurantId(e.target.value)} />
            <input className="w-full border rounded-lg px-3 py-2" placeholder="Mã chi nhánh (Branch ID - tùy chọn)" value={branchId} onChange={(e) => setBranchId(e.target.value)} />
          </>
        )}

        {error && <p className="text-sm text-red-600">{error}</p>}
        <button className="w-full bg-slate-900 text-white rounded-lg py-2 font-medium">Đăng ký ngay</button>
        <p className="text-sm text-slate-600">Đã có tài khoản? <Link className="text-blue-600" to="/login">Đăng nhập</Link></p>
      </form>
    </div>
  );
}
