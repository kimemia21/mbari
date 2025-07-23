import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Meeting/Widgets.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/ContributionModel.dart';
import 'package:mbari/data/services/globalFetch.dart';

class ContributionsTable extends StatefulWidget {
  const ContributionsTable({super.key});

  @override
  State<ContributionsTable> createState() => _ContributionsTableState();
}

class _ContributionsTableState extends State<ContributionsTable> {
  late Future<List<Contribution>> contributionsFuture;

  @override
  void initState() {
    super.initState();
    contributionsFuture = fetchContributions();
  }

  Future<List<Contribution>> fetchContributions() async {
    try {
      return await fetchGlobal<Contribution>(
        getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
        fromJson: (json) => Contribution.fromJson(json),
        endpoint: "contributions/meeting/${meeting.id}",
      );
    } catch (e) {
      debugPrint('Error fetching contributions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contribution>>(
      future: contributionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

          return const Center(child: Text('No contributions found.'));
        }

        final contributions = snapshot.data!;
        final totalCollected = contributions.fold<double>(
          0.0,
          (sum, c) => sum + (c.contributionType == "Paid" ? double.parse(c.amount) : 0.0),
        );
        final totalExpected = contributions.fold<double>(
          0.0,
          (sum, c) => sum + double.parse(c.amount),
        );

        return MeetingWidgets.buildTableSection(
          title: 'Contributions',
          subtitle:
              'Total Collected: \$${totalCollected.toStringAsFixed(2)} | Expected: \$${totalExpected.toStringAsFixed(2)}',
          actionButton: ElevatedButton.icon(
            onPressed: _showAddContributionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Cash'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          child: MeetingWidgets.buildDataTable(
            context: context,
            columns: ['Name', 'Amount', 'Payment Method','Type'],
            rows: contributions
                .map(
                  (record) => [
                    record.memberName,
                    '\$${double.parse(record.amount).toStringAsFixed(2)}',
                    record.paymentMethod,
                    MeetingWidgets.buildStatusChip(record.contributionType),
                  ],
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _showAddContributionDialog() {
    // your existing dialog code
  }
}
