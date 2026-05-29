import { useEffect, useState } from "react";
import api from "../api/client";

type Restaurant = {
  id: string;
  name: string;
  ownerId: string;
  status: string;
  isActive: boolean;
  createdAtUtc: string;
};

type SystemStats = {
  totalRestaurants: number;
  totalUsers: number;
  totalOrders: number;
};

export default function SystemAdminPage() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [stats, setStats] = useState<SystemStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [resRestaurants, resStats] = await Promise.all([
        api.get<Restaurant[]>("/system-admin/restaurants"),
        api.get<SystemStats>("/system-admin/stats"),
      ]);
      setRestaurants(resRestaurants.data);
      setStats(resStats.data);
    } catch {
      alert("Lỗi tải dữ liệu hệ thống");
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (id: string) => {
    if (!confirm("Bạn muốn phê duyệt nhà hàng này?")) return;
    try {
      await api.post(`/system-admin/restaurants/${id}/approve`);
      fetchData();
    } catch {
      alert("Lỗi khi phê duyệt");
    }
  };

  const handleReject = async (id: string) => {
    if (!confirm("Bạn muốn từ chối nhà hàng này?")) return;
    try {
      await api.post(`/system-admin/restaurants/${id}/reject`);
      fetchData();
    } catch {
      alert("Lỗi khi từ chối");
    }
  };

  const toggleLock = async (id: string) => {
    try {
      const res = await api.patch<{ isActive: boolean }>(`/system-admin/restaurants/${id}/toggle-lock`, {});
      setRestaurants((prev) => prev.map((r) => (r.id === id ? { ...r, isActive: res.data.isActive } : r)));
    } catch {
      alert("Lỗi thao tác");
    }
  };

  if (loading) return <div className="p-8">Đang tải dữ liệu hệ thống...</div>;

  return (
    <div className="space-y-8">
      <header>
        <h1 className="text-3xl font-bold text-slate-800">Quản trị hệ thống</h1>
        <p className="text-slate-500">Quản lý các nhà hàng và người dùng trên toàn hệ thống.</p>
      </header>

      {/* Thống kê nhanh */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl border shadow-sm">
          <p className="text-sm text-slate-500 uppercase font-semibold">Tổng nhà hàng</p>
          <p className="text-3xl font-bold">{stats?.totalRestaurants}</p>
        </div>
        <div className="bg-white p-6 rounded-xl border shadow-sm">
          <p className="text-sm text-slate-500 uppercase font-semibold">Người dùng</p>
          <p className="text-3xl font-bold">{stats?.totalUsers}</p>
        </div>
        <div className="bg-white p-6 rounded-xl border shadow-sm">
          <p className="text-sm text-slate-500 uppercase font-semibold">Đơn hàng</p>
          <p className="text-3xl font-bold">{stats?.totalOrders}</p>
        </div>
      </div>

      {/* Danh sách nhà hàng */}
      <section className="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div className="p-6 border-b">
          <h2 className="text-xl font-bold">Danh sách nhà hàng</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-slate-500 text-sm uppercase">
              <tr>
                <th className="px-6 py-4">Tên nhà hàng</th>
                <th className="px-6 py-4">Chủ quán</th>
                <th className="px-6 py-4">Trạng thái</th>
                <th className="px-6 py-4">Hoạt động</th>
                <th className="px-6 py-4 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {restaurants.map((r) => (
                <tr key={r.id} className="hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium text-slate-800">{r.name}</td>
                  <td className="px-6 py-4 text-slate-600">{r.ownerId}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-xs font-bold ${
                      r.status === 'Approved' ? 'bg-green-100 text-green-700' :
                      r.status === 'Rejected' ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {r.status}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => toggleLock(r.id)}
                      className={`text-sm font-medium ${r.isActive ? 'text-blue-600' : 'text-red-600'}`}
                    >
                      {r.isActive ? 'Đang mở' : 'Đang khóa'}
                    </button>
                  </td>
                  <td className="px-6 py-4 text-right space-x-2">
                    {r.status === 'Pending' && (
                      <>
                        <button onClick={() => handleApprove(r.id)} className="text-green-600 hover:underline text-sm font-bold">Duyệt</button>
                        <button onClick={() => handleReject(r.id)} className="text-red-600 hover:underline text-sm font-bold">Từ chối</button>
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
