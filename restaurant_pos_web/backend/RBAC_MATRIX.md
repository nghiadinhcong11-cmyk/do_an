# RBAC Matrix (Web + Mobile)

## Roles
- `admin`: quan tri he thong
- `owner`: chu quan
- `staff`: nhan vien ban hang
- `customer`: khach hang

## Platform scope
- Web: `admin`, `owner`
- Mobile: `owner`, `staff`

## Permission matrix
| Feature | admin | owner | staff |
|---|---|---|---|
| Quan tri users toan he thong | Yes | No | No |
| Xem doanh thu toan chuoi trong 1 restaurant | Yes | Yes | No |
| Xem doanh thu theo chi nhanh | Yes | Yes | Yes |
| Tao doanh thu | Yes | Yes | No |
| Cau hinh quan/chi nhanh | Yes | Yes | No |

## Current policy mapping in code
- `AdminOnly`: admin
- `OwnerOrAdmin`: admin, owner
- `StaffOrAbove`: admin, owner, staff

## Tenant isolation rules
- Moi JWT co `restaurant_id` va `branch_id`
- Query du lieu luon loc theo `restaurant_id`
- `manager/staff` bi gioi han tiep theo `branch_id`
- SignalR join group theo:
  - `restaurant:{restaurant_id}`
  - `branch:{restaurant_id}:{branch_id}`
