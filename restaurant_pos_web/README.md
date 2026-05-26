# Restaurant POS Web (Graduation Project)

Monorepo gồm:
- `backend`: ASP.NET Core Web API + EF Core + JWT + SignalR + PostgreSQL
- `frontend`: React + TypeScript + Tailwind CSS + Axios + React Router

## 1) Chạy local

### Backend
1. Sửa chuỗi kết nối ở `backend/appsettings.json`
2. Chạy migration (nếu cần tạo DB từ đầu):
   - `dotnet tool install --global dotnet-ef`
   - `dotnet ef migrations add Init`
   - `dotnet ef database update`
3. Run API:
   - `dotnet run`

API mặc định: `http://localhost:5000` (hoặc theo profile local)

### Frontend
1. Tạo file `.env` từ `.env.example`
2. Run app:
   - `npm install`
   - `npm run dev`

Frontend mặc định: `http://localhost:5173`

## 2) Deploy

### Backend (Render)
- Root Directory: `backend`
- Build Command: `dotnet publish -c Release -o out`
- Start Command: `dotnet out/RestaurantPos.Api.dll`
- Environment Variables:
  - `ConnectionStrings__DefaultConnection`
  - `Jwt__SecretKey`
  - `Frontend__Url`

### Frontend (Vercel)
- Root Directory: `frontend`
- Build Command: `npm run build`
- Output Directory: `dist`
- Environment Variables:
  - `VITE_API_BASE_URL=https://<your-render-domain>/api`
  - `VITE_API_ROOT_URL=https://<your-render-domain>`
