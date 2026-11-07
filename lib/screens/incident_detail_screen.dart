import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

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
    final dateText = MaterialLocalizations.of(context)
        .formatFullDate(localDate);
    final timeText = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(localDate));
    return '$dateText, $timeText';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final currentIncident = provider.incidentById(incident.id) ?? incident;
    final auth = context.watch<AuthProvider>();
    final canDelete =
        auth.isStaff ||
        (auth.currentUser?.uid == currentIncident.reporterId &&
            currentIncident.status == 'Pending');
    return Scaffold(
      appBar: AppBar(title: const Text('Incident details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (currentIncident.imageBase64 != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _decodeImage(currentIncident.imageBase64!),
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            currentIncident.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              currentIncident.status,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: _statusColor(currentIncident.status),
          ),
          const SizedBox(height: 16),
          if (auth.isStaff) _StaffStatusControls(incident: currentIncident),
          _DetailRow(label: 'Category', value: currentIncident.category),
          _DetailRow(label: 'Location', value: currentIncident.location),
          _DetailRow(label: 'Reported by', value: currentIncident.reporterName),
          _DetailRow(
            label: 'Date',
            value: _formatDate(context, currentIncident.createdAt),
          ),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(currentIncident.description),
          if (canDelete) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => _confirmDelete(context, currentIncident),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete incident'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete incident?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final provider = context.read<IncidentProvider>();
    final deleted = await provider.deleteIncident(incident);
    if (!context.mounted) return;
    if (deleted) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  Uint8List _decodeImage(String value) => base64Decode(value);
}

class _StaffStatusControls extends StatefulWidget {
  final Incident incident;

  const _StaffStatusControls({required this.incident});

  @override
  State<_StaffStatusControls> createState() => _StaffStatusControlsState();
}

class _StaffStatusControlsState extends State<_StaffStatusControls> {
  late String _status = widget.incident.status;

  @override
  void didUpdateWidget(covariant _StaffStatusControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.status != widget.incident.status) {
      _status = widget.incident.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: IncidentProvider.statuses
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
          onChanged: provider.isLoading
              ? null
              : (value) => setState(() => _status = value!),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  final updated = await context
                      .read<IncidentProvider>()
                      .updateStatus(
                        incidentId: widget.incident.id,
                        status: _status,
                      );
                  if (!context.mounted) return;
                  if (!updated &&
                      context.read<IncidentProvider>().errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.read<IncidentProvider>().errorMessage!,
                        ),
                      ),
                    );
                  }
                },
          child: provider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update status'),
        ),
        const SizedBox(height: 16),
      ],
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
