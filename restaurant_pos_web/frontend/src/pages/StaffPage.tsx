import { useEffect, useState } from "react";
import api from "../api/client";
import type { AppUser } from "../types";
import { Link } from "react-router-dom";

export default function StaffPage() {
  const [users, setUsers] = useState<AppUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void (async () => {
      try {
        const res = await api.get<AppUser[]>("/users");
        setUsers(res.data);
      } catch {
        alert("Loi tai nhan vien");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await api.get<AppUser[]>("/users");
      setUsers(res.data);
    } catch {
      alert("Loi tai nhan vien");
    } finally {
      setLoading(false);
    }
  };

  const deleteUser = async (id: number) => {
    if (!confirm("Xoa nhan vien nay?")) return;
    try {
      await api.delete(`/users/${id}`);
      fetchUsers();
    } catch {
      alert("Loi khi xoa");
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Quan ly nhan vien</h1>
        <Link to="/register" className="bg-slate-900 text-white px-4 py-2 rounded-lg">+ Cap tai khoan moi</Link>
      </div>
      {loading ? <p>Dang tai...</p> : users.map((u) => <div key={u.id}><span>{u.username}</span><button onClick={() => deleteUser(u.id)}>Xoa</button></div>)}
    </div>
  );
}
