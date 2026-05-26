import { useEffect, useState } from "react";
import * as signalR from "@microsoft/signalr";
import api from "../api/client";
import type { RestaurantTable } from "../types";

export default function TablesPage() {
  const [tables, setTables] = useState<RestaurantTable[]>([]);
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState("");
  const [seats, setSeats] = useState(4);

  useEffect(() => {
    fetchTables();

    const token = localStorage.getItem("token");
    const restaurantId = localStorage.getItem("restaurantId");
    if (!token || !restaurantId) return;

    const hub = new signalR.HubConnectionBuilder()
      .withUrl((import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000") + "/hubs/tables", {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect()
      .build();

    hub.on("tableStatusChanged", (tableId: string, status: string) => {
      setTables(prev => prev.map(t => t.id === tableId ? { ...t, status } : t));
    });

    hub.start()
      .then(() => hub.invoke("JoinRestaurantGroup", restaurantId))
      .catch(console.error);

    return () => {
      hub.stop().catch(() => undefined);
    };
  }, []);

  const fetchTables = async () => {
    try {
      const res = await api.get<RestaurantTable[]>("/tables");
      setTables(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const addTable = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post("/tables", { name, seats, status: "TRONG" });
      setName("");
      fetchTables();
    } catch (err) {
      alert("Lỗi khi thêm bàn");
    }
  };

  const deleteTable = async (id: string) => {
    if (!confirm("Xóa bàn này?")) return;
    try {
      await api.delete(`/tables/${id}`);
      fetchTables();
    } catch (err) {
      alert("Lỗi khi xóa");
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Quản lý sơ đồ bàn (Real-time)</h1>

      <div className="grid md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl border h-fit shadow-sm">
          <h2 className="font-semibold mb-4">Thêm bàn mới</h2>
          <form onSubmit={addTable} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Tên bàn</label>
              <input className="w-full border rounded-lg px-3 py-2" placeholder="Ví dụ: Bàn 01" value={name} onChange={e => setName(e.target.value)} required />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Số chỗ ngồi</label>
              <input type="number" className="w-full border rounded-lg px-3 py-2" value={seats} onChange={e => setSeats(Number(e.target.value))} required />
            </div>
            <button className="w-full bg-slate-900 text-white py-2 rounded-lg hover:bg-slate-800 transition-colors">Thêm bàn</button>
          </form>
        </div>

        <div className="md:col-span-2 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {loading ? <p>Đang tải...</p> : tables.map(t => {
            const restaurantId = localStorage.getItem("restaurantId");
            const publicUrl = `${window.location.origin}/menu/${restaurantId}?table=${t.id}`;
            const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${encodeURIComponent(publicUrl)}`;

            return (
              <div key={t.id} className="bg-white p-4 rounded-xl border flex flex-col items-center relative group shadow-sm transition-all hover:shadow-md">
                <div className={`w-12 h-12 rounded-full mb-2 flex items-center justify-center transition-colors ${t.status === 'TRONG' ? 'bg-green-100 text-green-600' : 'bg-orange-100 text-orange-600'}`}>
                  <span className="text-xs font-bold">{t.seats}</span>
                </div>
                <p className="font-bold">{t.name}</p>
                <p className={`text-[10px] font-bold px-2 py-0.5 rounded-full mb-3 ${t.status === 'TRONG' ? 'bg-green-50 text-green-600' : 'bg-orange-50 text-orange-600'}`}>
                  {t.status === 'TRONG' ? 'TRỐNG' : 'CÓ KHÁCH'}
                </p>

                <div className="mt-auto pt-3 border-t w-full flex flex-col items-center">
                  <img src={qrUrl} alt="QR Code" className="w-16 h-16 mb-1 grayscale group-hover:grayscale-0 transition-all" />
                  <span className="text-[9px] text-slate-400 uppercase tracking-widest font-semibold">Scan Menu</span>
                </div>

                <button
                  onClick={() => deleteTable(t.id)}
                  className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 text-red-300 hover:text-red-600 transition-all"
                >
                  ✕
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
