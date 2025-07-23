class MemberSummary {
  final double totalContributed;
  final int totalContributions;
  final double outstandingDebt;

  MemberSummary({
    required this.totalContributed,
    required this.totalContributions,
    required this.outstandingDebt,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) {
    return MemberSummary(
      totalContributed: double.parse(json['total_contributed'].toString()),
      totalContributions: json['total_contributions'],
      outstandingDebt: double.parse(json['outstanding_debt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_contributed': totalContributed.toStringAsFixed(2),
      'total_contributions': totalContributions,
      'outstanding_debt': outstandingDebt.toStringAsFixed(2),
    };
  }
}
