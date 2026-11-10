import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/helpers.dart';
import '../widgets/status_chip.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

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
      appBar: AppBar(title: const Text('Incident Details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IncidentThumbnail(incident: currentIncident),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentIncident.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              StatusChip(status: currentIncident.status),
                              _IconDetail(
                                icon: Icons.calendar_today_outlined,
                                text:
                                    'Submitted on ${_formatDate(context, currentIncident.createdAt)}',
                              ),
                              _IconDetail(
                                icon: Icons.person_outline,
                                text:
                                    'Reported by ${currentIncident.reporterName}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _StatusTimeline(status: currentIncident.status),
                const SizedBox(height: 20),
                if (auth.isStaff)
                  _StaffStatusControls(incident: currentIncident),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(currentIncident.description),
                const SizedBox(height: 16),
                _DetailRow(label: 'Category', value: currentIncident.category),
                _DetailRow(label: 'Location', value: currentIncident.location),
                if (currentIncident.imageBase64 != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Attached Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _decodeImage(currentIncident.imageBase64!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
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
          ),
        ),
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

class _IncidentThumbnail extends StatelessWidget {
  final Incident incident;

  const _IncidentThumbnail({required this.incident});

  @override
  Widget build(BuildContext context) {
    if (incident.imageBase64 == null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(incident.imageBase64!),
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _IconDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffStatusControls extends StatefulWidget {
  final Incident incident;

  const _StaffStatusControls({required this.incident});

  @override
  State<_StaffStatusControls> createState() => _StaffStatusControlsState();
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    const steps = ['Submitted', 'In Progress', 'Resolved'];
    final storedSteps = ['Pending', 'In Progress', 'Resolved'];
    final currentIndex = storedSteps.indexOf(status).clamp(0, steps.length - 1);
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: index <= currentIndex
                        ? primary
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: index == currentIndex
                        ? Border.all(color: primary, width: 3)
                        : null,
                  ),
                  child: Icon(
                    index < currentIndex ? Icons.check : Icons.circle,
                    size: index < currentIndex ? 18 : 10,
                    color: index <= currentIndex ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: index == currentIndex ? FontWeight.bold : null,
                    color: index <= currentIndex ? primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (index < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: index < currentIndex ? primary : Colors.grey.shade300,
              ),
            ),
        ],
      ],
    );
  }
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
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(displayStatus(status)),
                ),
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
