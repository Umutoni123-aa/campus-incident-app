import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;

  IncidentProvider({IncidentService? service})
      : _service = service ?? IncidentService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    XFile? image,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.submitIncident(
        title: title,
        description: description,
        category: category,
        location: location,
        image: image,
      );
      return true;
    } catch (_) {
      errorMessage = 'We could not submit your incident. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
