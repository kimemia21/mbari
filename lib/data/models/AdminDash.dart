class ChamaStats {
  final int totalUsers;
  final int activeUsers;
  final double totalContributions;
  final int totalCompleteMeetings;
  final double avgContributionPerUser;
  final int chamaId;

  ChamaStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalContributions,
    required this.totalCompleteMeetings,
    required this.avgContributionPerUser,
    required this.chamaId,
  });

  factory ChamaStats.fromJson(Map<String, dynamic> json) {
    return ChamaStats(
      totalUsers: json['totalUsers'],
      activeUsers: json['activeUsers'],
      totalContributions: json['totalContributions'],
      totalCompleteMeetings: json['totalCompleteMeetings'],
      avgContributionPerUser: json['avgContributionPerUser'],
      chamaId: json['chamaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalContributions': totalContributions,
      'totalCompleteMeetings': totalCompleteMeetings,
      'avgContributionPerUser': avgContributionPerUser,
      'chamaId': chamaId,
    };
  }
}
