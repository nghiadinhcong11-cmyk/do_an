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
    <div className="max-w-2xl mx-auto bg-white rounded-2xl shadow-sm border p-8 mt-10">
      <h1 className="text-2xl font-bold mb-2">Thông tin nhà hàng</h1>
      <p className="text-slate-500 mb-6">Vui lòng hoàn thiện thông tin để Admin có thể phê duyệt quán của bạn.</p>

      {restaurant?.status === 'Pending' && (
        <div className="bg-yellow-50 text-yellow-700 p-4 rounded-lg mb-6 border border-yellow-200">
          Trạng thái: <strong>Chờ phê duyệt</strong>. Bạn vẫn có thể cập nhật thông tin bên dưới.
        </div>
      )}

      {restaurant?.status === 'Approved' && (
        <div className="bg-green-50 text-green-700 p-4 rounded-lg mb-6 border border-green-200">
          Trạng thái: <strong>Đã được phê duyệt</strong>.
        </div>
      )}

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
  );
}
