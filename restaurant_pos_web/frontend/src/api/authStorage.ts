import type { AuthResponse } from "../types";

export function saveAuthSession(data: AuthResponse) {
  localStorage.setItem("token", data.token);
  localStorage.setItem("username", data.username);
  localStorage.setItem("role", data.role);
  localStorage.setItem("restaurantId", data.restaurantId);
  localStorage.setItem("branchId", data.branchId ?? "");
  localStorage.setItem("restaurantStatus", data.restaurantStatus ?? "Approved");
}

export function clearAuthSession() {
  localStorage.removeItem("token");
  localStorage.removeItem("username");
  localStorage.removeItem("role");
  localStorage.removeItem("restaurantId");
  localStorage.removeItem("branchId");
  localStorage.removeItem("restaurantStatus");
}

export function getCurrentRole() {
  return localStorage.getItem("role");
}
