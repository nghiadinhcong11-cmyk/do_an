import { useState } from "react";
import { Link, Outlet, useNavigate } from "react-router-dom";
import { clearAuthSession, getCurrentRole } from "../api/authStorage";

export default function Layout() {
  const navigate = useNavigate();
  const role = getCurrentRole();
  const username = localStorage.getItem("username");
  const restaurantName = localStorage.getItem("restaurantName");
  const restaurantStatus = localStorage.getItem("restaurantStatus");
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const logout = () => {
    clearAuthSession();
    navigate("/login");
  };

  const isOwner = role === "owner" || role === "admin";
  const isCustomer = role === "customer";
  const isApproved = restaurantStatus === "Approved" || role === "admin";

  const closeSidebar = () => setIsSidebarOpen(false);

  return (
    <div className="flex min-h-screen bg-slate-50 relative">
      {/* Mobile Backdrop */}
      {isSidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden backdrop-blur-sm"
          onClick={closeSidebar}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed inset-y-0 left-0 z-50 w-64 bg-slate-900 text-slate-300 flex flex-col transform transition-transform duration-300 ease-in-out
        lg:relative lg:translate-x-0
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="p-6 text-white border-b border-slate-800 flex justify-between items-center">
          <div>
            <div className="font-bold text-xl mb-1">FokaPOS</div>
            {restaurantName && (
              <div className="text-xs text-blue-400 font-medium truncate uppercase tracking-wider">
                {restaurantName}
              </div>
            )}
          </div>
          <button onClick={closeSidebar} className="lg:hidden text-slate-400 hover:text-white">
             <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </button>
        </div>
        <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
          {!isCustomer && (
            <Link to="/" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
              Dashboard
            </Link>
          )}

          {isOwner && (
            <Link to="/restaurant-profile" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
              Hồ sơ nhà hàng
            </Link>
          )}

          {isOwner && isApproved && (
            <>
              <Link to="/products" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý món ăn
              </Link>
              <Link to="/categories" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý danh mục
              </Link>
              <Link to="/branches" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý chi nhánh
              </Link>
              <Link to="/tables" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý bàn
              </Link>
              <Link to="/inventory" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý kho
              </Link>
              <Link to="/staff" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Quản lý nhân viên
              </Link>
            </>
          )}

          {isCustomer && (
            <>
              <Link to="/" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Trang chủ của bạn
              </Link>
              <Link to="/history" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white transition-colors">
                Lịch sử ăn uống
              </Link>
              <Link to="/vouchers" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white text-orange-400 font-bold transition-colors">
                Ưu đãi & Quà tặng
              </Link>
            </>
          )}

          {role === "admin" && (
            <Link to="/admin/users" onClick={closeSidebar} className="block px-4 py-2 rounded hover:bg-slate-800 hover:text-white text-orange-400 transition-colors border border-orange-400/20">
              Quản trị hệ thống
            </Link>
          )}
        </nav>
        <div className="p-4 border-t border-slate-800 bg-slate-950/50">
          <div className="text-sm mb-2 font-medium">{username}</div>
          <div className="text-[10px] uppercase text-slate-500 mb-3 tracking-tighter italic">Vai trò: {role}</div>
          <button onClick={logout} className="w-full flex items-center gap-2 px-4 py-2 rounded bg-red-500/10 hover:bg-red-500/20 text-red-400 transition-all text-sm font-bold">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
            Đăng xuất
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Mobile Top Header */}
        <header className="lg:hidden bg-white border-b p-4 flex items-center justify-between sticky top-0 z-30 shadow-sm">
          <button
            onClick={() => setIsSidebarOpen(true)}
            className="p-2 -ml-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div className="font-black text-blue-600 tracking-tight">FokaPOS</div>
          <div className="w-10"></div> {/* Spacer for symmetry */}
        </header>

        {/* Content */}
        <main className="flex-1 p-4 md:p-8 overflow-auto">
          {restaurantStatus === 'Pending' && role === 'owner' && (
            <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-6 rounded-r-xl shadow-sm">
              <p className="text-xs md:text-sm text-yellow-700 font-medium">
                Cửa hàng đang chờ duyệt. Một số tính năng sẽ bị hạn chế.
              </p>
            </div>
          )}
          {restaurantStatus === 'Rejected' && role === 'owner' && (
            <div className="bg-red-50 border-l-4 border-red-400 p-4 mb-6 rounded-r-xl shadow-sm">
              <p className="text-xs md:text-sm text-red-700 font-medium">Yêu cầu bị từ chối. Vui lòng liên hệ hỗ trợ.</p>
            </div>
          )}
          <Outlet />
        </main>
      </div>
    </div>
  );
}
