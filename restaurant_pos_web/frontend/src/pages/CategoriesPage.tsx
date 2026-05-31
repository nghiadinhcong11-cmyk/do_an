import { useEffect, useState } from "react";
import api from "../api/client";
import type { Category } from "../types";

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Partial<Category> | null>(null);

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const res = await api.get<Category[]>("/categories");
      setCategories(res.data);
    } catch {
      alert("Lỗi tải danh mục");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingCategory?.name) return;

    try {
      if (editingCategory.id) {
        await api.put(`/categories/${editingCategory.id}`, editingCategory);
      } else {
        await api.post("/categories", editingCategory);
      }
      setShowModal(false);
      fetchCategories();
    } catch {
      alert("Lỗi khi lưu danh mục");
    }
  };

  const deleteCategory = async (id: string) => {
    if (!confirm("Xóa danh mục này? Các sản phẩm thuộc danh mục này sẽ bị để trống danh mục.")) return;
    try {
      await api.delete(`/categories/${id}`);
      fetchCategories();
    } catch {
      alert("Không thể xóa danh mục");
    }
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800">Quản lý danh mục</h1>
          <p className="text-slate-500">Phân loại món ăn để khách hàng dễ dàng tìm kiếm.</p>
        </div>
        <button
          onClick={() => { setEditingCategory({ name: "", displayOrder: 0, isActive: true }); setShowModal(true); }}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-2xl transition-all font-bold shadow-lg shadow-blue-200 active:scale-95"
        >
          + THÊM DANH MỤC
        </button>
      </div>

      <div className="bg-white rounded-[2rem] border border-slate-100 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead className="bg-slate-50 text-slate-400 text-[10px] uppercase font-black tracking-widest border-b border-slate-100">
            <tr>
              <th className="px-8 py-4">Tên danh mục</th>
              <th className="px-8 py-4">Thứ tự hiển thị</th>
              <th className="px-8 py-4">Trạng thái</th>
              <th className="px-8 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-50">
            {loading ? (
              <tr><td colSpan={4} className="px-8 py-10 text-center text-slate-400 font-medium animate-pulse">Đang tải...</td></tr>
            ) : categories.length === 0 ? (
              <tr><td colSpan={4} className="px-8 py-10 text-center text-slate-400 italic">Chưa có danh mục nào.</td></tr>
            ) : (
              categories.map((c) => (
                <tr key={c.id} className="hover:bg-slate-50/50 transition-colors group">
                  <td className="px-8 py-5 font-bold text-slate-700">{c.name}</td>
                  <td className="px-8 py-5">
                    <span className="bg-slate-100 text-slate-500 px-3 py-1 rounded-lg text-xs font-bold">#{c.displayOrder}</span>
                  </td>
                  <td className="px-8 py-5">
                    <span className={`px-3 py-1 rounded-full text-[10px] font-black uppercase ${c.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                      {c.isActive ? 'Hoạt động' : 'Tạm ẩn'}
                    </span>
                  </td>
                  <td className="px-8 py-5 text-right space-x-2">
                    <button
                      onClick={() => { setEditingCategory(c); setShowModal(true); }}
                      className="text-blue-600 hover:bg-blue-50 px-3 py-1 rounded-lg font-bold text-xs transition-colors"
                    >
                      SỬA
                    </button>
                    <button
                      onClick={() => deleteCategory(c.id)}
                      className="text-red-400 hover:text-red-600 px-3 py-1 rounded-lg font-bold text-xs transition-colors"
                    >
                      XÓA
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-[2.5rem] p-10 w-full max-w-md shadow-2xl scale-in-center">
            <h2 className="text-2xl font-black text-slate-800 mb-6 uppercase tracking-tight">
              {editingCategory?.id ? "Sửa danh mục" : "Thêm danh mục"}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 ml-1">Tên danh mục *</label>
                <input
                  className="w-full border-2 border-slate-50 rounded-2xl px-4 py-4 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all font-bold"
                  value={editingCategory?.name || ""}
                  onChange={(e) => setEditingCategory({ ...editingCategory, name: e.target.value })}
                  placeholder="Ví dụ: Đồ uống, Món chính..."
                  required
                />
              </div>

              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 ml-1">Thứ tự hiển thị</label>
                <input
                  type="number"
                  className="w-full border-2 border-slate-50 rounded-2xl px-4 py-4 focus:border-blue-500 outline-none bg-slate-50 focus:bg-white transition-all font-bold"
                  value={editingCategory?.displayOrder || 0}
                  onChange={(e) => setEditingCategory({ ...editingCategory, displayOrder: Number(e.target.value) })}
                />
              </div>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={editingCategory?.isActive}
                  onChange={(e) => setEditingCategory({ ...editingCategory, isActive: e.target.checked })}
                  className="w-6 h-6 text-blue-600 border-2 border-slate-200 rounded-xl focus:ring-blue-500 transition-all"
                />
                <span className="text-sm font-bold text-slate-600 group-hover:text-slate-800">Hiển thị danh mục này</span>
              </label>

              <div className="pt-4 flex flex-col gap-2">
                <button className="w-full bg-slate-900 hover:bg-black text-white py-4 rounded-2xl font-black shadow-xl transition-all active:scale-95 uppercase tracking-widest">
                  Lưu danh mục
                </button>
                <button type="button" onClick={() => setShowModal(false)} className="w-full text-slate-400 py-2 text-xs font-bold uppercase hover:text-slate-600">Hủy bỏ</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
