import { useEffect, useState } from "react";
import * as signalR from "@microsoft/signalr";
import api from "../api/client";
import type { RestaurantTable } from "../types";
import { QRCodeSVG } from "qrcode.react";

export default function TablesPage() {
  const [tables, setTables] = useState<RestaurantTable[]>([]);
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState("");
  const [seats, setSeats] = useState(4);
  const [showQR, setShowQR] = useState<RestaurantTable | null>(null);

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

  const getQRUrl = (table: RestaurantTable) => {
    const restaurantId = localStorage.getItem("restaurantId");
    const baseUrl = window.location.origin;
    return `${baseUrl}/menu/${restaurantId}?tableId=${table.id}&tableName=${encodeURIComponent(table.name)}`;
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="text-3xl font-black text-slate-800">Sơ đồ phòng bàn</h1>
        <p className="text-slate-500">Quản lý trạng thái bàn và cung cấp mã QR cho khách gọi món.</p>
      </header>

      <div className="grid lg:grid-cols-4 gap-8">
        {/* Form thêm bàn */}
        <div className="lg:col-span-1">
          <section className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm sticky top-24">
            <h2 className="font-bold text-lg mb-4 flex items-center gap-2">
              <span className="bg-blue-600 w-2 h-6 rounded-full"></span>
              Thêm bàn mới
            </h2>
            <form onSubmit={addTable} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase mb-1 ml-1">Tên bàn</label>
                <input
                  className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all"
                  placeholder="Ví dụ: Bàn 01"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  required
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase mb-1 ml-1">Số chỗ ngồi</label>
                <input
                  type="number"
                  className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all"
                  value={seats}
                  onChange={e => setSeats(Number(e.target.value))}
                  required
                />
              </div>
              <button className="w-full bg-blue-600 hover:bg-blue-700 text-white py-4 rounded-2xl font-bold shadow-lg shadow-blue-100 transition-all active:scale-[0.98]">
                TẠO BÀN NGAY
              </button>
            </form>
          </section>
        </div>

        {/* Danh sách bàn */}
        <div className="lg:col-span-3 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          {loading ? (
            <div className="col-span-full py-20 text-center text-slate-400 font-medium">Đang tải sơ đồ bàn...</div>
          ) : tables.length === 0 ? (
            <div className="col-span-full py-20 text-center bg-white rounded-3xl border-2 border-dashed border-slate-200">
               <p className="text-slate-400">Chưa có bàn nào. Hãy thêm bàn để bắt đầu!</p>
            </div>
          ) : tables.map(t => (
            <div key={t.id} className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all group flex flex-col items-center">
              <div className={`w-16 h-16 rounded-2xl mb-4 flex items-center justify-center shadow-inner ${t.status === 'TRONG' ? 'bg-green-50 text-green-600' : 'bg-orange-50 text-orange-600'}`}>
                <span className="text-xl font-black">{t.seats}</span>
              </div>

              <h3 className="font-black text-xl text-slate-800 mb-1">{t.name}</h3>
              <p className={`text-[10px] font-black px-3 py-1 rounded-full mb-6 tracking-tighter ${t.status === 'TRONG' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                {t.status === 'TRONG' ? 'TRỐNG' : 'CÓ KHÁCH'}
              </p>

              <div className="w-full space-y-2">
                <button
                  onClick={() => setShowQR(t)}
                  className="w-full py-3 text-xs font-black bg-slate-50 hover:bg-slate-100 text-slate-600 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"></path></svg>
                  XUẤT MÃ QR
                </button>
                <button
                  onClick={() => deleteTable(t.id)}
                  className="w-full py-2 text-[10px] font-bold text-red-300 hover:text-red-500 transition-colors uppercase"
                >
                  Xóa bàn này
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Modal QR Code */}
      {showQR && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-4 z-50 animate-in fade-in duration-300">
          <div className="bg-white rounded-[40px] p-10 w-full max-w-sm text-center shadow-2xl scale-in-center">
            <h2 className="text-2xl font-black text-slate-800 mb-2">{showQR.name}</h2>
            <p className="text-sm text-slate-500 mb-8">Dán mã này tại bàn để khách gọi món</p>

            <div className="bg-white p-8 rounded-3xl shadow-inner border-2 border-slate-100 flex justify-center mb-8">
               <QRCodeSVG value={getQRUrl(showQR)} size={220} includeMargin={true} />
            </div>

            <button
              onClick={() => setShowQR(null)}
              className="w-full bg-slate-900 hover:bg-black text-white py-4 rounded-2xl font-bold shadow-xl transition-all active:scale-95"
            >
              HOÀN TẤT
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
