import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Meeting/Attendance.dart';
import 'package:mbari/ADMIN/Meeting/Contributions.dart';
import 'package:mbari/ADMIN/Meeting/MeetingFees.dart';
import 'package:mbari/ADMIN/Meeting/Widgets.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/models/MeetingFeeModel.dart';
import 'package:mbari/widgets/MeetingLoadingWidget.dart';

class MeetingManagementPage extends StatefulWidget {
  @override
  _MeetingManagementPageState createState() => _MeetingManagementPageState();
}

class _MeetingManagementPageState extends State<MeetingManagementPage> {
  final TextEditingController _agendaController = TextEditingController(
    text:
        "1. Review previous meeting minutes\n2. Financial report presentation\n3. New project proposals\n4. Budget allocation discussion\n5. Next meeting schedule",
  );

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 11, minute: 30);
  bool isMeetingActive = true;
  double cashInHand = 285.50; // Initial cash amount

  List<AttendanceRecord> attendance = [
    AttendanceRecord(name: "John Doe", status: "Present", arrivalTime: "09:00"),
    AttendanceRecord(name: "Jane Smith", status: "Absent", arrivalTime: "-"),
    AttendanceRecord(
      name: "Mike Johnson",
      status: "Late",
      arrivalTime: "09:15",
    ),
    AttendanceRecord(
      name: "Sarah Wilson",
      status: "Present",
      arrivalTime: "08:55",
    ),
    AttendanceRecord(name: "David Brown", status: "Late", arrivalTime: "09:20"),
    AttendanceRecord(
      name: "Alice Cooper",
      status: "Present",
      arrivalTime: "09:02",
    ),
  ];

  List<ContributionRecord> contributions = [
    ContributionRecord(
      name: "John Doe",
      amount: 50.0,
      paymentMethod: "Cash",
      status: "Paid",
    ),
    ContributionRecord(
      name: "Jane Smith",
      amount: 50.0,
      paymentMethod: "Mobile",
      status: "Pending",
    ),
    ContributionRecord(
      name: "Mike Johnson",
      amount: 75.0,
      paymentMethod: "Mobile",
      status: "Paid",
    ),
    ContributionRecord(
      name: "Sarah Wilson",
      amount: 50.0,
      paymentMethod: "Cash",
      status: "Pending",
    ),
    ContributionRecord(
      name: "David Brown",
      amount: 100.0,
      paymentMethod: "Mobile",
      status: "Paid",
    ),
    ContributionRecord(
      name: "Alice Cooper",
      amount: 60.0,
      paymentMethod: "Cash",
      status: "Paid",
    ),
  ];

  List<MeetingFeeRecord> meetingFees = [
    MeetingFeeRecord(
      id: 1,
      memberId: 101,
      meetingId: 201,
      amount: 100.00,
      paymentMethodId: 1,
      paymentDate: '2025-07-16T10:00:00.000Z',
      status: 'paid',
      collectedBy: 'admin001',
      notes: 'Paid in full',
      createdAt: '2025-07-16T09:50:00.000Z',
      memberName: 'John Doe',
      meetingDate: '2025-07-17T14:00:00.000Z',
      paymentMethod: 'cash',
      collectedByName: 'Alice Admin',
    ),
    MeetingFeeRecord(
      id: 2,
      memberId: 102,
      meetingId: 201,
      amount: 100.00,
      paymentMethodId: 2,
      paymentDate: null,
      status: 'pending',
      collectedBy: null,
      notes: 'Will pay at the meeting',
      createdAt: '2025-07-16T10:10:00.000Z',
      memberName: 'Sarah Wilson',
      meetingDate: '2025-07-17T14:00:00.000Z',
      paymentMethod: 'mpesa',
      collectedByName: null,
    ),
    MeetingFeeRecord(
      id: 3,
      memberId: 103,
      meetingId: 201,
      amount: 100.00,
      paymentMethodId: 1,
      paymentDate: '2025-07-16T11:00:00.000Z',
      status: 'paid',
      collectedBy: 'admin002',
      notes: 'Late payment',
      createdAt: '2025-07-16T10:55:00.000Z',
      memberName: 'David Brown',
      meetingDate: '2025-07-17T14:00:00.000Z',
      paymentMethod: 'cash',
      collectedByName: 'Bob Admin',
    ),
    MeetingFeeRecord(
      id: 4,
      memberId: 104,
      meetingId: 201,
      amount: 100.00,
      paymentMethodId: 3,
      paymentDate: '2025-07-16T12:30:00.000Z',
      status: 'paid',
      collectedBy: 'admin003',
      notes: 'Via bank deposit',
      createdAt: '2025-07-16T12:00:00.000Z',
      memberName: 'Alice Cooper',
      meetingDate: '2025-07-17T14:00:00.000Z',
      paymentMethod: 'bank',
      collectedByName: 'Eve Admin',
    ),
  ];

  List<FineRecord> fines = [
    FineRecord(
      name: "Jane Smith",
      reason: "Absence",
      amount: 10.0,
      status: "Unpaid",
    ),
    FineRecord(
      name: "Mike Johnson",
      reason: "Late arrival",
      amount: 5.0,
      status: "Paid",
    ),
    FineRecord(
      name: "David Brown",
      reason: "Late arrival",
      amount: 5.0,
      status: "Unpaid",
    ),
  ];

  List<DebtRecord> debts = [
    DebtRecord(
      name: "Jane Smith",
      debtType: "Meeting Fee",
      totalAmount: 50.0,
      paidAmount: 0.0,
    ),
    DebtRecord(
      name: "Sarah Wilson",
      debtType: "Meeting Fee",
      totalAmount: 50.0,
      paidAmount: 25.0,
    ),
    DebtRecord(
      name: "Jane Smith",
      debtType: "Fine",
      totalAmount: 10.0,
      paidAmount: 0.0,
    ),
    DebtRecord(
      name: "David Brown",
      debtType: "Fine",
      totalAmount: 5.0,
      paidAmount: 0.0,
    ),
  ];

  List<EventRecord> events = [
    EventRecord(
      eventName: "Annual Dinner",
      date: DateTime(2024, 12, 15),
      amount: 25.0,
      description: "Year-end celebration",
    ),
    EventRecord(
      eventName: "Team Building",
      date: DateTime(2024, 11, 20),
      amount: 15.0,
      description: "Outdoor activities",
    ),
    EventRecord(
      eventName: "Workshop",
      date: DateTime(2024, 10, 30),
      amount: 30.0,
      description: "Skills development",
    ),
  ];

  late Future<bool> _todayMeeting;
  String? msg;
  Future<bool> checkForMeeting() async {
    try {
      final results = await comms.getRequests(endpoint: "meeting/today");
      if (results["rsp"]["success"]) {
        meeting = Meeting.fromJson(results["rsp"]["data"]);
        print("=====================================${meeting.toJson()}====================================");
        showalert(
          success: true,
          context: context,
          title: "Success",
          subtitle: results["rsp"]["message"],
        );
        return true;
      } else {
        showalert(
          success: false,
          context: context,
          title: "No Meeting Found",
          subtitle: results["rsp"]["message"],
        );
        msg = results["rsp"]["message"];
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _todayMeeting = checkForMeeting();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _todayMeeting,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: MeetingLoadingWidget());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error checking meeting status'));
        } else if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            appBar: AppBar(
              title: Text('Meeting Admin Dashboard'),
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
              elevation: 1,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: isMeetingActive ? _endMeeting : null,
                    icon: Icon(Icons.stop_circle, size: 18),
                    label: Text('End Meeting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            body: FutureBuilder<bool>(
              future: _todayMeeting,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error checking meeting status'),
                  );
                } else if (snapshot.hasData && snapshot.data == true) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCashInHandSection(),
                        SizedBox(height: 20),
                        _buildMeetingHeader(),
                        SizedBox(height: 20),
                        _buildQuickStats(),
                        SizedBox(height: 20),
                        AttendanceTable(),
                        SizedBox(height: 20),
                        ContributionsTable(),
                        SizedBox(height: 20),
                        Meetingfees(),
                        SizedBox(height: 20),
                        _buildFinesSection(),
                        SizedBox(height: 20),
                        _buildDebtsSection(),
                        SizedBox(height: 20),
                        _buildEventsSection(),
                        SizedBox(height: 20),
                        _buildAgendaSection(),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy, color: Colors.red, size: 40),
                          SizedBox(height: 10),
                          Text(
                            msg ?? '❌ No meeting scheduled for today.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          );
        } else {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    msg ?? '❌ No meeting scheduled for today.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCashInHandSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash in Hand',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Cashier Balance',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(
              '\$${cashInHand.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meeting Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Time: ${startTime.format(context)} - ${endTime.format(context)}',
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isMeetingActive
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isMeetingActive ? 'Active' : 'Ended',
              style: TextStyle(
                color:
                    isMeetingActive
                        ? Colors.green.shade800
                        : Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    double totalContributions = contributions
        .where((c) => c.status == "Paid")
        .fold(0.0, (sum, c) => sum + c.amount);
    double expectedContributions = contributions.fold(
      0.0,
      (sum, c) => sum + c.amount,
    );
    double totalFines = fines
        .where((f) => f.status == "Paid")
        .fold(0.0, (sum, f) => sum + f.amount);
    double expectedFines = fines.fold(0.0, (sum, f) => sum + f.amount);
    double totalMeetingFees = meetingFees
        .where((f) => f.status == "Paid")
        .fold(0.0, (sum, f) => sum + f.amount);
    double expectedMeetingFees = meetingFees.fold(
      0.0,
      (sum, f) => sum + f.amount,
    );
    int presentCount = attendance.where((a) => a.status == "Present").length;
    int lateCount = attendance.where((a) => a.status == "Late").length;
    int absentCount = attendance.where((a) => a.status == "Absent").length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Present',
                  presentCount.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Late',
                  lateCount.toString(),
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Absent',
                  absentCount.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Contributions',
                  '\$${totalContributions.toStringAsFixed(2)} / \$${expectedContributions.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Meeting Fees',
                  '\$${totalMeetingFees.toStringAsFixed(2)} / \$${expectedMeetingFees.toStringAsFixed(2)}',
                  Colors.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Fines',
                  '\$${totalFines.toStringAsFixed(2)} / \$${expectedFines.toStringAsFixed(2)}',
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Cash',
                  '\$${(totalContributions + totalMeetingFees + totalFines).toStringAsFixed(2)}',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  

  Widget _buildFinesSection() {
    double totalCollected = fines
        .where((f) => f.status == "Paid")
        .fold(0.0, (sum, f) => sum + f.amount);
    double totalExpected = fines.fold(0.0, (sum, f) => sum + f.amount);

    return MeetingWidgets.buildTableSection(
      title: 'Fines',
      subtitle:
          'Total Collected: \$${totalCollected.toStringAsFixed(2)} | Expected: \$${totalExpected.toStringAsFixed(2)} | Payment to Bank',
      child: MeetingWidgets.buildDataTable(
        context: context,
        columns: ['Name', 'Reason', 'Amount', 'Status'],
        rows:
            fines
                .map(
                  (record) => [
                    record.name,
                    record.reason,
                    '\$${record.amount.toStringAsFixed(2)}',
                    MeetingWidgets.buildStatusChip(record.status),
                  ],
                )
                .toList(),
      ),
    );
  }

  Widget _buildDebtsSection() {
    double totalDebt = debts.fold(
      0.0,
      (sum, d) => sum + (d.totalAmount - d.paidAmount),
    );
    double totalExpected = debts.fold(0.0, (sum, d) => sum + d.totalAmount);

    return MeetingWidgets.buildTableSection(
      title: 'Outstanding Debts',
      subtitle:
          'Total Outstanding: \$${totalDebt.toStringAsFixed(2)} | Total Expected: \$${totalExpected.toStringAsFixed(2)}',
      child: MeetingWidgets.buildDataTable(
        context: context,
        columns: [
          'Name',
          'Debt Type',
          'Total Amount',
          'Paid Amount',
          'Remaining',
        ],
        rows:
            debts
                .map(
                  (record) => [
                    record.name,
                    record.debtType,
                    '\$${record.totalAmount.toStringAsFixed(2)}',
                    '\$${record.paidAmount.toStringAsFixed(2)}',
                    '\$${(record.totalAmount - record.paidAmount).toStringAsFixed(2)}',
                  ],
                )
                .toList(),
      ),
    );
  }

  Widget _buildEventsSection() {
    return MeetingWidgets.buildTableSection(
      title: 'Events',
      subtitle: 'Upcoming and Past Events',
      actionButton: ElevatedButton.icon(
        onPressed: () => _showAddEventDialog(),
        icon: Icon(Icons.event),
        label: Text('Add Event'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
      ),
      child: MeetingWidgets.buildDataTable(
        context: context,
        columns: ['Event Name', 'Date', 'Amount', 'Description'],
        rows:
            events
                .map(
                  (record) => [
                    record.eventName,
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    '\$${record.amount.toStringAsFixed(2)}',
                    record.description,
                  ],
                )
                .toList(),
      ),
    );
  }

  Widget _buildAgendaSection() {
    return MeetingWidgets.buildTableSection(
      title: 'Meeting Agenda',
      child: Container(
        width: double.infinity,
        child: TextField(
          controller: _agendaController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLines: 8,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _endMeeting() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('End Meeting'),
          content: Text(
            'Are you sure you want to end this meeting? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMeetingActive = false;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meeting ended successfully')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('End Meeting'),
            ),
          ],
        );
      },
    );
  }

  void _showAddContributionDialog() {
    String selectedMember = contributions.first.name;
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Cash Contribution'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMember,
                    decoration: InputDecoration(labelText: 'Select Member'),
                    items:
                        contributions
                            .map(
                              (contrib) => DropdownMenuItem(
                                value: contrib.name,
                                child: Text(contrib.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMember = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Amount (\$)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (amount > 0) {
                  setState(() {
                    cashInHand += amount;
                    // Update contribution record
                    int index = contributions.indexWhere(
                      (c) => c.name == selectedMember,
                    );
                    if (index != -1) {
                      contributions[index] = ContributionRecord(
                        name: selectedMember,
                        amount: contributions[index].amount + amount,
                        paymentMethod: "Cash",
                        status: "Paid",
                      );
                    }
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cash contribution added successfully'),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // void _showAddMeetingFeeDialog() {
  //   String selectedMember = meetingFees.first.name;
  //   double amount = 20.0;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Record Meeting Fee Payment'),
  //         content: StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 DropdownButtonFormField<String>(
  //                   value: selectedMember,
  //                   decoration: InputDecoration(
  //                     labelText: 'Select Present Member',
  //                   ),
  //                   items:
  //                       meetingFees
  //                           .where(
  //                             (fee) => attendance.any(
  //                               (att) =>
  //                                   att.name == fee.name &&
  //                                   (att.status == "Present" ||
  //                                       att.status == "Late"),
  //                             ),
  //                           )
  //                           .map(
  //                             (fee) => DropdownMenuItem(
  //                               value: fee.name,
  //                               child: Text(fee.name),
  //                             ),
  //                           )
  //                           .toList(),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       selectedMember = value!;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(height: 16),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Amount (\$)'),
  //                   keyboardType: TextInputType.number,
  //                   controller: TextEditingController(text: amount.toString()),
  //                   onChanged: (value) {
  //                     amount = double.tryParse(value) ?? 20.0;
  //                   },
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   'Cash Payment Only',
  //                   style: TextStyle(fontSize: 12, color: Colors.grey),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (amount > 0) {
  //                 setState(() {
  //                   cashInHand += amount;
  //                   // Update meeting fee record
  //                   int index = meetingFees.indexWhere(
  //                     (f) => f.name == selectedMember,
  //                   );
  //                   if (index != -1) {
  //                     meetingFees[index] = MeetingFeeRecord(
  //                       id: 23,
  //                       memberName: selectedMember,
  //                       amount: amount,
  //                       status: "Paid",
  //                     );
  //                   }
  //                 });
  //                 Navigator.of(context).pop();
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text('Meeting fee recorded successfully'),
  //                   ),
  //                 );
  //               }
  //             },
  //             child: Text('Record'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showAddEventDialog() {
    String eventName = '';
    DateTime selectedDate = DateTime.now();
    double amount = 0.0;
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Event Name'),
                    onChanged: (value) => eventName = value,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Amount (\$)'),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (value) => amount = double.tryParse(value) ?? 0.0,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (eventName.isNotEmpty && amount > 0) {
                  setState(() {
                    events.add(
                      EventRecord(
                        eventName: eventName,
                        date: selectedDate,
                        amount: amount,
                        description: description,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event added successfully')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Model classes
class AttendanceRecord {
  final String name;
  final String status;
  final String arrivalTime;

  AttendanceRecord({
    required this.name,
    required this.status,
    required this.arrivalTime,
  });
}

class ContributionRecord {
  final String name;
  final double amount;
  final String paymentMethod;
  final String status;

  ContributionRecord({
    required this.name,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}

class FineRecord {
  final String name;
  final String reason;
  final double amount;
  final String status;

  FineRecord({
    required this.name,
    required this.reason,
    required this.amount,
    required this.status,
  });
}

class DebtRecord {
  final String name;
  final String debtType;
  final double totalAmount;
  final double paidAmount;

  DebtRecord({
    required this.name,
    required this.debtType,
    required this.totalAmount,
    required this.paidAmount,
  });
}

class EventRecord {
  final String eventName;
  final DateTime date;
  final double amount;
  final String description;

  EventRecord({
    required this.eventName,
    required this.date,
    required this.amount,
    required this.description,
  });
}
