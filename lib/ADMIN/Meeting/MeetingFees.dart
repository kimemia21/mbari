import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Meeting/ONEPAGE.dart';
import 'package:mbari/ADMIN/Meeting/Widgets.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/MeetingFeeModel.dart';
import 'package:mbari/data/services/globalFetch.dart';
import 'package:mbari/widgets/MeetingLoadingWidget.dart';

class Meetingfees extends StatefulWidget {
  const Meetingfees({super.key});

  @override
  State<Meetingfees> createState() => _MeetingfeesState();
}

class _MeetingfeesState extends State<Meetingfees> {
  late Future<List<MeetingFeeRecord>> fees;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    fees = _fetchFees();
  }

  Future<List<MeetingFeeRecord>> _fetchFees() async {
    final results = await fetchGlobal<MeetingFeeRecord>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => MeetingFeeRecord.fromJson(json),
      endpoint: "meeting-fees/meeting/${meeting.id}}",
    );
    return results;
  }

  Future<void> _updatePaymentStatus(MeetingFeeRecord record) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final newStatus =
          record.status.toLowerCase() == "paid" ? "unpaid" : "paid";

      final results = await comms.putRequest(
        endpoint: "meeting-fees/${record.id}",
        data: {
          "status": "paid",
          "collected_by": user.id,
          "notes": "meeting fee payment for this day is complete",
          "payment_date": "${DateTime.now()}",
        },
      );

      print("============$results============");
      if (results["rsp"]["success"]) {
        showalert(
          success: true,
          context: context,
          title: "successfully",
          subtitle: "Status updated Succesfully",
        );
      } else {
        showalert(
          success: false,
          context: context,
          title: "error",
          subtitle: "Payment error",
        );
      }
      // Make API call to update payment status
      // await comms.putRequests(
      //   endpoint: "meeting-fees/${record.id}",
      //   data: {"status": newStatus},
      // );

      // Show success alert

      // Refresh the data
      setState(() {
        fees = _fetchFees();
      });
    } catch (e) {
      // Show error alert
      showalert(
        success: false,
        context: context,
        title: "error",
        subtitle: "Payment error",
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showPaymentStatusDialog(MeetingFeeRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.teal, size: 28),
              SizedBox(width: 12),
              Text(
                'Update Payment Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Member:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      record.memberName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${record.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Current Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    MeetingWidgets.buildStatusChip(record.status),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                record.status.toLowerCase() == "paid"
                    ? 'Mark this payment as unpaid?'
                    : 'Mark this payment as paid?',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  _isUpdating
                      ? null
                      : () {
                        Navigator.of(context).pop();
                        _updatePaymentStatus(record);
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    record.status.toLowerCase() == "paid"
                        ? Colors.orange[600]
                        : Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isUpdating
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        record.status.toLowerCase() == "paid"
                            ? 'Mark Unpaid'
                            : 'Mark Paid',
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeetingFeesSection(List<MeetingFeeRecord> records) {
    double totalCollected = records
        .where((f) => f.status.toLowerCase() == "paid")
        .fold(0.0, (sum, f) => sum + f.amount);

    double totalExpected = records.fold(0.0, (sum, f) => sum + f.amount);

    return MeetingWidgets.buildTableSection(
      title: 'Meeting Fees',
      subtitle:
          'Total Collected: \$${totalCollected.toStringAsFixed(2)} | Expected: \$${totalExpected.toStringAsFixed(2)} | Present Members Only',
      actionButton: ElevatedButton.icon(
        onPressed: () {
          // _showAddMeetingFeeDialog();
        },
        icon: Icon(Icons.add),
        label: Text('Record Payment'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
      ),
      child: MeetingWidgets.buildDataTable(
        context: context,
        columns: ['Name', 'Amount', 'Status', 'Actions'],
        rows:
            records.map((record) {
              return [
                record.memberName,
                '\$${record.amount.toStringAsFixed(2)}',
                MeetingWidgets.buildStatusChip(record.status),
                Container(
                  child: IconButton(
                    onPressed:
                        _isUpdating
                            ? null
                            : () => _showPaymentStatusDialog(record),
                    icon: Icon(
                      record.status.toLowerCase() == "paid"
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      color:
                          record.status.toLowerCase() == "paid"
                              ? Colors.green[600]
                              : Colors.grey[400],
                      size: 28,
                    ),
                    tooltip:
                        record.status.toLowerCase() == "paid"
                            ? 'Mark as unpaid'
                            : 'Mark as paid',
                  ),
                ),
              ];
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MeetingFeeRecord>>(
      future: fees,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: MeetingLoadingWidget());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading meeting fees'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No meeting fees found.'));
        } else {
          return _buildMeetingFeesSection(snapshot.data!);
        }
      },
    );
  }
}
