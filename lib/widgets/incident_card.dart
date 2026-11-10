import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../utils/helpers.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;
  final String? dateText;
  final bool showCategory;
  final bool showChevron;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.dateText,
    this.showCategory = false,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(incident: incident),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    if (showCategory)
                      Text(
                        '${incident.category} • ${incident.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        text: incident.location,
                      ),
                    const SizedBox(height: 3),
                    _InfoLine(
                      icon: Icons.access_time,
                      text: dateText ?? timeAgo(incident.createdAt),
                    ),
                  ],
                ),
              ),
              StatusChip(status: incident.status),
              if (showChevron)
                const Padding(
                  padding: EdgeInsets.only(left: 2, top: 8),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Incident incident;

  const _Thumbnail({required this.incident});

  @override
  Widget build(BuildContext context) {
    if (incident.imageBase64 == null) {
      return Container(
        width: 58,
        height: 58,
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
        width: 58,
        height: 58,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
