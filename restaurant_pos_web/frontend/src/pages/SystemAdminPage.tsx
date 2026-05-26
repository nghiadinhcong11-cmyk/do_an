import { useEffect, useState } from "react";
import api from "../api/client";

type Restaurant = {
  id: string;
  name: string;
  ownerId: string;
  status: string;
  isActive: boolean;
  createdAtUtc: string;
};

type SystemStats = {
  totalRestaurants: number;
  totalUsers: number;
  totalOrders: number;
};

export default function SystemAdminPage() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [stats, setStats] = useState<SystemStats | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const [resRestaurants, resStats] = await Promise.all([
          api.get<Restaurant[]>("/system-admin/restaurants"),
          api.get<SystemStats>("/system-admin/stats"),
        ]);
        setRestaurants(resRestaurants.data);
        setStats(resStats.data);
      } catch {
        alert("Loi tai du lieu he thong");
      }
    })();
  }, []);

  const toggleLock = async (id: string) => {
    try {
      const res = await api.patch<{ isActive: boolean }>(`/system-admin/restaurants/${id}/toggle-lock`, {});
      setRestaurants((prev) => prev.map((r) => (r.id === id ? { ...r, isActive: res.data.isActive } : r)));
    } catch {
      alert("Loi thao tac");
    }
  };

  return <div>{stats?.totalRestaurants} {restaurants.map((r) => <button key={r.id} onClick={() => toggleLock(r.id)}>{r.name}</button>)}</div>;
}
