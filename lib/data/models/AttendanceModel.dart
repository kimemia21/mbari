class AttendanceRecord {
  final int id;
  final int meetingId;
  final int memberId;
  final String attendanceStatus;
  final DateTime arrivalTime;
  final String notes;
  final DateTime createdAt;
  final String memberName;

  AttendanceRecord({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.attendanceStatus,
    required this.arrivalTime,
    required this.notes,
    required this.createdAt,
    required this.memberName,
  });

  // from JSON factory
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      meetingId: json['meeting_id'],
      memberId: json['member_id'],
      attendanceStatus: json['attendance_status'],
      arrivalTime: DateTime.parse(json['arrival_time']),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      memberName: json['member_name'],
    );
  }

  // to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'member_id': memberId,
      'attendance_status': attendanceStatus,
      'arrival_time': arrivalTime.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'member_name': memberName,
    };
  }
}
