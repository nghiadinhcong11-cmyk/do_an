# RBAC Matrix (Web + Mobile)

## Roles
- `admin`: quan tri he thong
- `owner`: chu quan
- `manager`: quan ly van hanh
- `staff`: nhan vien ban hang

## Platform scope
- Web: `admin`, `owner` (co the mo rong cho `manager`)
- Mobile: `owner`, `manager`, `staff`

## Permission matrix
| Feature | admin | owner | manager | staff |
|---|---|---|---|---|
| Quan tri users toan he thong | Yes | No | No | No |
| Xem doanh thu toan chuoi trong 1 restaurant | Yes | Yes | No | No |
| Xem doanh thu theo chi nhanh | Yes | Yes | Yes | Yes |
| Tao doanh thu | Yes | Yes | Yes | No |
| Cau hinh quan/chi nhanh | Yes | Yes | Yes (branch scope) | No |

## Current policy mapping in code
- `AdminOnly`: admin
- `OwnerOrAdmin`: admin, owner
- `ManagerOrAbove`: admin, owner, manager
- `StaffOrAbove`: admin, owner, manager, staff

## Tenant isolation rules
- Moi JWT co `restaurant_id` va `branch_id`
- Query du lieu luon loc theo `restaurant_id`
- `manager/staff` bi gioi han tiep theo `branch_id`
- SignalR join group theo:
  - `restaurant:{restaurant_id}`
  - `branch:{restaurant_id}:{branch_id}`
