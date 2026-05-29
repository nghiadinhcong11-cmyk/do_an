import { Link, Outlet, useNavigate } from "react-router-dom";
import { clearAuthSession, getCurrentRole } from "../api/authStorage";

export default function Layout() {
  const navigate = useNavigate();
  const role = getCurrentRole();
  const username = localStorage.getItem("username");
  const restaurantName = localStorage.getItem("restaurantName");
  const restaurantStatus = localStorage.getItem("restaurantStatus");

  const logout = () => {
    clearAuthSession();
    navigate("/login");
  };

  const isOwner = role === "owner" || role === "admin";
  const isCustomer = role === "customer";
  const isApproved = restaurantStatus === "Approved" || role === "admin";

  return (
    <div className="flex min-h-screen bg-slate-50">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col">
        <div className="p-6 text-white border-b border-slate-800">
          <div className="font-bold text-xl mb-1">FokaPOS</div>
          {restaurantName && (
            <div className="text-xs text-blue-400 font-medium truncate uppercase tracking-wider">
              {restaurantName}
            </div>
          )}
        </div>
        <nav className="flex-1 p-4 space-y-2">
          {!isCustomer && (
            <Link to="/" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
              Dashboard
            </Link>
          )}

          {isOwner && (
            <Link to="/restaurant-profile" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
              Hồ sơ nhà hàng
            </Link>
          )}

          {isOwner && isApproved && (
            <>
              <Link to="/products" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Quản lý món ăn
              </Link>
              <Link to="/branches" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Quản lý chi nhánh
              </Link>
              <Link to="/tables" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Quản lý bàn
              </Link>
              <Link to="/inventory" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Quản lý kho
              </Link>
              <Link to="/staff" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Quản lý nhân viên
              </Link>
            </>
          )}

          {isCustomer && (
            <>
              <Link to="/" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Thực đơn & Đặt món
              </Link>
              <Link to="/history" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white">
                Lịch sử gọi món
              </Link>
              <Link to="/points" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white text-yellow-500">
                Điểm tích lũy & Ưu đãi
              </Link>
            </>
          )}

          {role === "admin" && (
            <Link to="/admin/users" className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white text-orange-400">
              Quản trị hệ thống
            </Link>
          )}
        </nav>
        <div className="p-4 border-t border-slate-800">
          <div className="text-sm mb-2">{username} ({role})</div>
          <button onClick={logout} className="w-full text-left px-4 py-2 rounded hover:bg-slate-800 text-red-400">
            Đăng xuất
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8 overflow-auto">
        {restaurantStatus === 'Pending' && role === 'owner' && (
          <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-6">
            <p className="text-sm text-yellow-700 font-medium">
              Cửa hàng của bạn đang chờ Admin phê duyệt. Một số tính năng sẽ bị hạn chế cho đến khi được kích hoạt.
            </p>
          </div>
        )}
        {restaurantStatus === 'Rejected' && role === 'owner' && (
          <div className="bg-red-50 border-l-4 border-red-400 p-4 mb-6">
            <p className="text-sm text-red-700 font-medium">Yêu cầu tạo quán của bạn đã bị từ chối. Vui lòng liên hệ hỗ trợ.</p>
          </div>
        )}
        <Outlet />
      </main>
    </div>
  );
}
