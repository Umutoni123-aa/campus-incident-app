import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        displayStatus(status),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: statusColor(status),
      visualDensity: VisualDensity.compact,
    );
  }
}
