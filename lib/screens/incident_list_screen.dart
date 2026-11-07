import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import 'incident_detail_screen.dart';

class IncidentListScreen extends StatelessWidget {
  const IncidentListScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return 'Just now';
    final localDate = date.toLocal();
    final dateText = MaterialLocalizations.of(context).formatShortDate(localDate);
    final timeText = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(localDate),
    );
    return '$dateText, $timeText';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: provider.setSearchText,
            decoration: const InputDecoration(
              hintText: 'Search incidents',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        _FilterChips(
          label: 'Category',
          values: IncidentProvider.categories,
          selectedValue: provider.selectedCategory,
          onSelected: provider.setCategory,
        ),
        _FilterChips(
          label: 'Status',
          values: IncidentProvider.statuses,
          selectedValue: provider.selectedStatus,
          onSelected: provider.setStatus,
        ),
        Expanded(
          child: provider.isLoadingIncidents
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredIncidents.isEmpty
                  ? const Center(child: Text('No incidents found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: provider.filteredIncidents.length,
                      itemBuilder: (context, index) {
                        final incident = provider.filteredIncidents[index];
                        return _IncidentCard(
                          incident: incident,
                          statusColor: _statusColor(incident.status),
                          dateText: _formatDate(context, incident.createdAt),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String label;
  final List<String> values;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _FilterChips({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('$label:'),
          ),
          FilterChip(
            label: const Text('All'),
            selected: selectedValue == null,
            onSelected: (_) => onSelected(null),
          ),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(value),
                selected: selectedValue == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final Color statusColor;
  final String dateText;

  const _IncidentCard({
    required this.incident,
    required this.statusColor,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incident: incident),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (incident.imageBase64 != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.memory(
                    _decodeImage(incident.imageBase64!),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${incident.category} • ${incident.location}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            incident.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: statusColor,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          dateText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List _decodeImage(String value) => base64Decode(value);
}
