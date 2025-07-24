class MembersAdmin {
  final int totalMembers;
  final int activeMembers;
  final int totalContributions;

  final List<MemberStats> memberStats;
  MembersAdmin({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalContributions,
    required this.memberStats,
  });

  factory MembersAdmin.fromJson(Map<String, dynamic> json) {
    var statsList = json['memberStats'] as List;
    List<MemberStats> memberStatsList =
        statsList.map((i) => MemberStats.fromJson(i)).toList();

    return MembersAdmin(
      totalMembers: json['totalMembers'],
      activeMembers: json['activeMembers'],
      totalContributions: json['totalContributions'],
      memberStats: memberStatsList,
    );
  }
}
class MemberStats {
  final int memberId;
  final String memberName;
  final String memberPhone;
  final String memberRole;
  final String memberStatus;
  final double totalContributed;
  final int totalContributions;
  final double outstandingDebt;
  final int meetingsAttended;
  final int timesLate;
  final int totalCompletedMeetings;
  final double attendancePercentage;

  MemberStats({
    required this.memberId,
    required this.memberName,
    required this.memberPhone,
    required this.memberRole,
    required this.memberStatus,
    required this.totalContributed,
    required this.totalContributions,
    required this.outstandingDebt,
    required this.meetingsAttended,
    required this.timesLate,
    required this.totalCompletedMeetings,
    required this.attendancePercentage,
  });

  factory MemberStats.fromJson(Map<String, dynamic> json) {
    return MemberStats(
      memberId: json['member_id'],
      memberName: json['member_name'],
      memberPhone: json['member_phone'],
      memberRole: json['member_role'],
      memberStatus: json['member_status'],
      totalContributed: double.parse(json['total_contributed']),
      totalContributions: json['total_contributions'],
      outstandingDebt: double.parse(json['outstanding_debt']),
      meetingsAttended: json['meetings_attended'],
      timesLate: json['times_late'],
      totalCompletedMeetings: json['total_completed_meetings'],
      attendancePercentage: double.parse(json['attendance_percentage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'member_phone': memberPhone,
      'member_role': memberRole,
      'member_status': memberStatus,
      'total_contributed': totalContributed.toStringAsFixed(2),
      'total_contributions': totalContributions,
      'outstanding_debt': outstandingDebt.toStringAsFixed(2),
      'meetings_attended': meetingsAttended,
      'times_late': timesLate,
      'total_completed_meetings': totalCompletedMeetings,
      'attendance_percentage': attendancePercentage.toStringAsFixed(2),
    };
  }
}
