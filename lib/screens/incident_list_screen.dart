import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/incident_provider.dart';
import '../utils/helpers.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class IncidentListScreen extends StatelessWidget {
  const IncidentListScreen({super.key});

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return 'Just now';
    final localDate = date.toLocal();
    final dateText = MaterialLocalizations.of(context)
        .formatShortDate(localDate);
    final timeText = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(localDate));
    return '$dateText, $timeText';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  onChanged: provider.setSearchText,
                  decoration: const InputDecoration(
                    hintText: 'Search incidents',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              _FilterChips(
                label: 'Category',
                values: IncidentProvider.categories,
                selectedValue: provider.selectedCategory,
                onSelected: provider.setCategory,
              ),
              _FilterChips(
                label: 'Status',
                values: IncidentProvider.statuses,
                displayValue: displayStatus,
                selectedValue: provider.selectedStatus,
                onSelected: provider.setStatus,
              ),
              Expanded(
                child: provider.isLoadingIncidents
                    ? const Center(child: CircularProgressIndicator())
                    : provider.filteredIncidents.isEmpty
                    ? const Center(child: Text('No incidents found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: provider.filteredIncidents.length,
                        itemBuilder: (context, index) {
                          final incident = provider.filteredIncidents[index];
                          return IncidentCard(
                            incident: incident,
                            dateText: _formatDate(context, incident.createdAt),
                            showCategory: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    IncidentDetailScreen(incident: incident),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String label;
  final List<String> values;
  final String Function(String) displayValue;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _FilterChips({
    required this.label,
    required this.values,
    this.displayValue = _identity,
    required this.selectedValue,
    required this.onSelected,
  });

  static String _identity(String value) => value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('$label:'),
          ),
          FilterChip(
            label: const Text('All'),
            selected: selectedValue == null,
            onSelected: (_) => onSelected(null),
          ),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(displayValue(value)),
                selected: selectedValue == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
