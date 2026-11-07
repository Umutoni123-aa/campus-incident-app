import 'package:flutter/material.dart';

import '../models/incident.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

  Color _statusColor() {
    switch (incident.status) {
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(BuildContext context) {
    final date = incident.createdAt;
    if (date == null) return 'Just now';
    final localDate = date.toLocal();
    final dateText = MaterialLocalizations.of(context).formatFullDate(localDate);
    final timeText = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(localDate),
    );
    return '$dateText, $timeText';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incident.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                incident.imageUrl!,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 120,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(incident.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              incident.status,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: _statusColor(),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Category', value: incident.category),
          _DetailRow(label: 'Location', value: incident.location),
          _DetailRow(label: 'Reported by', value: incident.reporterName),
          _DetailRow(label: 'Date', value: _formatDate(context)),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(incident.description),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
