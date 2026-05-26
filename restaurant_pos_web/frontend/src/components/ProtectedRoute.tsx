import { Navigate, Outlet } from "react-router-dom";

type ProtectedRouteProps = {
  allowedRoles?: string[];
};

export default function ProtectedRoute({ allowedRoles }: ProtectedRouteProps) {
  const token = localStorage.getItem("token");
  if (!token) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && allowedRoles.length > 0) {
    const role = localStorage.getItem("role");
    if (!role || !allowedRoles.includes(role)) {
      return <Navigate to="/forbidden" replace />;
    }
  }

  return <Outlet />;
}
