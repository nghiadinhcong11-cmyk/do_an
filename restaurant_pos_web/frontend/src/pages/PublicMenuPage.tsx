import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";

type Product = {
  id: string;
  name: string;
  price: number;
  category: string;
  imageUrl?: string;
};

export default function PublicMenuPage() {
  const { restaurantId } = useParams();
  const [data, setData] = useState<{ restaurantName: string, products: Product[] } | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const baseUrl = import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000";
    axios.get(`${baseUrl}/api/public/menu/${restaurantId}`)
      .then(res => setData(res.data))
      .catch(() => setError("Không thể tải menu. Vui lòng thử lại sau."))
      .finally(() => setLoading(false));
  }, [restaurantId]);

  if (loading) return <div className="p-10 text-center">Đang tải thực đơn...</div>;
  if (error) return <div className="p-10 text-center text-red-500">{error}</div>;

  const categories = Array.from(new Set(data?.products.map(p => p.category) || []));

  return (
    <div className="min-h-screen bg-orange-50 pb-20">
      <header className="bg-white p-6 shadow-sm sticky top-0 z-10 text-center">
        <h1 className="text-2xl font-bold text-orange-600">{data?.restaurantName}</h1>
        <p className="text-slate-500 text-sm">Thực đơn tại bàn</p>
      </header>

      <div className="max-w-md mx-auto p-4 space-y-8">
        {categories.map(cat => (
          <section key={cat}>
            <h2 className="text-lg font-bold mb-4 border-l-4 border-orange-500 pl-3">{cat}</h2>
            <div className="grid gap-4">
              {data?.products.filter(p => p.category === cat).map(p => (
                <div key={p.id} className="bg-white p-3 rounded-xl shadow-sm flex items-center gap-4">
                  <div className="w-20 h-20 bg-orange-100 rounded-lg flex-shrink-0 flex items-center justify-center overflow-hidden">
                    {p.imageUrl ? (
                      <img src={p.imageUrl} alt={p.name} className="w-full h-full object-cover" />
                    ) : (
                      <span className="text-orange-300">🍽️</span>
                    )}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-slate-800">{p.name}</h3>
                    <p className="text-orange-600 font-bold mt-1">{p.price.toLocaleString()}đ</p>
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>

      <footer className="fixed bottom-0 left-0 right-0 bg-white border-t p-4 text-center text-xs text-slate-400">
        Powered by FokaPOS
      </footer>
    </div>
  );
}
