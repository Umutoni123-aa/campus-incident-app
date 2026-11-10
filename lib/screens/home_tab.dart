import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import 'incident_detail_screen.dart';
import 'submit_incident_screen.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;

  const HomeTab({super.key, required this.onSeeAll});

  void _openSubmit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubmitIncidentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.incidents;
    final userId = auth.currentUser?.uid;
    final visible = auth.isStaff
        ? incidents
        : incidents.where((item) => item.reporterId == userId).toList();
    final recent = incidents.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Safe'),
        actions: [
          if (auth.isStaff)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: Chip(label: Text('Staff'))),
            ),
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Hello, ${_firstName(auth.userName)} 👋',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Help make our campus safer.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _ReportBanner(onTap: () => _openSubmit(context)),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Report Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryCard(
                label: 'My Reports',
                count: visible.length,
                color: const Color(0xFFE9E2FF),
                icon: Icons.description_outlined,
              ),
              _SummaryCard(
                label: 'In Progress',
                count: visible.where((i) => i.status == 'In Progress').length,
                color: const Color(0xFFDDEBFF),
                icon: Icons.autorenew,
              ),
              _SummaryCard(
                label: 'Resolved',
                count: visible.where((i) => i.status == 'Resolved').length,
                color: const Color(0xFFDDF5E8),
                icon: Icons.check_circle_outline,
              ),
              _SummaryCard(
                label: 'Pending',
                count: visible.where((i) => i.status == 'Pending').length,
                color: const Color(0xFFFFEBD2),
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Recent Reports',
            action: 'See all',
            onTap: onSeeAll,
          ),
          const SizedBox(height: 8),
          if (provider.isLoadingIncidents)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No reports yet.'),
            )
          else
            ...recent.map((incident) => _RecentReportCard(incident: incident)),
        ],
      ),
    );
  }

  String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;
}

class _ReportBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ReportBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'See an issue on campus?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Let us know so we can make it better.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C4CF1),
              ),
              child: const Text('Report an Issue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: Colors.black54),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentReportCard extends StatelessWidget {
  final Incident incident;

  const _RecentReportCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final statusColor = incident.status == 'Resolved'
        ? Colors.green
        : incident.status == 'In Progress'
        ? Colors.blue
        : Colors.orange;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${incident.category} • ${incident.location}'),
        trailing: Chip(
          label: Text(
            incident.status,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: statusColor,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incident: incident),
          ),
        ),
      ),
    );
  }
}
