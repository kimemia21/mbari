import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Meeting/ONEPAGE.dart';
import 'package:mbari/ADMIN/Meeting/Widgets.dart';

class Meetingfees extends StatefulWidget {
  const Meetingfees({super.key});

  @override
  State<Meetingfees> createState() => _MeetingfeesState();
}

class _MeetingfeesState extends State<Meetingfees> {
  List<MeetingFeeRecord> meetingFees = [
    MeetingFeeRecord(name: "John Doe", amount: 20.0, status: "Paid"),
    MeetingFeeRecord(name: "Mike Johnson", amount: 20.0, status: "Paid"),
    MeetingFeeRecord(name: "Sarah Wilson", amount: 20.0, status: "Pending"),
    MeetingFeeRecord(name: "David Brown", amount: 20.0, status: "Pending"),
    MeetingFeeRecord(name: "Alice Cooper", amount: 20.0, status: "Paid"),
  ];

  Widget buildMeetingFeesSection() {
    double totalCollected = meetingFees
        .where((f) => f.status == "Paid")
        .fold(0.0, (sum, f) => sum + f.amount);
    double totalExpected = meetingFees.fold(0.0, (sum, f) => sum + f.amount);

    return MeetingWidgets.buildTableSection(
      title: 'Meeting Fees',
      subtitle:
          'Total Collected: \$${totalCollected.toStringAsFixed(2)} | Expected: \$${totalExpected.toStringAsFixed(2)} | Present Members Only',
      actionButton: ElevatedButton.icon(
        onPressed: (){},
        //  => _showAddMeetingFeeDialog(),
        icon: Icon(Icons.add),
        label: Text('Record Payment'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
      ),
      child: MeetingWidgets.buildDataTable(
        context: context,
        columns: ['Name', 'Amount', 'Status'],
        rows:
            meetingFees
                .map(
                  (record) => [
                    record.name,
                    '\$${record.amount.toStringAsFixed(2)}',
                    MeetingWidgets.buildStatusChip(record.status),
                  ],
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMeetingFeesSection();
  }
}
