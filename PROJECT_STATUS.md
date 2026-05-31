# FokaPOS - Nhật ký Trạng thái Dự án (Project Status Log)

Tài liệu này tóm tắt toàn bộ cấu trúc và các tính năng đã hoàn thiện của hệ thống POS Nhà hàng. Dùng để cung cấp ngữ cảnh nhanh cho AI hoặc Developer.

## 🚀 Công nghệ sử dụng (Tech Stack)
- **Backend:** .NET 8 Web API, PostgreSQL (Render), SignalR (Real-time).
- **Web Frontend:** React, TypeScript, Tailwind CSS, Recharts, Vite.
- **Mobile App:** Flutter, Provider (State Management), SQLite (Offline mode).

## 👥 Hệ thống Vai trò (Roles)
1. **Admin (Super Admin):** Quản trị toàn bộ hệ thống, duyệt/khóa các nhà hàng.
2. **Owner (Chủ quán):** Quản lý thực đơn, danh mục, nhân viên, sơ đồ bàn, xem báo cáo doanh thu.
3. **Staff (Nhân viên):** Xem sơ đồ bàn, nhận yêu cầu từ khách, đặt món, thanh toán hóa đơn.
4. **Customer (Khách đăng ký):** Tích điểm, xem hạng thành viên, sử dụng Voucher.
5. **Guest (Khách vãng lai):** Quét QR tại bàn, xem menu, gửi yêu cầu đặt món (Real-time).

## ✅ Các tính năng đã hoàn thiện

### 1. Backend & Hệ thống chung
- [x] **Database Schema:** Đã chuẩn hóa (Users, Restaurants, Products, Categories, Orders, OrderRequests, Loyalty, Vouchers).
- [x] **Authentication:** JWT Token, phân quyền dựa trên Role.
- [x] **Real-time:** SignalR Hub cho trạng thái bàn và yêu cầu của khách.
- [x] **Image Upload:** Hỗ trợ tải ảnh lên server, lưu vào `wwwroot/uploads`.
- [x] **CORS & Proxy:** Cấu hình chuẩn để chạy trên Render (Forwarded Headers).

### 2. Web Frontend (Quản trị)
- [x] **Đăng ký/Đăng nhập:** Hỗ trợ tạo Admin bằng mã bí mật `FOKA@ADMIN`.
- [x] **Duyệt Nhà hàng:** Admin tổng xem hồ sơ và phê duyệt quán mới.
- [x] **Dashboard Chủ quán:** Biểu đồ doanh thu 7 ngày, Top món bán chạy, Thống kê tổng quát.
- [x] **Quản lý Thực đơn:** Nhóm theo danh mục, tìm kiếm, tải ảnh từ máy, thêm mô tả, đơn vị tính.
- [x] **Quản lý Danh mục:** Thêm/Sửa/Xóa và sắp xếp thứ tự hiển thị.
- [x] **Quản lý Bàn:** Tự động tạo mã QR định danh (RestaurantId + TableId).
- [x] **Thiết lập Ngân hàng:** Chủ quán nhập thông tin VietQR để đồng bộ xuống App.
- [x] **Tối ưu Mobile:** Giao diện Web (Sidebar/Form) đã responsive hoàn toàn cho điện thoại.

### 3. Mobile App (Vận hành)
- [x] **Sơ đồ bàn:** Xem trạng thái Trống/Có khách real-time.
- [x] **Xử lý yêu cầu:** Nhận yêu cầu gọi món từ khách qua thông báo (SignalR), tự động lấy đúng giá từ server.
- [x] **Giỏ hàng & Hóa đơn:** Thêm/Sửa/Xóa món, tự động tính thuế VAT 3%.
- [x] **Thanh toán VietQR:** Tự động tạo ảnh mã QR thanh toán theo số tiền hóa đơn và STK của chủ quán.
- [x] **Phân quyền:** Ẩn các mục cấu hình nhạy cảm đối với nhân viên.
- [x] **Điều hướng:** Đã fix lỗi kẹt ở màn hình Profile/History, thêm Drawer Menu.

## 🔑 Thông tin quan trọng (Internal Info)
- **Cơ chế tạo Super Admin:** Sử dụng mã bí mật khi đăng ký trên Web (Mã này nên được cấu hình trong Environment Variables).
- **Luồng gọi món:** Khách quét QR -> Web Menu -> Gửi Request -> App Staff nhận -> Xác nhận -> Vào bàn -> Thanh toán -> Bàn tự động về Trống.
鼓
## 📝 Lưu ý cho AI tiếp theo
- Khi cập nhật Database, luôn sử dụng lệnh `dotnet ef migrations add <Name>` và đảm bảo có `db.Database.Migrate()` trong `Program.cs`.
- Ảnh sản phẩm được lưu vật lý trên Server. Trên Render (bản free), ảnh sẽ mất khi server restart (Ephemeral FS).
- App Flutter và Web React đều kết nối chung một endpoint Backend trên Render.
