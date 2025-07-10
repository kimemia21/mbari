class Chamasdropdown {
  final int id;
  final String name;
  final DateTime createdAt;

  Chamasdropdown({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Factory method to create Chamasdropdown from JSON
  factory Chamasdropdown.fromJson(Map<String, dynamic> json) {
    return Chamasdropdown(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method to convert Chamasdropdown to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
