import 'package:flutter/material.dart';
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
      });
    } catch (e) {
      print('Error fetching announcements: $e');
      // Handle error as needed (e.g., show error message)
    }
  }

  void _showAnnouncementDetails(
      BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  announcement.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        announcement.description,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        Announcement announcement = _announcements[index];
        return ListTile(
          title: Text(announcement.title),
          subtitle: Text(announcement.description),
          leading: Image.network(
            announcement.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          onTap: () => _showAnnouncementDetails(context, announcement),
        );
      },
    );
  }
}
