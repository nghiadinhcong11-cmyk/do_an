import { useEffect, useState } from "react";
import api from "../api/client";
import type { Product } from "../types";

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Partial<Product> | null>(null);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const res = await api.get<Product[]>("/products");
      setProducts(res.data);
    } catch {
      alert("Lỗi tải sản phẩm");
    } finally {
      setLoading(false);
    }
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    setUploading(true);
    try {
      const res = await api.post<{ imageUrl: string }>("/upload/image", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      setEditingProduct(prev => prev ? { ...prev, imageUrl: res.data.imageUrl } : null);
    } catch {
      alert("Lỗi tải ảnh lên");
    } finally {
      setUploading(false);
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
      alert("Lỗi khi lưu sản phẩm");
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
            <div key={p.id} className="bg-white rounded-xl shadow-sm border overflow-hidden flex flex-col hover:shadow-md transition-shadow">
              {/* Ảnh sản phẩm */}
              <div className="h-48 bg-slate-100 relative group">
                {p.imageUrl ? (
                  <img src={p.imageUrl} alt={p.name} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-slate-300">
                    <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                  </div>
                )}
                {p.isBestSeller && (
                  <div className="absolute top-3 left-3 bg-yellow-400 text-white text-[10px] font-black px-2 py-1 rounded-md shadow-sm uppercase tracking-wider">
                    Bán chạy
                  </div>
                )}
              </div>

              <div className="p-4 flex-1 flex flex-col">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <h3 className="font-bold text-lg text-slate-800 line-clamp-1">{p.name}</h3>
                    <p className="text-blue-600 font-black text-xl">{p.price.toLocaleString('vi-VN')}đ</p>
                  </div>
                </div>

                <p className="text-slate-500 text-xs line-clamp-2 mb-4 h-8">
                  {p.description || "Chưa có mô tả cho món ăn này."}
                </p>

                <div className="mt-auto space-y-3">
                  <div className="flex justify-between items-center bg-slate-50 p-2 rounded-lg border border-slate-100">
                    <div className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={p.isAvailable}
                        onChange={() => toggleAvailability(p)}
                        className="w-4 h-4 text-blue-600 rounded cursor-pointer"
                      />
                      <span className="text-[10px] font-bold text-slate-500 uppercase">Còn món</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={p.isBestSeller}
                        onChange={() => toggleBestSeller(p)}
                        className="w-4 h-4 text-yellow-500 rounded cursor-pointer"
                      />
                      <span className="text-[10px] font-bold text-slate-500 uppercase">Nổi bật</span>
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={() => { setEditingProduct(p); setShowModal(true); }}
                      className="flex-1 py-2 text-sm font-bold text-blue-600 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
                    >
                      SỬA
                    </button>
                    <button
                      onClick={() => deleteProduct(p.id)}
                      className="px-3 py-2 text-sm font-bold text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    >
                      XÓA
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 overflow-y-auto">
          <div className="bg-white rounded-[2rem] p-8 w-full max-w-2xl shadow-2xl my-8">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-black text-slate-800 uppercase tracking-tight">
                {editingProduct?.id ? "Sửa món ăn" : "Thêm món mới"}
              </h2>
              <button onClick={() => setShowModal(false)} className="text-slate-400 hover:text-slate-600 transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path></svg>
              </button>
            </div>

            <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                {/* Upload Ảnh */}
                <div className="space-y-2">
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Ảnh món ăn</label>
                  <div className="relative group aspect-video bg-slate-50 rounded-2xl border-2 border-dashed border-slate-200 overflow-hidden flex flex-col items-center justify-center transition-all hover:border-blue-400">
                    {editingProduct?.imageUrl ? (
                      <>
                        <img src={editingProduct.imageUrl} className="w-full h-full object-cover" />
                        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                          <label className="cursor-pointer bg-white text-slate-800 px-4 py-2 rounded-lg font-bold text-xs shadow-lg">THAY ĐỔI ẢNH</label>
                        </div>
                      </>
                    ) : (
                      <>
                        <svg className="w-8 h-8 text-slate-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                        <p className="text-[10px] font-bold text-slate-400 uppercase">Tải ảnh lên</p>
                      </>
                    )}
                    <input type="file" accept="image/*" onChange={handleImageUpload} className="absolute inset-0 opacity-0 cursor-pointer" />
                    {uploading && (
                      <div className="absolute inset-0 bg-white/80 flex items-center justify-center">
                        <div className="w-6 h-6 border-2 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
                      </div>
                    )}
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Mô tả món ăn</label>
                  <textarea
                    className="w-full border-2 border-slate-50 rounded-2xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all min-h-[120px] text-sm"
                    placeholder="Nguyên liệu, cách chế biến, hương vị..."
                    value={editingProduct?.description || ""}
                    onChange={(e) => setEditingProduct({ ...editingProduct, description: e.target.value })}
                  />
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Tên món *</label>
                  <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all font-bold" value={editingProduct?.name || ""} onChange={(e) => setEditingProduct({ ...editingProduct, name: e.target.value })} required />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Giá bán *</label>
                    <input type="number" className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all font-black text-blue-600" value={editingProduct?.price || ""} onChange={(e) => setEditingProduct({ ...editingProduct, price: Number(e.target.value) })} required />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Giá vốn</label>
                    <input type="number" className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all" value={editingProduct?.costPrice || ""} onChange={(e) => setEditingProduct({ ...editingProduct, costPrice: Number(e.target.value) })} />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Danh mục</label>
                  <input className="w-full border-2 border-slate-50 rounded-xl px-4 py-3 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all" value={editingProduct?.category || ""} onChange={(e) => setEditingProduct({ ...editingProduct, category: e.target.value })} />
                </div>

                <div className="pt-6">
                  <button className="w-full bg-blue-600 hover:bg-blue-700 text-white py-4 rounded-2xl font-black shadow-xl shadow-blue-100 transition-all active:scale-[0.98] uppercase tracking-widest">
                    Lưu món ăn
                  </button>
                  <button type="button" onClick={() => setShowModal(false)} className="w-full text-slate-400 py-3 text-xs font-bold uppercase tracking-widest hover:text-slate-600 mt-2">Hủy bỏ</button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
