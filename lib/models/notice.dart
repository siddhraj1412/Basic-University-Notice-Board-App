import 'package:flutter/material.dart';

enum NoticeCategory {
  exam('Exam', Colors.red),
  event('Event', Colors.green),
  academic('Academic', Colors.blue),
  general('General', Colors.orange);

  final String label;
  final MaterialColor color;
  const NoticeCategory(this.label, this.color);
}

class Notice {
  final int? id;
  final String title;
  final String description;
  final NoticeCategory category;
  final String? filePath;

  Notice({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'filePath': filePath,
    };
  }

  factory Notice.fromMap(Map<String, dynamic> map) {
    final rawCategory = map['category'];
    NoticeCategory category = NoticeCategory.general;
    if (rawCategory != null) {
      try {
        category =
            NoticeCategory.values.firstWhere((e) => e.name == rawCategory);
      } catch (_) {
        try {
          category =
              NoticeCategory.values.firstWhere((e) => e.label == rawCategory);
        } catch (_) {
          category = NoticeCategory.general;
        }
      }
    }

    return Notice(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: category,
      filePath: map['filePath'],
    );
  }
}
