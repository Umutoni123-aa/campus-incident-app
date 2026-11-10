import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/helpers.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final allIncidents = provider.incidents;
    final userId = auth.currentUser?.uid;
    final reports = auth.isStaff
        ? allIncidents
        : allIncidents.where((item) => item.reporterId == userId).toList();
    final filtered = _filter == 'All'
        ? reports
        : reports
              .where((item) => displayStatus(item.status) == _filter)
              .toList();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _ProfileHeader(auth: auth),
              const SizedBox(height: 24),
              Row(
                children: [
                  _StatCard(
                    label: 'Total Reports',
                    value: reports.length,
                    color: const Color(0xFFE9E2FF),
                    icon: Icons.description_outlined,
                  ),
                  _StatCard(
                    label: 'In Progress',
                    value: reports
                        .where((item) => item.status == 'In Progress')
                        .length,
                    color: const Color(0xFFDDEBFF),
                    icon: Icons.autorenew,
                  ),
                  _StatCard(
                    label: 'Resolved',
                    value: reports
                        .where((item) => item.status == 'Resolved')
                        .length,
                    color: const Color(0xFFDDF5E8),
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                auth.isStaff ? 'All Reports' : 'My Reports',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Submitted', 'In Progress', 'Resolved']
                      .map(
                        (value) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(value),
                            selected: _filter == value,
                            onSelected: (_) => setState(() => _filter = value),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isLoadingIncidents)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No reports found.')),
                )
              else
                ...filtered.map(
                  (incident) => IncidentCard(
                    incident: incident,
                    showChevron: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            IncidentDetailScreen(incident: incident),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthProvider auth;

  const _ProfileHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    final userInitials = initials(auth.userName);
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            userInitials.isEmpty ? '?' : userInitials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                auth.currentUser?.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 5),
              Chip(
                label: Text(auth.isStaff ? 'Staff' : 'Student'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') auth.logout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 7),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
