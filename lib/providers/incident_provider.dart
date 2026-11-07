import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  StreamSubscription<List<Incident>>? _incidentsSubscription;

  IncidentProvider({IncidentService? service})
    : _service = service ?? IncidentService() {
    _listenToIncidents();
  }

  bool isLoading = false;
  bool isLoadingIncidents = true;
  String? errorMessage;
  List<Incident> _incidents = [];
  String _searchText = '';
  String? _selectedCategory;
  String? _selectedStatus;

  static const categories = [
    'Water',
    'Electricity',
    'Broken Facility',
    'Furniture',
    'Sanitation',
    'Safety',
    'Other',
  ];

  static const statuses = ['Pending', 'In Progress', 'Resolved'];

  List<Incident> get filteredIncidents {
    final search = _searchText.toLowerCase();
    return _incidents.where((incident) {
      final matchesSearch =
          search.isEmpty ||
          incident.title.toLowerCase().contains(search) ||
          incident.description.toLowerCase().contains(search) ||
          incident.location.toLowerCase().contains(search) ||
          incident.category.toLowerCase().contains(search);
      final matchesCategory =
          _selectedCategory == null || incident.category == _selectedCategory;
      final matchesStatus =
          _selectedStatus == null || incident.status == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  String get searchText => _searchText;
  String? get selectedCategory => _selectedCategory;
  String? get selectedStatus => _selectedStatus;

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void _listenToIncidents() {
    _incidentsSubscription = _service.incidentsStream().listen(
      (incidents) {
        _incidents = incidents;
        isLoadingIncidents = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoadingIncidents = false;
        errorMessage = 'We could not load incidents. Please try again.';
        notifyListeners();
      },
    );
  }

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

  @override
  void dispose() {
    _incidentsSubscription?.cancel();
    super.dispose();
  }
}
