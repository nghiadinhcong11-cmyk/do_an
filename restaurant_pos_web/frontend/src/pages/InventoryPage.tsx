import { useEffect, useState } from "react";
import api from "../api/client";
import { AlertTriangle, ArrowDown, ArrowUp, Plus } from "lucide-react";

type Ingredient = {
  id: string;
  name: string;
  unit: string;
  stockQuantity: number;
  minStockLevel: number;
  lastUpdatedUtc: string;
};

export default function InventoryPage() {
  const [ingredients, setIngredients] = useState<Ingredient[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [showImportModal, setShowImportModal] = useState(false);
  const [selectedIngredient, setSelectedIngredient] = useState<Ingredient | null>(null);
  const [newIngredient, setNewIngredient] = useState({ name: "", unit: "g", minStockLevel: 100 });
  const [importQty, setImportQty] = useState(0);

  useEffect(() => {
    fetchIngredients();
  }, []);

  const fetchIngredients = async () => {
    try {
      const res = await api.get<Ingredient[]>("/ingredients");
      setIngredients(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post("/ingredients", { ...newIngredient, stockQuantity: 0 });
      setShowModal(false);
      fetchIngredients();
    } catch (err) { alert("Lỗi khi tạo nguyên liệu"); }
  };

  const handleImport = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedIngredient) return;
    try {
      await api.post(`/ingredients/import?id=${selectedIngredient.id}`, importQty);
      setShowImportModal(false);
      setImportQty(0);
      fetchIngredients();
    } catch (err) { alert("Lỗi khi nhập kho"); }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-slate-900">Quản lý kho nguyên liệu</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-slate-900 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-slate-800 transition-colors"
        >
          <Plus size={18} /> Thêm nguyên liệu
        </button>
      </div>

      <div className="grid md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border shadow-sm">
          <p className="text-sm text-slate-500">Tổng mặt hàng</p>
          <p className="text-2xl font-bold">{ingredients.length}</p>
        </div>
        <div className="bg-white p-4 rounded-xl border shadow-sm flex items-center gap-3">
          <div className="p-2 bg-red-50 rounded-lg"><AlertTriangle className="text-red-600" size={20} /></div>
          <div>
            <p className="text-sm text-slate-500">Sắp hết hàng</p>
            <p className="text-2xl font-bold text-red-600">
              {ingredients.filter(i => i.stockQuantity <= i.minStockLevel).length}
            </p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-slate-50 border-b text-slate-600 font-semibold text-sm">
            <tr>
              <th className="px-6 py-4">Tên nguyên liệu</th>
              <th className="px-6 py-4 text-center">Tồn kho</th>
              <th className="px-6 py-4 text-center">Đơn vị</th>
              <th className="px-6 py-4">Trạng thái</th>
              <th className="px-6 py-4 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody className="divide-y text-sm">
            {loading ? (
              <tr><td colSpan={5} className="px-6 py-10 text-center">Đang tải...</td></tr>
            ) : ingredients.map((i) => (
              <tr key={i.id} className="hover:bg-slate-50 transition-colors">
                <td className="px-6 py-4 font-medium text-slate-900">{i.name}</td>
                <td className="px-6 py-4 text-center">
                  <span className={`font-bold ${i.stockQuantity <= i.minStockLevel ? 'text-red-600' : 'text-slate-700'}`}>
                    {i.stockQuantity.toLocaleString()}
                  </span>
                </td>
                <td className="px-6 py-4 text-center text-slate-500 uppercase">{i.unit}</td>
                <td className="px-6 py-4">
                  {i.stockQuantity <= i.minStockLevel ? (
                    <span className="flex items-center gap-1 text-red-600 font-medium">
                      <ArrowDown size={14} /> Cần nhập thêm
                    </span>
                  ) : (
                    <span className="flex items-center gap-1 text-green-600 font-medium">
                      <ArrowUp size={14} /> An toàn
                    </span>
                  )}
                </td>
                <td className="px-6 py-4 text-right">
                  <button
                    onClick={() => { setSelectedIngredient(i); setShowImportModal(true); }}
                    className="text-blue-600 hover:bg-blue-50 px-3 py-1 rounded transition-colors font-medium"
                  >
                    Nhập kho
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modal Thêm nguyên liệu */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
            <h2 className="text-xl font-bold mb-4">Thêm nguyên liệu mới</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Tên nguyên liệu</label>
                <input className="w-full border rounded-lg px-3 py-2" placeholder="Ví dụ: Cà phê bột, Sữa đặc..." value={newIngredient.name} onChange={e => setNewIngredient({...newIngredient, name: e.target.value})} required />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Đơn vị</label>
                  <select className="w-full border rounded-lg px-3 py-2" value={newIngredient.unit} onChange={e => setNewIngredient({...newIngredient, unit: e.target.value})}>
                    <option value="g">Gram (g)</option>
                    <option value="ml">Mililit (ml)</option>
                    <option value="kg">Kilogram (kg)</option>
                    <option value="l">Lít (l)</option>
                    <option value="piece">Cái/Chiếc</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Mức cảnh báo</label>
                  <input type="number" className="w-full border rounded-lg px-3 py-2" value={newIngredient.minStockLevel} onChange={e => setNewIngredient({...newIngredient, minStockLevel: Number(e.target.value)})} required />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4">
                <button type="button" onClick={() => setShowModal(false)} className="px-4 py-2 border rounded-lg">Hủy</button>
                <button type="submit" className="px-4 py-2 bg-slate-900 text-white rounded-lg">Lưu lại</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Nhập kho */}
      {showImportModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-sm shadow-xl">
            <h2 className="text-xl font-bold mb-2">Nhập kho nguyên liệu</h2>
            <p className="text-sm text-slate-500 mb-4">{selectedIngredient?.name}</p>
            <form onSubmit={handleImport} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1 text-slate-700">Số lượng nhập thêm ({selectedIngredient?.unit})</label>
                <input type="number" className="w-full border-2 border-slate-900 rounded-lg px-3 py-3 text-xl font-bold" value={importQty} onChange={e => setImportQty(Number(e.target.value))} autoFocus required />
              </div>
              <div className="flex justify-end gap-2 pt-2">
                <button type="button" onClick={() => setShowImportModal(false)} className="px-4 py-2 border rounded-lg">Hủy</button>
                <button type="submit" className="px-4 py-2 bg-green-600 text-white rounded-lg">Xác nhận nhập</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
