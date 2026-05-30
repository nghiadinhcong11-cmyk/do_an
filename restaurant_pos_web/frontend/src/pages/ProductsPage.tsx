import { useEffect, useState } from "react";
import api from "../api/client";
import type { Product } from "../types";

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Partial<Product> | null>(null);
  const [uploading, setUploading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

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

  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.category.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const categories = Array.from(new Set(filteredProducts.map(p => p.category)));

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
    <div className="space-y-8">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800">Quản lý thực đơn</h1>
          <p className="text-slate-500">Tổ chức món ăn theo danh mục và tìm kiếm nhanh chóng.</p>
        </div>
        <button
          onClick={() => { setEditingProduct({ category: "Món chính", price: 0, costPrice: 0, isAvailable: true, isBestSeller: false }); setShowModal(true); }}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-2xl transition-all font-bold shadow-lg shadow-blue-200 active:scale-95"
        >
          + THÊM MÓN MỚI
        </button>
      </div>

      {/* Thanh tìm kiếm */}
      <div className="relative max-w-xl">
        <span className="absolute inset-y-0 left-0 pl-4 flex items-center text-slate-400">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
        </span>
        <input
          type="text"
          className="w-full pl-12 pr-4 py-4 bg-white border-2 border-slate-100 rounded-2xl focus:border-blue-500 outline-none transition-all shadow-sm text-slate-800 placeholder-slate-400"
          placeholder="Tìm tên món, danh mục hoặc nguyên liệu..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      <div className="space-y-12">
        {loading ? (
          <div className="py-20 text-center text-slate-400 animate-pulse font-medium">Đang tải dữ liệu thực đơn...</div>
        ) : categories.length === 0 ? (
          <div className="py-20 text-center bg-white rounded-3xl border-2 border-dashed border-slate-200">
            <p className="text-slate-400 font-medium">Không tìm thấy món ăn nào phù hợp.</p>
          </div>
        ) : (
          categories.map(cat => (
            <section key={cat} className="space-y-6">
              <div className="flex items-center gap-3">
                <div className="h-8 w-1.5 bg-blue-600 rounded-full"></div>
                <h2 className="text-2xl font-black text-slate-800 uppercase tracking-tight">{cat}</h2>
                <span className="bg-slate-100 text-slate-500 px-3 py-1 rounded-full text-xs font-bold">
                  {filteredProducts.filter(p => p.category === cat).length} món
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {filteredProducts.filter(p => p.category === cat).map((p) => (
                  <div key={p.id} className="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden flex flex-col hover:shadow-xl hover:-translate-y-1 transition-all group">
                    {/* Ảnh sản phẩm */}
                    <div className="h-48 bg-slate-50 relative overflow-hidden">
                      {p.imageUrl ? (
                        <img src={p.imageUrl} alt={p.name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-slate-200">
                          <svg className="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                        </div>
                      )}
                      <div className="absolute top-4 right-4 flex flex-col gap-2">
                        {p.isBestSeller && (
                          <div className="bg-yellow-400 text-white text-[10px] font-black px-2 py-1 rounded-lg shadow-lg uppercase">Best</div>
                        )}
                        {!p.isAvailable && (
                          <div className="bg-slate-900/80 text-white text-[10px] font-black px-2 py-1 rounded-lg shadow-lg uppercase backdrop-blur-sm">Hết món</div>
                        )}
                      </div>
                    </div>

                    <div className="p-6 flex-1 flex flex-col">
                      <div className="mb-4">
                        <h3 className="font-bold text-lg text-slate-800 line-clamp-1 mb-1">{p.name}</h3>
                        <p className="text-blue-600 font-black text-2xl">{p.price.toLocaleString('vi-VN')}đ</p>
                      </div>

                      <p className="text-slate-400 text-xs line-clamp-2 mb-6 h-8 italic">
                        {p.description || "Không có mô tả chi tiết."}
                      </p>

                      <div className="mt-auto space-y-4">
                        <div className="flex justify-between items-center bg-slate-50 p-3 rounded-2xl border border-slate-100">
                          <label className="flex items-center gap-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={p.isAvailable}
                              onChange={() => toggleAvailability(p)}
                              className="w-5 h-5 text-blue-600 border-2 border-slate-200 rounded-lg focus:ring-blue-500 transition-all"
                            />
                            <span className="text-[10px] font-black text-slate-500 uppercase tracking-tighter">Bán</span>
                          </label>
                          <label className="flex items-center gap-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={p.isBestSeller}
                              onChange={() => toggleBestSeller(p)}
                              className="w-5 h-5 text-yellow-500 border-2 border-slate-200 rounded-lg focus:ring-yellow-500 transition-all"
                            />
                            <span className="text-[10px] font-black text-slate-500 uppercase tracking-tighter">Hot</span>
                          </label>
                        </div>

                        <div className="flex gap-3">
                          <button
                            onClick={() => { setEditingProduct(p); setShowModal(true); }}
                            className="flex-1 py-3 text-xs font-black text-blue-600 bg-blue-50 hover:bg-blue-600 hover:text-white rounded-xl transition-all"
                          >
                            CHỈNH SỬA
                          </button>
                          <button
                            onClick={() => deleteProduct(p.id)}
                            className="p-3 text-red-300 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all"
                          >
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </section>
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
