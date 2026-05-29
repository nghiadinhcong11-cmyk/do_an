import { useEffect, useState, useMemo } from "react";
import { useParams, useSearchParams } from "react-router-dom";
import axios from "axios";

type Product = {
  id: string;
  name: string;
  price: number;
  category: string;
  imageUrl?: string;
  isBestSeller?: boolean;
};

type CartItem = {
  product: Product;
  quantity: number;
};

export default function PublicMenuPage() {
  const { restaurantId } = useParams();
  const [searchParams] = useSearchParams();
  const tableId = searchParams.get("tableId") || "unassigned";
  const tableName = searchParams.get("tableName") || "Khách vãng lai";

  const [data, setData] = useState<{ restaurantName: string, products: Product[] } | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [cart, setCart] = useState<CartItem[]>([]);
  const [isOrdering, setIsOrdering] = useState(false);
  const [note, setNote] = useState("");
  const [orderSuccess, setOrderSuccess] = useState(false);

  useEffect(() => {
    const baseUrl = import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000";
    axios.get(`${baseUrl}/api/public/menu/${restaurantId}`)
      .then(res => setData(res.data))
      .catch(() => setError("Không thể tải thực đơn. Vui lòng thử lại sau."))
      .finally(() => setLoading(false));
  }, [restaurantId]);

  const addToCart = (product: Product) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        return prev.map(item =>
          item.product.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [...prev, { product, quantity: 1 }];
    });
  };

  const updateQuantity = (productId: string, delta: number) => {
    setCart(prev => {
      return prev.map(item => {
        if (item.product.id === productId) {
          const newQty = Math.max(0, item.quantity + delta);
          return { ...item, quantity: newQty };
        }
        return item;
      }).filter(item => item.quantity > 0);
    });
  };

  const totalPrice = useMemo(() =>
    cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0),
  [cart]);

  const totalItems = useMemo(() =>
    cart.reduce((sum, item) => sum + item.quantity, 0),
  [cart]);

  const sendOrder = async () => {
    if (cart.length === 0) return;
    setIsOrdering(true);
    const baseUrl = import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000";

    try {
      await axios.post(`${baseUrl}/api/public/request`, {
        restaurantId,
        tableId,
        tableName,
        type: "order",
        note,
        items: cart.map(item => ({
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity
        }))
      });
      setOrderSuccess(true);
      setCart([]);
      setNote("");
      setTimeout(() => setOrderSuccess(false), 5000);
    } catch {
      alert("Gửi yêu cầu thất bại. Vui lòng gọi nhân viên trực tiếp.");
    } finally {
      setIsOrdering(false);
    }
  };

  const callStaff = async () => {
    const baseUrl = import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000";
    try {
      await axios.post(`${baseUrl}/api/public/request`, {
        restaurantId,
        tableId,
        tableName,
        type: "callStaff",
      });
      alert("Đã gửi yêu cầu gọi nhân viên.");
    } catch {
      alert("Không thể gửi yêu cầu.");
    }
  };

  if (loading) return <div className="p-10 text-center animate-pulse text-orange-600 font-medium">Đang chuẩn bị thực đơn...</div>;
  if (error) return <div className="p-10 text-center text-red-500">{error}</div>;

  const categories = Array.from(new Set(data?.products.map(p => p.category) || []));

  return (
    <div className="min-h-screen bg-slate-50 pb-32">
      <header className="bg-white p-5 shadow-sm sticky top-0 z-20 flex justify-between items-center border-b border-orange-100">
        <div>
          <h1 className="text-xl font-black text-slate-800 leading-tight">{data?.restaurantName}</h1>
          <p className="text-orange-500 text-xs font-bold uppercase tracking-widest">{tableName}</p>
        </div>
        <button
          onClick={callStaff}
          className="bg-orange-100 text-orange-600 px-3 py-1.5 rounded-lg text-xs font-bold border border-orange-200"
        >
          GỌI NHÂN VIÊN
        </button>
      </header>

      {orderSuccess && (
        <div className="m-4 bg-green-500 text-white p-4 rounded-xl shadow-lg flex items-center gap-3 animate-bounce">
          <span className="text-xl">✅</span>
          <div>
            <p className="font-bold">Đã gửi yêu cầu gọi món!</p>
            <p className="text-xs opacity-90">Nhân viên sẽ đến xác nhận trong giây lát.</p>
          </div>
        </div>
      )}

      <div className="max-w-md mx-auto p-4 space-y-8">
        {categories.map(cat => (
          <section key={cat}>
            <h2 className="text-lg font-bold mb-4 flex items-center gap-2 text-slate-700">
              <span className="w-1.5 h-6 bg-orange-500 rounded-full"></span>
              {cat}
            </h2>
            <div className="grid gap-4">
              {data?.products.filter(p => p.category === cat).map(p => {
                const cartQty = cart.find(item => item.product.id === p.id)?.quantity || 0;
                return (
                  <div key={p.id} className="bg-white p-3 rounded-2xl shadow-sm border border-slate-100 flex gap-4 hover:border-orange-200 transition-colors">
                    <div className="w-24 h-24 bg-slate-100 rounded-xl flex-shrink-0 flex items-center justify-center overflow-hidden border border-slate-50">
                      {p.imageUrl ? (
                        <img src={p.imageUrl} alt={p.name} className="w-full h-full object-cover" />
                      ) : (
                        <span className="text-3xl">🍲</span>
                      )}
                    </div>
                    <div className="flex-1 flex flex-col justify-between py-1">
                      <div>
                        <div className="flex justify-between items-start">
                          <h3 className="font-bold text-slate-800 leading-tight">{p.name}</h3>
                          {p.isBestSeller && <span className="bg-yellow-400 text-[10px] font-black px-1.5 py-0.5 rounded ml-2 uppercase">Best</span>}
                        </div>
                        <p className="text-orange-600 font-extrabold text-lg mt-1">{p.price.toLocaleString()}đ</p>
                      </div>

                      <div className="flex justify-end items-center gap-3">
                        {cartQty > 0 ? (
                          <div className="flex items-center gap-3 bg-slate-100 rounded-full px-1">
                            <button onClick={() => updateQuantity(p.id, -1)} className="w-8 h-8 rounded-full flex items-center justify-center text-xl font-bold text-slate-600">-</button>
                            <span className="font-bold text-slate-800 w-4 text-center">{cartQty}</span>
                            <button onClick={() => updateQuantity(p.id, 1)} className="w-8 h-8 rounded-full flex items-center justify-center text-xl font-bold text-orange-600">+</button>
                          </div>
                        ) : (
                          <button
                            onClick={() => addToCart(p)}
                            className="bg-orange-500 hover:bg-orange-600 text-white w-8 h-8 rounded-full flex items-center justify-center shadow-md shadow-orange-100 transition-all active:scale-90"
                          >
                            <span className="text-xl font-bold">+</span>
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        ))}
      </div>

      {/* Cart Summary / Order Button */}
      {totalItems > 0 && (
        <div className="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-white via-white to-transparent">
          <div className="max-w-md mx-auto bg-slate-900 rounded-2xl shadow-2xl p-4 text-white">
            <div className="flex justify-between items-center mb-3">
              <div>
                <p className="text-slate-400 text-xs uppercase font-bold tracking-wider">Tổng cộng ({totalItems} món)</p>
                <p className="text-xl font-black text-orange-400">{totalPrice.toLocaleString()}đ</p>
              </div>
              <button
                onClick={sendOrder}
                disabled={isOrdering}
                className="bg-orange-500 hover:bg-orange-600 text-white px-8 py-3 rounded-xl font-bold shadow-lg shadow-orange-900/20 active:scale-95 transition-all disabled:opacity-50"
              >
                {isOrdering ? "Đang gửi..." : "GỌI MÓN NGAY"}
              </button>
            </div>
            <input
              className="w-full bg-slate-800 border-none rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 outline-none focus:ring-1 focus:ring-orange-500"
              placeholder="Ghi chú thêm (vd: ít cay, không hành...)"
              value={note}
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </div>
      )}

      <footer className="p-8 text-center">
        <p className="text-xs text-slate-400 font-medium">Powered by <span className="text-orange-400 font-bold">FokaPOS</span> v1.0</p>
      </footer>
    </div>
  );
}
