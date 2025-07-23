class Members {
  final int id;
  final String name;
  final String phoneNumber;
  final int chamaId;
  final DateTime createdAt;

  Members({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.chamaId,
    required this.createdAt,
  });

  factory Members.fromJson(Map<String, dynamic> json) {
    return Members(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      chamaId: json['chama_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'chama_id': chamaId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
