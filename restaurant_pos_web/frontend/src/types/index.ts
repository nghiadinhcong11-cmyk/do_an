export type UserRole = "admin" | "owner" | "staff" | "customer";

export type AuthResponse = {
  token: string;
  username: string;
  role: UserRole;
  restaurantId: string;
  branchId: string | null;
  restaurantStatus?: string;
};

export type Revenue = {
  id: number;
  amount: number;
  note: string;
  createdAtUtc: string;
  createdBy: string;
  restaurantId: string;
  branchId: string | null;
};

export type Product = {
  id: string;
  name: string;
  price: number;
  costPrice: number;
  category: string;
  imageUrl?: string;
  isVisibleToStaff: boolean;
  isAvailable: boolean;
  isBestSeller: boolean;
};

export type Branch = {
  id: string;
  restaurantId: string;
  name: string;
  address?: string;
  phone?: string;
  isActive: boolean;
};

export type RestaurantTable = {
  id: string;
  name: string;
  seats: number;
  status: string;
};

export type AppUser = {
  id: number;
  username: string;
  role: string;
  restaurantId: string;
  branchId?: string;
};
