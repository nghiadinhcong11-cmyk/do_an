import { useEffect, useMemo, useState } from "react";
import * as signalR from "@microsoft/signalr";
import api from "../api/client";
import { getCurrentRole } from "../api/authStorage";
import type { Revenue } from "../types";

export default function DashboardPage() {
  const [items, setItems] = useState<Revenue[]>([]);
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");
  const [error, setError] = useState("");

  const total = useMemo(() => items.reduce((sum, x) => sum + x.amount, 0), [items]);
  const role = getCurrentRole();
  const canCreateRevenue = role === "admin" || role === "owner";

  useEffect(() => {
    api
      .get<Revenue[]>("/revenues")
      .then((res) => setItems(res.data))
      .catch(() => setError("Cannot load revenues."));

    const token = localStorage.getItem("token");
    if (!token) return;

    const hub = new signalR.HubConnectionBuilder()
      .withUrl((import.meta.env.VITE_API_ROOT_URL ?? "http://localhost:5000") + "/hubs/revenues", {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect()
      .build();

    hub.on("revenueCreated", (data: Revenue) => {
      setItems((prev) => [data, ...prev]);
    });

    hub.start().catch(() => undefined);
    return () => {
      hub.stop().catch(() => undefined);
    };
  }, []);

  const addRevenue = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const amountNumber = Number(amount);
    if (Number.isNaN(amountNumber) || amountNumber <= 0) {
      setError("Invalid amount.");
      return;
    }

    try {
      await api.post("/revenues", { amount: amountNumber, note });
      setAmount("");
      setNote("");
    } catch {
      setError("Cannot create revenue entry.");
    }
  };

  return (
    <div className="text-slate-900">
      <header className="mb-8">
        <h1 className="text-3xl font-bold">Tong quan doanh thu</h1>
        <p className="text-slate-500">Chao mung tro lai, {localStorage.getItem("username")}!</p>
      </header>

      <div className="grid md:grid-cols-3 gap-6">
        {canCreateRevenue && (
          <section className="md:col-span-1 bg-white rounded-xl border p-6 h-fit shadow-sm">
            <h2 className="font-semibold mb-4 text-lg">Ghi nhan doanh thu</h2>
            <form onSubmit={addRevenue} className="space-y-4">
              <input className="w-full border rounded-lg px-3 py-2" placeholder="0" value={amount} onChange={(e) => setAmount(e.target.value)} />
              <input className="w-full border rounded-lg px-3 py-2" placeholder="Ghi chu" value={note} onChange={(e) => setNote(e.target.value)} />
              {error && <p className="text-sm text-red-600">{error}</p>}
              <button className="w-full bg-slate-900 text-white rounded-lg py-2 font-medium">Luu doanh thu</button>
            </form>
          </section>
        )}

        <section className="bg-white rounded-xl border p-6 md:col-span-2 shadow-sm">
          <div className="flex justify-between items-center mb-6">
            <h2 className="font-semibold text-lg text-slate-700">Lich su giao dich</h2>
            <div className="text-right">
              <p className="text-sm text-slate-500">Tong cong</p>
              <p className="text-2xl font-bold text-green-600">{total.toLocaleString("vi-VN")}d</p>
            </div>
          </div>
          <div className="space-y-3 max-h-[600px] overflow-auto pr-2">
            {items.length === 0 ? <p className="text-center py-10 text-slate-400">Chua co du lieu doanh thu</p> : items.map((x) => <div key={x.id} className="border rounded p-3">{x.note || "Doanh thu"}</div>)}
          </div>
        </section>
      </div>
    </div>
  );
}
