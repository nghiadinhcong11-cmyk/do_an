import { useEffect, useState } from "react";
import api from "../api/client";
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

type SummaryStats = {
  todayRevenue: number;
  todayOrders: number;
  totalProducts: number;
};

type ChartData = {
  date: string;
  amount: number;
};

type TopProduct = {
  name: string;
  value: number;
};

export default function DashboardPage() {
  const [summary, setSummary] = useState<SummaryStats | null>(null);
  const [chartData, setChartData] = useState<ChartData[]>([]);
  const [topProducts, setTopProducts] = useState<TopProduct[]>([]);
  const [loading, setLoading] = useState(true);

  const username = localStorage.getItem("username");

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [sumRes, chartRes, topRes] = await Promise.all([
          api.get<SummaryStats>("/stats/summary"),
          api.get<ChartData[]>("/stats/revenue-chart"),
          api.get<TopProduct[]>("/stats/top-products")
        ]);
        setSummary(sumRes.data);
        setChartData(chartRes.data);
        setTopProducts(topRes.data);
      } catch (err) {
        console.error("Lỗi tải báo cáo:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) return <div className="py-20 text-center animate-pulse text-slate-400 font-medium">Đang tổng hợp báo cáo...</div>;

  return (
    <div className="space-y-8 pb-10">
      <header className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight uppercase">Bảng điều khiển</h1>
          <p className="text-slate-500 font-medium">Chào mừng trở lại, <span className="text-blue-600 font-bold">{username}</span></p>
        </div>
        <div className="text-right hidden md:block">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Hôm nay</p>
          <p className="text-lg font-black text-slate-700">{new Date().toLocaleDateString('vi-VN')}</p>
        </div>
      </header>

      {/* Thẻ thống kê nhanh */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-8 rounded-[2rem] border border-slate-100 shadow-sm hover:shadow-xl transition-all group">
          <div className="flex justify-between items-start mb-4">
            <div className="bg-blue-50 p-3 rounded-2xl text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-colors">
               <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            </div>
          </div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Doanh thu hôm nay</p>
          <p className="text-3xl font-black text-slate-800">{summary?.todayRevenue.toLocaleString('vi-VN')}đ</p>
        </div>

        <div className="bg-white p-8 rounded-[2rem] border border-slate-100 shadow-sm hover:shadow-xl transition-all group">
          <div className="flex justify-between items-start mb-4">
            <div className="bg-orange-50 p-3 rounded-2xl text-orange-600 group-hover:bg-orange-600 group-hover:text-white transition-colors">
               <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>
            </div>
          </div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Đơn hàng mới</p>
          <p className="text-3xl font-black text-slate-800">{summary?.todayOrders} đơn</p>
        </div>

        <div className="bg-white p-8 rounded-[2rem] border border-slate-100 shadow-sm hover:shadow-xl transition-all group">
          <div className="flex justify-between items-start mb-4">
            <div className="bg-green-50 p-3 rounded-2xl text-green-600 group-hover:bg-green-600 group-hover:text-white transition-colors">
               <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path></svg>
            </div>
          </div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Thực đơn hiện có</p>
          <p className="text-3xl font-black text-slate-800">{summary?.totalProducts} món</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Biểu đồ doanh thu 7 ngày */}
        <div className="lg:col-span-2 bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-sm">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-xl font-bold text-slate-800">Doanh thu 7 ngày qua</h2>
            <div className="flex items-center gap-2">
               <div className="w-3 h-3 bg-blue-600 rounded-full"></div>
               <span className="text-xs font-bold text-slate-500 uppercase">Doanh thu (VNĐ)</span>
            </div>
          </div>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis
                  dataKey="date"
                  axisLine={false}
                  tickLine={false}
                  tick={{fill: '#94a3b8', fontSize: 12, fontWeight: 600}}
                  dy={10}
                />
                <YAxis hide />
                <Tooltip
                  contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                  formatter={(value: number) => [value.toLocaleString() + 'đ', 'Doanh thu']}
                />
                <Line
                  type="monotone"
                  dataKey="amount"
                  stroke="#2563eb"
                  strokeWidth={4}
                  dot={{ r: 6, fill: '#2563eb', strokeWidth: 0 }}
                  activeDot={{ r: 8, strokeWidth: 0 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Top món bán chạy */}
        <div className="bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-sm">
          <h2 className="text-xl font-bold text-slate-800 mb-8">Sản phẩm bán chạy</h2>
          <div className="space-y-6">
            {topProducts.length === 0 ? (
              <p className="text-center py-20 text-slate-400 italic">Chưa có dữ liệu bán hàng</p>
            ) : topProducts.map((item, index) => (
              <div key={item.name} className="flex items-center gap-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold ${
                  index === 0 ? 'bg-yellow-100 text-yellow-700' :
                  index === 1 ? 'bg-slate-100 text-slate-700' : 'bg-orange-100 text-orange-700'
                }`}>
                  {index + 1}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-slate-800 truncate">{item.name}</p>
                  <div className="w-full bg-slate-100 h-2 rounded-full mt-2 overflow-hidden">
                    <div
                      className={`h-full rounded-full ${index === 0 ? 'bg-yellow-400' : 'bg-blue-500'}`}
                      style={{ width: `${(item.value / topProducts[0].value) * 100}%` }}
                    ></div>
                  </div>
                </div>
                <p className="font-black text-slate-700">{item.value}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
