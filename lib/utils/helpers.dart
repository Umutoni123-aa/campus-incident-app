import 'package:flutter/material.dart';

String displayStatus(String status) =>
    status == 'Pending' ? 'Submitted' : status;

String timeAgo(DateTime? date, {DateTime? now}) {
  if (date == null) return 'Just now';
  final difference = (now ?? DateTime.now()).difference(date.toLocal());
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} hours ago';
  if (difference.inDays < 7) return '${difference.inDays} days ago';
  return '${date.day}/${date.month}/${date.year}';
}

Color statusColor(String status) {
  switch (status) {
    case 'In Progress':
      return Colors.blue;
    case 'Resolved':
      return Colors.green;
    default:
      return Colors.orange;
  }
}

String firstName(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '' : trimmed.split(RegExp(r'\s+')).first;
}

String initials(String name) {
  return name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}
