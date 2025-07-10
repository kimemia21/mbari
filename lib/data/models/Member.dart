class Member {
  final int id;
  final int chamaId;
  final String name;
  final String phoneNumber;
  final bool isActive;
  final DateTime joinedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String chamaName;
  final double monthlyContribution;
  final double meetingFee;
  final double lateFine;
  final double absentFine;
  final String meetingDay;

  Member({
    required this.id,
    required this.chamaId,
    required this.name,
    required this.phoneNumber,
    required this.isActive,
    required this.joinedDate,
    required this.createdAt,
    required this.updatedAt,
    required this.chamaName,
    required this.monthlyContribution,
    required this.meetingFee,
    required this.lateFine,
    required this.absentFine,
    required this.meetingDay,
  });


  factory Member.empty() {
    return Member(
      id: 0,
      chamaId: 0,
      name: '',
      phoneNumber: '',
      isActive: false,
      joinedDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      chamaName: '',
      monthlyContribution: 0.0,
      meetingFee: 0.0,
      lateFine: 0.0,
      absentFine: 0.0,
      meetingDay: '',
    );
  }




  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      chamaId: json['chama_id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isActive: json['is_active'] == 1,
      joinedDate: DateTime.parse(json['joined_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      chamaName: json['chama_name'],
      monthlyContribution: double.parse(json['monthly_contribution']),
      meetingFee: double.parse(json['meeting_fee']),
      lateFine: double.parse(json['late_fine']),
      absentFine: double.parse(json['absent_fine']),
      meetingDay: json['meeting_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chama_id': chamaId,
      'name': name,
      'phoneNumber': phoneNumber,
      'is_active': isActive ? 1 : 0,
      'joined_date': joinedDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'chama_name': chamaName,
      'monthly_contribution': monthlyContribution.toStringAsFixed(2),
      'meeting_fee': meetingFee.toStringAsFixed(2),
      'late_fine': lateFine.toStringAsFixed(2),
      'absent_fine': absentFine.toStringAsFixed(2),
      'meeting_day': meetingDay,
    };
  }
}
