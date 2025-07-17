class MeetingFeeRecord {
  final int id;
  final int memberId;
  final int meetingId;
  final double amount;
  final int paymentMethodId;
  final String? paymentDate;
  final String status;
  final String? collectedBy;
  final String notes;
  final String createdAt;
  final String memberName;
  final String? meetingDate;
  final String paymentMethod;
  final String? collectedByName;

  MeetingFeeRecord({
    required this.id,
    required this.memberId,
    required this.meetingId,
    required this.amount,
    required this.paymentMethodId,
    required this.paymentDate,
    required this.status,
    required this.collectedBy,
    required this.notes,
    required this.createdAt,
    required this.memberName,
    required this.meetingDate,
    required this.paymentMethod,
    required this.collectedByName,
  });

  factory MeetingFeeRecord.fromJson(Map<String, dynamic> json) {
    return MeetingFeeRecord(
      id: json['id'] ?? 0,
      memberId: json['member_id'] ?? 0,
      meetingId: json['meeting_id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
      paymentMethodId: json['payment_method_id'] ?? 0,
      paymentDate: json['payment_date'], // can be null
      status: json['status'] ?? 'unknown',
      collectedBy: json['collected_by']?.toString(),
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      memberName: json['member_name'] ?? 'Unknown',
      meetingDate: json['meeting_date'], // can be null
      paymentMethod: json['payment_method'] ?? 'unknown',
      collectedByName: json['collected_by_name'], // can be null
    );
  }
}
