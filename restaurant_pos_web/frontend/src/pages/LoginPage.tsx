import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api/client";
import { saveAuthSession } from "../api/authStorage";
import type { AuthResponse } from "../types";

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    try {
      const { data } = await api.post<AuthResponse>("/auth/login", { username, password });
      saveAuthSession(data);
      navigate("/");
    } catch {
      setError("Invalid username or password.");
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center px-4">
      <form onSubmit={submit} className="w-full max-w-md bg-white rounded-2xl p-8 shadow-lg space-y-4">
        <h1 className="text-2xl font-bold text-slate-800">Login</h1>
        <input className="w-full border rounded-lg px-3 py-2" placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} />
        <input className="w-full border rounded-lg px-3 py-2" type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} />
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button className="w-full bg-slate-900 text-white rounded-lg py-2 font-medium">Sign in</button>
        <p className="text-sm text-slate-600">No account? <Link className="text-blue-600" to="/register">Register</Link></p>
      </form>
    </div>
  );
}
