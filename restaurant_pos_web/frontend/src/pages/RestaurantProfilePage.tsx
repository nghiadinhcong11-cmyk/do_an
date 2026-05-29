import { useEffect, useState } from "react";
import api from "../api/client";

type Restaurant = {
  id: string;
  name: string;
  address?: string;
  contactPhone?: string;
  status: string;
};

export default function RestaurantProfilePage() {
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [name, setName] = useState("");
  const [address, setAddress] = useState("");
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const res = await api.get<Restaurant>("/restaurant/my-restaurant");
      setRestaurant(res.data);
      setName(res.data.name);
      setAddress(res.data.address || "");
      setPhone(res.data.contactPhone || "");
    } catch {
      setMessage("Không thể tải thông tin nhà hàng.");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setMessage("");
    try {
      await api.put("/restaurant/update-profile", { name, address, contactPhone: phone });
      setMessage("Cập nhật thành công! Vui lòng chờ Admin phê duyệt.");
      fetchProfile();
    } catch {
      setMessage("Lỗi khi lưu thông tin.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="p-8">Đang tải...</div>;

  return (
    <div className="max-w-4xl mx-auto mt-10 space-y-6">
      <div className="bg-white rounded-2xl shadow-sm border p-8">
        <div className="flex justify-between items-start mb-6">
          <div>
            <h1 className="text-2xl font-bold mb-1">Thông tin nhà hàng</h1>
            <p className="text-slate-500">Quản lý thông tin cơ bản và mã định danh để nhân viên tham gia.</p>
          </div>
          <div className="text-right">
            <span className={`px-3 py-1 rounded-full text-sm font-bold ${
              restaurant?.status === 'Approved' ? 'bg-green-100 text-green-700' :
              restaurant?.status === 'Rejected' ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700'
            }`}>
              {restaurant?.status === 'Approved' ? 'Đã duyệt' : restaurant?.status === 'Rejected' ? 'Từ chối' : 'Chờ phê duyệt'}
            </span>
          </div>
        </div>

        {/* Khu vực Mã định danh cho nhân viên */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <div className="bg-slate-50 p-4 rounded-xl border border-slate-200">
            <p className="text-xs text-slate-500 uppercase font-bold mb-1">Mã nhà hàng (Restaurant ID)</p>
            <div className="flex items-center justify-between">
              <code className="text-lg font-mono font-bold text-blue-700">{restaurant?.id}</code>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(restaurant?.id || "");
                  alert("Đã sao chép mã nhà hàng");
                }}
                className="text-xs bg-white border px-2 py-1 rounded hover:bg-slate-100"
              >
                Sao chép
              </button>
            </div>
            <p className="text-[10px] text-slate-400 mt-2 italic">* Cung cấp mã này cho nhân viên để họ đăng ký tài khoản vào quán bạn.</p>
          </div>

          <div className="bg-amber-50 p-4 rounded-xl border border-amber-200">
            <p className="text-xs text-amber-600 uppercase font-bold mb-1">Chủ sở hữu</p>
            <p className="text-lg font-bold text-slate-800">{restaurant?.ownerId}</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1">Tên nhà hàng</label>
          <input className="w-full border rounded-lg px-3 py-2" value={name} onChange={(e) => setName(e.target.value)} required />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Số điện thoại liên hệ</label>
          <input className="w-full border rounded-lg px-3 py-2" value={phone} onChange={(e) => setPhone(e.target.value)} required />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Địa chỉ quán</label>
          <textarea className="w-full border rounded-lg px-3 py-2" rows={3} value={address} onChange={(e) => setAddress(e.target.value)} required />
        </div>

        {message && <p className={`text-sm ${message.includes('thành công') ? 'text-green-600' : 'text-red-600'}`}>{message}</p>}

        <button
          disabled={saving}
          className="bg-slate-900 text-white px-6 py-2 rounded-lg font-medium disabled:opacity-50"
        >
          {saving ? "Đang lưu..." : "Lưu thông tin"}
        </button>
      </form>
      </div>
    </div>
  );
}
