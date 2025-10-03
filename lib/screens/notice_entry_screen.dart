import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/notice.dart';
import '../services/database_service.dart';

class NoticeEntryScreen extends StatefulWidget {
  const NoticeEntryScreen({Key? key}) : super(key: key);

  @override
  _NoticeEntryScreenState createState() => _NoticeEntryScreenState();
}

class _NoticeEntryScreenState extends State<NoticeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  NoticeCategory _selectedCategory = NoticeCategory.general;
  String? _filePath;
  final DatabaseService _databaseService = DatabaseService();
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path ?? result.files.single.name;
      });
    }
  }

  void _submitNotice() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      final notice = Notice(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        filePath: _filePath,
      );
      try {
        await _databaseService.insertNotice(notice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice added')),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add notice: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Notice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<NoticeCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: NoticeCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
              ),
              if (_filePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Text('File: ${_filePath!.split(RegExp(r"[\\/]+")).last}'),
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNotice,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Notice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
