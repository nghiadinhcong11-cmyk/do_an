import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import Layout from "./components/Layout";
import DashboardPage from "./pages/DashboardPage";
import ForbiddenPage from "./pages/ForbiddenPage";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import ProductsPage from "./pages/ProductsPage";
import TablesPage from "./pages/TablesPage";
import StaffPage from "./pages/StaffPage";
import BranchesPage from "./pages/BranchesPage";
import InventoryPage from "./pages/InventoryPage";
import SystemAdminPage from "./pages/SystemAdminPage";
import PublicMenuPage from "./pages/PublicMenuPage";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/forbidden" element={<ForbiddenPage />} />

      {/* Public Routes */}
      <Route path="/menu/:restaurantId" element={<PublicMenuPage />} />

      <Route element={<ProtectedRoute allowedRoles={["admin", "owner", "manager", "staff"]} />}>
        <Route element={<Layout />}>
          <Route path="/" element={<DashboardPage />} />

          {/* Owner & Manager Routes */}
          <Route element={<ProtectedRoute allowedRoles={["admin", "owner", "manager"]} />}>
            <Route path="/products" element={<ProductsPage />} />
            <Route path="/branches" element={<BranchesPage />} />
            <Route path="/tables" element={<TablesPage />} />
            <Route path="/inventory" element={<InventoryPage />} />
            <Route path="/staff" element={<StaffPage />} />
          </Route>

          {/* System Admin Routes */}
          <Route element={<ProtectedRoute allowedRoles={["admin"]} />}>
            <Route path="/admin/users" element={<SystemAdminPage />} />
          </Route>
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
