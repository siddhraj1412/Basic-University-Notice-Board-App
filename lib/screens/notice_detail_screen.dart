import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../models/notice.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({Key? key, required this.notice}) : super(key: key);

  Color _getCategoryColor(NoticeCategory category) {
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notice.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _getCategoryColor(notice.category),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                notice.category.label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              notice.title,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(notice.description),
            const SizedBox(height: 16.0),
            if (notice.filePath != null) ...[
              const Text('Attached File:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () {
                  OpenFile.open(notice.filePath!);
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(
                    'Open ${notice.filePath!.split(RegExp(r"[\\/]+")).last}'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () {
                  Share.shareXFiles([XFile(notice.filePath!)],
                      text: notice.title);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share File'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
