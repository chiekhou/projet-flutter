class UserInfo {
  final int id;
  final int userId;
  final String name;
  final int? points;
  final String type;

  UserInfo({
    required this.id,
    required this.userId,
    required this.name,
    required this.points,
    required this.type,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? json['userId'],
      userId: json['userId'],
      name: json['name'] ?? json['userName'] ?? '',
      points: json['points_accumules'] ?? json['totalPoints'],
      type: json['type'] ?? json['userType'],
    );
  }
}