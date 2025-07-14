class Member {
  final String id;
  final String name;
  final String phone;
  final double contributedAmount;
  final double debts;
  final int attendance;
  final DateTime joinDate;
  bool isActive;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.contributedAmount,
    required this.debts,
    required this.attendance,
    required this.joinDate,
    required this.isActive,
  });

  // Optional: from JSON (if fetching from an API)
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'].toString(),
      name: json['name'],
      phone: json['phone'],
      contributedAmount: (json['contributedAmount'] ?? 0).toDouble(),
      debts: (json['debts'] ?? 0).toDouble(),
      attendance: (json['attendance'] ?? 0).toInt(),
      joinDate: DateTime.parse(json['joinDate']),
      isActive: json['isActive'] ?? false,
    );
  }

  // Optional: to JSON (if sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'contributedAmount': contributedAmount,
      'debts': debts,
      'attendance': attendance,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
