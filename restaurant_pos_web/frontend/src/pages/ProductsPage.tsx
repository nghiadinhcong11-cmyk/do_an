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

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Quan ly thuc don</h1>
        <button onClick={() => { setEditingProduct({ category: "Khac", price: 0, costPrice: 0 }); setShowModal(true); }} className="bg-blue-600 text-white px-4 py-2 rounded-lg">+ Them mon moi</button>
      </div>
      <div className="bg-white rounded-xl shadow border overflow-hidden">
        {loading ? <p className="p-4">Dang tai...</p> : products.map((p) => (
          <div key={p.id} className="p-4 border-b flex justify-between">
            <span>{p.name}</span>
            <div className="space-x-2">
              <button onClick={() => { setEditingProduct(p); setShowModal(true); }}>Sua</button>
              <button onClick={() => deleteProduct(p.id)}>Xoa</button>
            </div>
          </div>
        ))}
      </div>
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <form onSubmit={handleSubmit} className="space-y-4">
              <input className="w-full border rounded-lg px-3 py-2" value={editingProduct?.name || ""} onChange={(e) => setEditingProduct({ ...editingProduct, name: e.target.value })} />
              <input type="number" className="w-full border rounded-lg px-3 py-2" value={editingProduct?.price || ""} onChange={(e) => setEditingProduct({ ...editingProduct, price: Number(e.target.value) })} />
              <button className="px-4 py-2 bg-blue-600 text-white rounded-lg">Luu</button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
