import { useEffect, useState } from "react";
import { Link } from "react-router-dom";

type CustomerInfo = {
  points: number;
  rank: string;
  totalSpent: number;
};

type Voucher = {
  id: string;
  code: string;
  title: string;
  discountValue: number;
  expiryDate: string;
};

export default function CustomerDashboard() {
  const [info, setInfo] = useState<CustomerInfo | null>(null);
  const [vouchers, setVouchers] = useState<Voucher[]>([]);
  const username = localStorage.getItem("username");

  useEffect(() => {
    // Giả lập hoặc gọi API lấy thông tin tích điểm
    setInfo({ points: 1250, rank: "Vàng (Gold)", totalSpent: 5200000 });

    // Giả lập lấy voucher
    setVouchers([
      { id: "1", code: "HE_XINH", title: "Giảm 20k cho đơn từ 100k", discountValue: 20000, expiryDate: "2024-06-30" },
      { id: "2", code: "FREESHIP", title: "Miễn phí món tráng miệng", discountValue: 0, expiryDate: "2024-07-15" }
    ]);
  }, []);

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <header className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800">Xin chào, {username}! 👋</h1>
          <p className="text-slate-500 font-medium">Cảm ơn bạn đã luôn ủng hộ cửa hàng.</p>
        </div>
        <div className="bg-gradient-to-r from-orange-500 to-amber-500 text-white p-6 rounded-3xl shadow-lg shadow-orange-200 flex items-center gap-6">
          <div className="text-center">
            <p className="text-xs uppercase font-bold opacity-80 tracking-widest mb-1">Điểm tích lũy</p>
            <p className="text-4xl font-black">{info?.points.toLocaleString()}</p>
          </div>
          <div className="w-px h-12 bg-white/20"></div>
          <div>
            <p className="text-xs uppercase font-bold opacity-80 tracking-widest mb-1">Hạng thẻ</p>
            <p className="text-xl font-black">{info?.rank}</p>
          </div>
        </div>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Phần Voucher */}
        <section className="space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">
              <span className="text-2xl">🎁</span> Voucher của bạn
            </h2>
            <Link to="/vouchers" className="text-sm font-bold text-orange-600 hover:underline">Xem tất cả</Link>
          </div>

          <div className="space-y-3">
            {vouchers.map(v => (
              <div key={v.id} className="bg-white border-2 border-dashed border-slate-200 rounded-2xl p-4 flex justify-between items-center hover:border-orange-300 transition-colors group">
                <div>
                  <h3 className="font-bold text-slate-800 group-hover:text-orange-600">{v.title}</h3>
                  <p className="text-xs text-slate-400 mt-1">HSD: {v.expiryDate}</p>
                </div>
                <div className="bg-slate-100 px-3 py-1 rounded-lg font-mono font-bold text-slate-600 text-sm">
                  {v.code}
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Phần đặt món nhanh */}
        <section className="bg-blue-600 rounded-3xl p-8 text-white relative overflow-hidden flex flex-col justify-center">
          <div className="relative z-10">
            <h2 className="text-2xl font-black mb-2">Đang ở tại quán?</h2>
            <p className="text-blue-100 mb-6 text-sm">Quét mã QR tại bàn để xem thực đơn và gọi món ngay trên điện thoại.</p>
            <button className="bg-white text-blue-600 px-6 py-3 rounded-xl font-bold shadow-lg shadow-blue-900/20 active:scale-95 transition-all">
               QUÉT QR ĐẶT MÓN
            </button>
          </div>
          <span className="absolute -right-4 -bottom-4 text-9xl opacity-10 rotate-12">📱</span>
        </section>
      </div>

      {/* Lịch sử gần đây */}
      <section className="bg-white rounded-3xl border border-slate-100 shadow-sm p-8">
        <h2 className="text-xl font-bold text-slate-800 mb-6">Đơn hàng gần đây</h2>
        <div className="space-y-4">
          <div className="flex justify-between items-center p-4 rounded-2xl bg-slate-50">
             <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-xl">🍜</div>
                <div>
                   <p className="font-bold text-slate-800">Phở bò, Trà đào...</p>
                   <p className="text-xs text-slate-400">Hôm qua • 12:30</p>
                </div>
             </div>
             <p className="font-black text-slate-800">125.000đ</p>
          </div>
          <button className="w-full py-3 text-sm font-bold text-slate-400 hover:text-slate-600 transition-colors">XEM TOÀN BỘ LỊCH SỬ</button>
        </div>
      </section>
    </div>
  );
}
