import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/announcementControlller.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/Model/Announcement.dart';
import 'package:khms/api/firebase_api.dart';

class ManageAnnouncementsPage extends StatefulWidget {
  const ManageAnnouncementsPage({super.key});

  @override
  _ManageAnnouncementsPageState createState() =>
      _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  final UserController _userController = UserController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AnnouncementController _controller = AnnouncementController();

  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    List<Announcement> announcements = await _controller.fetchAnnouncements();
    setState(() {
      _announcements = announcements;
    });
  }

  Future<void> _uploadData() async {
    try {
      await _controller.uploadAnnouncement(
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        imageFile: _imageFile,
      );

      final students = await _userController.fetchAllStudents();

      final studentsWithFCM =
          students.where((student) => student.fcmToken.isNotEmpty);

      for (var student in studentsWithFCM) {
        FirebaseApi.sendNotification(
          'Students',
          student.studentId!,
          _titleController.text,
          _descriptionController.text,
        );
      }

      _showSnackBar('Announcement uploaded successfully');
      _clearInputFields();
      _fetchAnnouncements();
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = selectedImage;
    });
  }

  Future<void> _removeAnnouncement(String id) async {
    try {
      await _controller.removeAnnouncement(id);
      _showSnackBar('Announcement removed successfully');
      _fetchAnnouncements();
    } catch (e) {
      _showSnackBar('Error removing announcement: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearInputFields() {
    _titleController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Announcements'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAnnouncementForm(),
              const SizedBox(height: 24),
              _buildCurrentAnnouncements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create New Announcement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildTextField(_titleController, 'Title'),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(_imageUrlController, 'Image URL (optional)'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Announcement'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _uploadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(_imageFile!.path),
                height: 200, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('No image selected')),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Select Image'),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  Widget _buildCurrentAnnouncements() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Current Announcements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _announcements.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return ListTile(
                  title: Text(
                    announcement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.description),
                      Text(
                        DateFormat('dd MMM yyyy h:mm a')
                            .format(announcement.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      announcement.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _showDeleteConfirmation(context, announcement),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to delete the announcement '${announcement.title}'?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _removeAnnouncement(announcement.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
