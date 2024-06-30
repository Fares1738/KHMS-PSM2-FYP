// models/announcement.dart
class Announcement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Announcement.fromMap(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
