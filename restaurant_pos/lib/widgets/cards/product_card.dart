import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/utils/app_format.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Function() onEdit;
  final Function() onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Hiển thị ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.imagePath != null && product.imagePath!.isNotEmpty
                  ? Image.file(
                      File(product.imagePath!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.blue[50],
                      child: Icon(Icons.restaurant, color: Colors.blue[200], size: 30),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giá bán: ${AppFormat.money(product.price)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Giá vốn: ${AppFormat.money(product.costPrice)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        label: "Sửa",
                        icon: Icons.edit,
                        color: Colors.blue[50]!,
                        textColor: Colors.blue[700]!,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        label: "Xóa",
                        icon: Icons.delete_outline,
                        color: Colors.red[50]!,
                        textColor: Colors.red[700]!,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
