import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/helpers.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';
import 'submit_incident_screen.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;

  const HomeTab({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.incidents;
    final userId = auth.currentUser?.uid;
    final visible = auth.isStaff
        ? incidents
        : incidents.where((item) => item.reporterId == userId).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _HomeHeader(auth: auth),
                const SizedBox(height: 22),
                _ReportBanner(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubmitIncidentScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Report Summary',
                  action: 'See all',
                  onTap: onSeeAll,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SummaryCard(
                      label: 'My Reports',
                      count: visible.length,
                      color: const Color(0xFFE9E2FF),
                      iconColor: const Color(0xFF6C4CF1),
                      icon: Icons.description_outlined,
                    ),
                    _SummaryCard(
                      label: 'In Progress',
                      count: visible
                          .where((i) => i.status == 'In Progress')
                          .length,
                      color: const Color(0xFFDDEBFF),
                      iconColor: Colors.blue,
                      icon: Icons.autorenew,
                    ),
                    _SummaryCard(
                      label: 'Resolved',
                      count: visible
                          .where((i) => i.status == 'Resolved')
                          .length,
                      color: const Color(0xFFDDF5E8),
                      iconColor: Colors.green,
                      icon: Icons.check_circle_outline,
                    ),
                    _SummaryCard(
                      label: 'Submitted',
                      count: visible.where((i) => i.status == 'Pending').length,
                      color: const Color(0xFFFFE0E0),
                      iconColor: Colors.red,
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
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (incidents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No reports yet.'),
                  )
                else
                  ...incidents
                      .take(3)
                      .map(
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
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final AuthProvider auth;

  const _HomeHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name = firstName(auth.userName);
    final userInitials = initials(auth.userName);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Help make our campus safer. Report issues and track their resolution.',
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifications',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') auth.logout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              userInitials.isEmpty ? '?' : userInitials,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ReportBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [primary, const Color(0xFF8A70F5)]),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
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
                  const SizedBox(height: 8),
                  const Text(
                    'Report it and help improve our learning environment.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Report an Issue'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Icon(
                Icons.school_outlined,
                size: 88,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color iconColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.iconColor,
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
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 7),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                maxLines: 1,
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
