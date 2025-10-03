import 'package:flutter/material.dart';
import 'screens/notice_list_screen.dart';

void main() {
  runApp(const UniversityNoticeBoardApp());
}

class UniversityNoticeBoardApp extends StatelessWidget {
  const UniversityNoticeBoardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Notice Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NoticeListScreen(),
    );
  }
}
