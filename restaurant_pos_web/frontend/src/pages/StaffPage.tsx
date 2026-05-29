import { useEffect, useState } from "react";
import api from "../api/client";
import type { AppUser } from "../types";
import { Link } from "react-router-dom";

export default function StaffPage() {
  const [users, setUsers] = useState<AppUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void (async () => {
      try {
        const res = await api.get<AppUser[]>("/users");
        setUsers(res.data);
      } catch {
        alert("Loi tai nhan vien");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await api.get<AppUser[]>("/users");
      setUsers(res.data);
    } catch {
      alert("Loi tai nhan vien");
    } finally {
      setLoading(false);
    }
  };

  const deleteUser = async (id: number) => {
    if (!confirm("Xoa nhan vien nay?")) return;
    try {
      await api.delete(`/users/${id}`);
      fetchUsers();
    } catch {
      alert("Loi khi xoa");
    }
  };

  const getRoleLabel = (role: string) => {
    switch (role.toLowerCase()) {
      case "owner": return { label: "Chủ quán", color: "text-blue-700 bg-blue-100" };
      case "staff": return { label: "Nhân viên", color: "text-green-700 bg-green-100" };
      case "customer": return { label: "Khách hàng", color: "text-amber-700 bg-amber-100" };
      case "admin": return { label: "Admin tổng", color: "text-purple-700 bg-purple-100" };
      default: return { label: role, color: "text-slate-700 bg-slate-100" };
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Quản lý nhân sự</h1>
          <p className="text-slate-500">Danh sách tài khoản thuộc nhà hàng của bạn.</p>
        </div>
        <div className="flex gap-3">
          <div className="bg-blue-50 px-4 py-2 rounded-lg border border-blue-100">
            <span className="text-xs text-blue-600 block uppercase font-bold">Mã nhà hàng</span>
            <code className="text-sm font-mono font-bold text-blue-800">{localStorage.getItem("restaurantId")}</code>
          </div>
          <Link to="/register" className="bg-slate-900 hover:bg-slate-800 text-white px-6 py-2 rounded-lg font-medium transition-colors flex items-center gap-2">
            <span>+ Cấp tài khoản mới</span>
          </Link>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b text-slate-500 text-xs uppercase tracking-wider">
              <tr>
                <th className="px-6 py-4 font-bold">ID</th>
                <th className="px-6 py-4 font-bold">Tên đăng nhập</th>
                <th className="px-6 py-4 font-bold">Vai trò</th>
                <th className="px-6 py-4 font-bold">Chi nhánh</th>
                <th className="px-6 py-4 text-right font-bold">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y text-sm">
              {loading ? (
                <tr>
                  <td colSpan={5} className="px-6 py-10 text-center text-slate-400">Đang tải danh sách...</td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-10 text-center text-slate-400">Chưa có nhân viên nào.</td>
                </tr>
              ) : (
                users.map((u) => {
                  const roleInfo = getRoleLabel(u.role);
                  return (
                    <tr key={u.id} className="hover:bg-slate-50 transition-colors">
                      <td className="px-6 py-4 text-slate-400 font-mono">{u.id}</td>
                      <td className="px-6 py-4 font-medium text-slate-800">{u.username}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2.5 py-0.5 rounded-full text-xs font-bold ${roleInfo.color}`}>
                          {roleInfo.label}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-slate-500">
                        {u.branchId || "—"}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button
                          onClick={() => deleteUser(u.id)}
                          className="text-red-500 hover:text-red-700 font-medium px-3 py-1 rounded-md hover:bg-red-50 transition-colors"
                        >
                          Xóa
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3 items-start">
        <div className="bg-amber-200 p-1 rounded-full text-amber-700">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        </div>
        <p className="text-xs text-amber-800">
          <strong>Lưu ý:</strong> Chủ quán nên cung cấp <strong>Mã nhà hàng</strong> ở trên cho nhân viên để họ tự đăng ký tài khoản, hoặc bạn có thể nhấn "Cấp tài khoản mới" để tạo trực tiếp.
        </p>
      </div>
    </div>
  );
}
