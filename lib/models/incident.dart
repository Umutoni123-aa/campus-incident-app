import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String? imageUrl;
  final String status;
  final String reporterId;
  final String reporterName;
  final DateTime? createdAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'] as Timestamp?;
    return Incident(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      location: data['location'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      status: data['status'] as String? ?? 'Pending',
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      createdAt: timestamp?.toDate(),
    );
  }

  Incident copyWith({String? status}) {
    return Incident(
      id: id,
      title: title,
      description: description,
      category: category,
      location: location,
      imageUrl: imageUrl,
      status: status ?? this.status,
      reporterId: reporterId,
      reporterName: reporterName,
      createdAt: createdAt,
    );
  }
}
