import 'package:flutter/material.dart';
import 'package:internal/models/notice.dart';

class CategoryBadge extends StatelessWidget {
  final NoticeCategory category;
  final double size;
  final bool showLabel;
  const CategoryBadge({Key? key, required this.category, this.size = 14, this.showLabel = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(color: category.color.withOpacity(0.5)),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(category.label, style: TextStyle(color: category.color, fontWeight: FontWeight.w600)),
        ]
      ],
    );
  }
}