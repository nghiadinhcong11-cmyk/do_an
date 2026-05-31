export type UserRole = "admin" | "owner" | "staff" | "customer";

export type AuthResponse = {
  token: string;
  username: string;
  role: UserRole;
  restaurantId: string;
  restaurantName?: string;
  branchId: string | null;
  restaurantStatus?: string;
  bankCode?: string;
  bankAccountNumber?: string;
  bankAccountName?: string;
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
  restaurantId: string;
  categoryId?: string;
  sku?: string;
  name: string;
  description?: string;
  price: number;
  costPrice: number;
  unit?: string;
  imageUrl?: string;
  isAvailable: boolean;
  isVisibleToStaff: boolean;
  isBestSeller: boolean;
  isArchived: boolean;
  displayOrder: number;
  createdAtUtc: string;
  updatedAtUtc: string;
};

export type Category = {
  id: string;
  restaurantId: string;
  name: string;
  description?: string;
  imageUrl?: string;
  displayOrder: number;
  isActive: boolean;
  createdAtUtc: string;
  updatedAtUtc: string;
};

export type Branch = {
  id: string;
  restaurantId: string;
  name: string;
  address?: string;
  phone?: string;
  email?: string;
  managerUserId?: string;
  openTime?: string;
  closeTime?: string;
  vatRate: number;
  isActive: boolean;
  createdAtUtc: string;
  updatedAtUtc: string;
};

export type RestaurantTable = {
  id: string;
  restaurantId: string;
  branchId?: string;
  name: string;
  seats: number;
  displayOrder: number;
  qrToken?: string;
  status: string;
  isActive: boolean;
  createdAtUtc: string;
  updatedAtUtc: string;
};

export type AppUser = {
  id: number;
  username: string;
  fullName?: string;
  email?: string;
  phoneNumber?: string;
  role: UserRole;
  restaurantId?: string;
  branchId?: string;
  isActive: boolean;
  isDeleted: boolean;
  lastLoginUtc?: string;
  createdAtUtc: string;
  updatedAtUtc: string;
};

export type Order = {
  id: string;
  restaurantId: string;
  branchId?: string;
  tableId: string;
  customerId?: string;
  voucherId?: string;
  createdByUserId?: number;
  invoiceNo: string;
  lookupCode: string;
  type?: string;
  status?: string;
  paymentMethod?: string;
  paymentStatus?: string;
  paymentContent?: string;
  paymentReference?: string;
  itemCount: number;
  subTotal: number;
  discountAmount: number;
  vatAmount: number;
  totalAmount: number;
  notes?: string;
  paidAtUtc?: string;
  createdAtUtc: string;
  updatedAtUtc: string;
  items: OrderItem[];
};

export type OrderItem = {
  id: number;
  orderId: string;
  productId: string;
  productName?: string;
  unitPrice: number;
  quantity: number;
  lineTotal: number;
  notes?: string;
  createdAtUtc: string;
};
