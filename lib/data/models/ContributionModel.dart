class Contribution {
  final int id;
  final int memberId;
  final int meetingId;
  final String amount;
  final String contributionType;
  final String paymentMethod;
  final DateTime paidAt;
  final DateTime createdAt;
  final String memberName;

  Contribution({
    required this.id,
    required this.memberId,
    required this.meetingId,
    required this.amount,
    required this.contributionType,
    required this.paymentMethod,
    required this.paidAt,
    required this.createdAt,
    required this.memberName,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      memberId: json['member_id'],
      meetingId: json['meeting_id'],
      amount: json['amount'],
      contributionType: json['contribution_type'],
      paymentMethod: json['payment_method'],
      paidAt: DateTime.parse(json['paid_at']),
      createdAt: DateTime.parse(json['created_at']),
      memberName: json['member_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'meeting_id': meetingId,
      'amount': amount,
      'contribution_type': contributionType,
      'payment_method': paymentMethod,
      'paid_at': paidAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'member_name': memberName,
    };
  }
}
