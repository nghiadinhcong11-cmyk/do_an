import { useEffect, useState } from "react";
import api from "../api/client";
import type { Product } from "../types";

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Partial<Product> | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const res = await api.get<Product[]>("/products");
        setProducts(res.data);
      } catch {
        alert("Loi tai san pham");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const fetchProducts = async () => {
    try {
      const res = await api.get<Product[]>("/products");
      setProducts(res.data);
    } catch {
      alert("Loi tai san pham");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingProduct?.name || !editingProduct?.price) return;

    try {
      if (editingProduct.id) {
        await api.put(`/products/${editingProduct.id}`, editingProduct);
      } else {
        await api.post("/products", editingProduct);
      }
      setShowModal(false);
      fetchProducts();
    } catch {
      alert("Loi khi luu san pham");
    }
  };

  const deleteProduct = async (id: string) => {
    if (!confirm("Ban co chac muon xoa mon nay?")) return;
    try {
      await api.delete(`/products/${id}`);
      fetchProducts();
    } catch {
      alert("Khong the xoa mon nay");
    }
  };

  const toggleAvailability = async (product: Product) => {
    try {
      await api.patch(`/products/${product.id}/availability`, { isAvailable: !product.isAvailable });
      fetchProducts();
    } catch {
      alert("Lỗi khi cập nhật trạng thái");
    }
  };

  const toggleBestSeller = async (product: Product) => {
    try {
      await api.patch(`/products/${product.id}/bestseller`, { isBestSeller: !product.isBestSeller });
      fetchProducts();
    } catch {
      alert("Lỗi khi cập nhật trạng thái");
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-slate-800">Quản lý thực đơn</h1>
        <button
          onClick={() => { setEditingProduct({ category: "Khác", price: 0, costPrice: 0, isAvailable: true, isBestSeller: false }); setShowModal(true); }}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors font-medium"
        >
          + Thêm món mới
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          <p className="p-4">Đang tải...</p>
        ) : products.length === 0 ? (
          <p className="p-4 text-slate-500 italic">Chưa có món ăn nào trong thực đơn.</p>
        ) : (
          products.map((p) => (
            <div key={p.id} className="bg-white rounded-xl shadow-sm border p-4 flex flex-col justify-between hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <h3 className="font-bold text-lg text-slate-800 flex items-center gap-2">
                    {p.name}
                    {p.isBestSeller && <span className="text-yellow-500 text-sm">★</span>}
                  </h3>
                  <p className="text-blue-600 font-semibold">{p.price.toLocaleString('vi-VN')}đ</p>
                  <p className="text-slate-500 text-xs mt-1">Danh mục: {p.category}</p>
                </div>
                <div className="flex flex-col items-end gap-2">
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-500">Còn món</span>
                    <input
                      type="checkbox"
                      checked={p.isAvailable}
                      onChange={() => toggleAvailability(p)}
                      className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500 cursor-pointer"
                    />
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-500">Nổi bật</span>
                    <input
                      type="checkbox"
                      checked={p.isBestSeller}
                      onChange={() => toggleBestSeller(p)}
                      className="w-4 h-4 text-yellow-600 rounded focus:ring-yellow-500 cursor-pointer"
                    />
                  </div>
                </div>
              </div>

              <div className="flex justify-end space-x-2 mt-4 pt-4 border-t">
                <button
                  onClick={() => { setEditingProduct(p); setShowModal(true); }}
                  className="px-3 py-1 text-sm text-blue-600 hover:bg-blue-50 rounded transition-colors"
                >
                  Sửa
                </button>
                <button
                  onClick={() => deleteProduct(p.id)}
                  className="px-3 py-1 text-sm text-red-600 hover:bg-red-50 rounded transition-colors"
                >
                  Xóa
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-8 w-full max-w-md shadow-2xl">
            <h2 className="text-xl font-bold mb-6 text-slate-800">
              {editingProduct?.id ? "Sửa món ăn" : "Thêm món mới"}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Tên món *</label>
                <input
                  className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
                  value={editingProduct?.name || ""}
                  onChange={(e) => setEditingProduct({ ...editingProduct, name: e.target.value })}
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Giá bán *</label>
                <input
                  type="number"
                  className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
                  value={editingProduct?.price || ""}
                  onChange={(e) => setEditingProduct({ ...editingProduct, price: Number(e.target.value) })}
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Danh mục</label>
                <input
                  className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
                  value={editingProduct?.category || ""}
                  onChange={(e) => setEditingProduct({ ...editingProduct, category: e.target.value })}
                />
              </div>
              <div className="flex justify-end gap-3 pt-6">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
                >
                  Hủy
                </button>
                <button className="px-6 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors">
                  Lưu thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
