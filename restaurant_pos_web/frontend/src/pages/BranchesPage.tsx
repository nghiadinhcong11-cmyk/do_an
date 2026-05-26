import { useEffect, useState } from "react";
import api from "../api/client";
import type { Branch } from "../types";

export default function BranchesPage() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);
  const [newBranch, setNewBranch] = useState({ name: "", address: "", phone: "" });

  useEffect(() => {
    void (async () => {
      try {
        const res = await api.get<Branch[]>("/branches");
        setBranches(res.data);
      } catch {
        alert("Loi tai chi nhanh");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const fetchBranches = async () => {
    try {
      const res = await api.get<Branch[]>("/branches");
      setBranches(res.data);
    } catch {
      alert("Loi tai chi nhanh");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.post("/branches", newBranch);
      setNewBranch({ name: "", address: "", phone: "" });
      fetchBranches();
    } catch {
      alert("Loi khi them chi nhanh");
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Quan ly chi nhanh</h1>
      <div className="grid md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl border h-fit shadow-sm">
          <h2 className="font-semibold mb-4">Them chi nhanh moi</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <input className="w-full border rounded-lg px-3 py-2" placeholder="Ten chi nhanh" value={newBranch.name} onChange={(e) => setNewBranch({ ...newBranch, name: e.target.value })} required />
            <input className="w-full border rounded-lg px-3 py-2" placeholder="Dia chi" value={newBranch.address} onChange={(e) => setNewBranch({ ...newBranch, address: e.target.value })} />
            <input className="w-full border rounded-lg px-3 py-2" placeholder="So dien thoai" value={newBranch.phone} onChange={(e) => setNewBranch({ ...newBranch, phone: e.target.value })} />
            <button className="w-full bg-slate-900 text-white py-2 rounded-lg">Luu chi nhanh</button>
          </form>
        </div>

        <div className="md:col-span-2 space-y-4">
          {loading ? <p>Dang tai...</p> : branches.map((b) => (
            <div key={b.id} className="bg-white p-4 rounded-xl border flex justify-between items-center shadow-sm">
              <div>
                <p className="font-bold text-lg">{b.name}</p>
                <p className="text-sm text-slate-500">{b.address || "Khong co dia chi"}</p>
                <p className="text-sm text-slate-500">{b.phone}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
