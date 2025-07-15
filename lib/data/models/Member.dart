class Member {
  final String id;
  final String name;
  final String phone;

  final double? contributedAmount;
  final double? debts;
  final int? attendance;
  final DateTime? joinDate;
  bool? isActive;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    this.contributedAmount,
    this.debts,
    this.attendance,
    this.joinDate,
    this.isActive,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phoneNumber'] ?? '',
      contributedAmount: json['contributedAmount'] != null
          ? (json['contributedAmount'] as num).toDouble()
          : null,
      debts: json['debts'] != null ? (json['debts'] as num).toDouble() : null,
      attendance: json['attendance'],
      joinDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'contributedAmount': contributedAmount,
      'debts': debts,
      'attendance': attendance,
      'joinDate': joinDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
