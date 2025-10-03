import 'package:flutter/material.dart';
import '../models/notice.dart';
import 'notice_detail_screen.dart';
import 'notice_entry_screen.dart';
import '../services/database_service.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({Key? key}) : super(key: key);

  @override
  _NoticeListScreenState createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  NoticeCategory? _selectedCategory;
  String _searchQuery = '';

  Color _getCategoryColor(NoticeCategory category) {
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Notices',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
                ...NoticeCategory.values.map((category) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category.label),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Notice>>(
              future: _searchQuery.isEmpty
                  ? _databaseService.getNoticesByCategory(_selectedCategory)
                  : _databaseService.searchNotices(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notices found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final notice = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(notice.title),
                        subtitle: Text(notice.category.name),
                        trailing: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(notice.category),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            notice.category.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoticeDetailScreen(notice: notice),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoticeEntryScreen()),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
