import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khms/Controller/announcementControlller.dart';
import 'package:khms/Model/Announcement.dart';

class AnnouncementWidget extends StatefulWidget {
  final String studentId;

  const AnnouncementWidget({super.key, required this.studentId});

  @override
  _AnnouncementWidgetState createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  final AnnouncementController _announcementController =
      AnnouncementController();
  List<Announcement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      List<Announcement> announcements =
          await _announcementController.fetchAnnouncements();
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching announcements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAnnouncementDetails(
      BuildContext context, Announcement announcement) {
    // ... (keep the existing _showAnnouncementDetails method unchanged)
  }

  Widget _buildNoAnnouncementsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements at the moment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_announcements.isEmpty) {
      return _buildNoAnnouncementsMessage();
    }

    return ListView.builder(
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        Announcement announcement = _announcements[index];
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
                DateFormat('dd MMM yyyy h:mm a').format(announcement.createdAt),
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
          onTap: () => _showAnnouncementDetails(context, announcement),
        );
      },
    );
  }
}
