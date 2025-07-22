class MeetingDetails {
  final String meetingId;
  final int memberId;
  final Attendance attendance;
  final FinancialGroup meetingFees;
  final FinancialGroup fines;
  final FinancialGroup contributions;
  final Summary summary;

  MeetingDetails({
    required this.meetingId,
    required this.memberId,
    required this.attendance,
    required this.meetingFees,
    required this.fines,
    required this.contributions,
    required this.summary,
  });

  factory MeetingDetails.fromJson(Map<String, dynamic> json) {
    return MeetingDetails(
      meetingId: json['meetingId'],
      memberId: json['memberId'],
      attendance: Attendance.fromJson(json['attendance']),
      meetingFees: FinancialGroup.fromJson(json['meetingFees']),
      fines: FinancialGroup.fromJson(json['fines']),
      contributions: FinancialGroup.fromJson(json['contributions']),
      summary: Summary.fromJson(json['summary']),
    );
  }
}

class Attendance {
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  Attendance({
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      status: json['status'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
    );
  }
}

class FinancialGroup {
  final int total;
  final int count;

  FinancialGroup({required this.total, required this.count});

  factory FinancialGroup.fromJson(Map<String, dynamic> json) {
    return FinancialGroup(
      total: json.containsKey('totalPaid')
          ? json['totalPaid']
          : json.containsKey('totalFines')
              ? json['totalFines']
              : json['totalContributions'],
      count: json['count'],
    );
  }
}

class Summary {
  final int totalFinancialActivity;
  final int outstandingFines;
  final int netContribution;

  Summary({
    required this.totalFinancialActivity,
    required this.outstandingFines,
    required this.netContribution,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalFinancialActivity: json['totalFinancialActivity'],
      outstandingFines: json['outstandingFines'],
      netContribution: json['netContribution'],
    );
  }
}
