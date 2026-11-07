import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/incident.dart';

class IncidentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Incident>> incidentsStream() {
    return _firestore
        .collection('incidents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Incident.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    XFile? image,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to submit an incident.');
    }

    String? imageBase64;
    if (image != null) {
      imageBase64 = base64Encode(await image.readAsBytes());
    }

    final userSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final reporterName =
        userSnapshot.data()?['name'] as String? ??
        user.displayName ??
        'Student';

    await _firestore.collection('incidents').add({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'imageBase64': imageBase64,
      'status': 'Pending',
      'reporterId': user.uid,
      'reporterName': reporterName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String incidentId, String status) {
    return _firestore.collection('incidents').doc(incidentId).update({
      'status': status,
    });
  }

  Future<void> deleteIncident(String incidentId) {
    return _firestore.collection('incidents').doc(incidentId).delete();
  }
}
