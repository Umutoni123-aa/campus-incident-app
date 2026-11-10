import 'package:flutter/material.dart';

import 'home_tab.dart';
import 'incident_list_screen.dart';
import 'profile_tab.dart';
import 'submit_incident_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _openSubmit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubmitIncidentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(onSeeAll: () => setState(() => _selectedIndex = 1)),
      const IncidentListScreen(),
      const SizedBox.shrink(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavigationItem(
                icon: Icons.list_alt_outlined,
                label: 'Reports',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _NavigationItem(
                icon: Icons.add,
                label: '',
                selected: false,
                emphasized: true,
                onTap: _openSubmit,
              ),
              _NavigationItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade600;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emphasized
                ? Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white),
                  )
                : Icon(icon, color: color),
            if (!emphasized) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
